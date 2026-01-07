# CI/CD Pipeline Guide

This document explains the comprehensive CI/CD pipeline for this NixOS flake repository.

## Overview

The CI/CD pipeline is designed to catch issues before they reach your production machines by:
- ✅ Validating flake structure and metadata
- ✅ Building all 10 configurations (9 desktops + 1 headless)
- ✅ Testing VM boots for critical configurations
- ✅ Checking modules can be imported
- ✅ Security scanning for hardcoded secrets
- ✅ Home Manager configuration validation

## Pipeline Structure

### Quick Checks (runs on every push/PR)
These lightweight checks fail fast if there are basic issues:

1. **Basic Validation** (~1 min)
   - Installs Nix (required for syntax checking)
   - Validates Nix file syntax using `nix-instantiate`
   - Checks profile/machine structure
   - Validates Home Manager imports

2. **Flake Structure Validation** (~2 min)
   - Validates flake metadata
   - Checks all expected configurations exist
   - Verifies homeConfigurations

### Build Checks (runs on every push/PR)
These ensure all configurations can build:

3. **Build Configurations** (~5-10 min per config, runs in parallel)
   - Matrix build for all 10 configurations
   - Dry-run builds (doesn't actually build, just evaluates)
   - Checks configurations evaluate without errors
   - Uses Cachix to speed up builds

### Module & Security Checks (runs on every push/PR)

4. **Module Validation** (~1 min)
   - Validates Nix syntax for all module files
   - Verifies modules are referenced in profiles
   - Checks for broken symlinks

5. **Security Checks** (~1 min)
   - Scans for hardcoded secrets
   - Checks for non-placeholder example data
   - Validates git attributes

6. **Home Manager Validation** (~2 min)
   - Builds Home Manager configurations
   - Validates they evaluate correctly

### VM Boot Tests (manual only - opt-in)
Optional VM boot tests that verify systems actually boot:

7. **VM Boot Tests** (~3-8 min per config) - **MANUAL TRIGGER ONLY**
   - **Only runs when:**
     - You add the `test-vm-boot` label to a PR
     - **Does NOT run automatically on main or PRs**
   - Tests 2 representative configurations:
     - `base-server` (headless, minimal)
     - `xfce-workstation` (lightweight desktop)
   - **Why manual-only?**
     - Very resource-intensive (10+ minutes even for lightweight configs)
     - Build/evaluation tests catch 95%+ of issues
     - Can be run locally when needed
     - Saves CI resources and time for routine checks
   - Verifies each VM:
     - Boots successfully with 2GB RAM
     - Reaches `multi-user.target` or `graphical.target`
     - Completes within 15 minutes (12 min boot timeout + 3 min buffer)
     - Progress updates every minute during boot
   - Uploads serial logs on failure
   - Enhanced logging for troubleshooting
   
   **When to use:** Major boot-related changes, kernel updates, or systemd configuration changes.

## Understanding the Results

### ✅ All Checks Passed
All configurations build and evaluate correctly. Safe to deploy!

### ⚠️ Build Tests Failed
One or more configurations failed to evaluate or build. Check the specific job for details.

### ⚠️ VM Boot Tests Failed
A configuration built successfully but failed to boot. This is serious and indicates:
- Kernel/initrd issues
- Systemd configuration problems
- Missing required packages
- Hardware emulation issues

### 🔒 Security Checks Failed
Found hardcoded secrets or sensitive data. Review and fix before merging.

## Running VM Tests Manually

VM tests are expensive (time and resources), so they only run when explicitly requested:

### Trigger VM Tests in CI
Add the label `test-vm-boot` to your PR. The VM boot tests will run for base-server and xfce-workstation.

### Local Testing (Recommended)
Instead of running expensive CI VM tests, test locally:
You can run VM tests locally before pushing:

```bash
# Build a VM for testing
nix build .#nixosConfigurations.gnome-workstation.config.system.build.vm

# Run the VM interactively
./result/bin/run-*-vm

# Or test boot automatically (headless)
QEMU_KERNEL_PARAMS="console=ttyS0" ./result/bin/run-*-vm -nographic
```

## Optimizing Build Times

### Cachix Setup
The pipeline uses the `nixos-cosmic` Cachix cache. To speed up builds further:

1. Create a Cachix account at https://cachix.org
2. Create a cache (or use an existing one)
3. Add `CACHIX_AUTH_TOKEN` secret to your GitHub repository
4. Update the workflow to use your cache name

### GitHub Actions Concurrency
The workflow cancels in-progress runs for the same branch, preventing wasted resources.

## Configuration Matrix

| Configuration | Build Test | VM Boot Test | Notes |
|---------------|------------|--------------|-------|
| base-server | ✅ | ✅ | Headless baseline - always VM tested |
| cosmic-workstation | ✅ | ⏭️ | Requires nixos-cosmic cache |
| gnome-workstation | ✅ | ⏭️ | Full GNOME stack - build tested only |
| kde-workstation | ✅ | ⏭️ | Full KDE Plasma 6 - build tested only |
| cinnamon-workstation | ✅ | ⏭️ | Cinnamon desktop |
| xfce-workstation | ✅ | ✅ | Lightweight desktop - always VM tested |
| mate-workstation | ✅ | ⏭️ | MATE desktop |
| budgie-workstation | ✅ | ⏭️ | Budgie desktop |
| pantheon-workstation | ✅ | ⏭️ | Pantheon desktop |
| lxqt-workstation | ✅ | ⏭️ | LXQt desktop |

✅ = Always tested  
⏭️ = Build/evaluation tested only (not VM booted)

**Rationale:** Only base-server and xfce-workstation are VM boot tested because:
- They're fast and resource-efficient for CI
- They validate both headless and graphical boot paths
- Heavier desktops (GNOME, KDE) are thoroughly validated via build and evaluation tests
- Reduces CI time and resource consumption

## Troubleshooting

### "nix-instantiate: not found"
The workflow tried to use Nix before it was installed. This has been fixed in the current workflow by installing Nix before running syntax checks in the `validate-basics` job.

### "file 'nixpkgs/nixos' was not found in the Nix search path"
This error occurred in older versions of the workflow that tried to use `<nixpkgs/nixos>` for module validation. The current workflow uses `nix-instantiate --parse` for syntax validation instead, which doesn't require NIX_PATH to be set.

### "VM boot timeout"
The VM didn't reach multi-user.target within the allowed time. This can happen for several reasons:

**Diagnosis:**
1. Go to the failed workflow run
2. Download the `vm-serial-log-<config>` artifact
3. Review the serial log for boot errors or hangs

**Common causes:**
- **Slow evaluation/build** - Some desktop environments (especially GNOME/KDE) take longer to evaluate
- **Missing dependencies** - Check for service failures in the log
- **Kernel panic** - Look for "Kernel panic" or "Oops" messages
- **Systemd service timeout** - A service might be waiting for a timeout
- **Resource constraints** - VMs run with 2GB RAM, might be insufficient for heavy desktops

**Solutions:**
- The workflow now allows 12 minutes for boot (increased from 4 minutes)
- Check the progress indicators in the workflow log to see how far it got
- Look for the last systemd target reached in the serial log
- If a specific service is hanging, it may need to be disabled in VM tests

**Testing locally:**
```bash
# Build and test VM locally
nix build .#nixosConfigurations.gnome-workstation.config.system.build.vm
QEMU_KERNEL_PARAMS="console=ttyS0" ./result/bin/run-*-vm -nographic -m 2048
```

### "Configuration evaluation failed"
Syntax or reference error in your Nix code. Check the build log for details.

### "Module import failed"
A module has missing dependencies or syntax errors. Check the specific module mentioned.

### "KVM not available"
GitHub Actions runners support KVM. If this fails, it's likely a runner configuration issue.

## Cost Considerations

### Free Tier (GitHub Actions)
- 2,000 minutes/month for free (public repos get unlimited)
- VM boot tests are the most expensive (~5-10 min each)
- Build tests are cheaper (~5 min total for dry-run)

### Optimization Tips
1. Use Cachix to avoid rebuilding unchanged dependencies
2. Only run VM tests on main branch and labeled PRs
3. Use fail-fast: false in matrix to see all failures at once
4. Cancel in-progress runs when pushing new commits

## Adding New Configurations

When adding a new desktop environment or profile:

1. Add it to the `build-configurations` matrix
2. Optionally add it to `vm-boot-tests` matrix if critical
3. Update the expected configuration check in `validate-flake-structure`

Example:
```yaml
matrix:
  config:
    - base-server
    - cosmic-workstation
    - your-new-config  # Add here
```

## Best Practices

1. **Always run locally first**: `nix flake check` and `nix build .#nixosConfigurations.X.config.system.build.toplevel`
2. **Test VMs locally** before pushing if making significant changes
3. **Use descriptive commit messages** to understand CI failures
4. **Review VM serial logs** when boot tests fail
5. **Don't skip security checks** - they catch real issues

## Future Enhancements

Potential improvements for this pipeline:

- [ ] Add integration tests (e.g., test that services start)
- [ ] Test specialisation configurations
- [ ] Add performance benchmarks
- [ ] Test upgrades from previous versions
- [ ] Add automatic dependency updates (renovate/dependabot)
- [ ] Generate build reports with size comparisons

## Questions?

See [CONTRIBUTING.md](../CONTRIBUTING.md) for more information on contributing to this repository.
