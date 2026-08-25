# CI/CD Pipeline Guide

This document describes the CI/CD pipeline for this NixOS flake repository.

## Overview

The CI/CD pipeline performs the following checks:
- Validates flake structure and metadata
- Dry-runs and evaluates 7 configurations (6 desktops + 1 headless)
- Optionally tests VM boots for two configurations on labeled pull requests
- Checks module syntax and references
- Scans for hardcoded secrets
- Validates the Home Manager configuration

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

### Configuration Checks (runs on every push/PR)
These ensure all configurations evaluate and their builds can be planned:

3. **Configuration Matrix** (runs in parallel)
   - Matrix check for all 7 configurations
   - Dry-run system builds
   - Checks configurations evaluate without errors
   - Cachix caching is not enabled

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

### VM Boot Tests (label-gated)
Optional VM boot tests that verify systems actually boot:

7. **VM Boot Tests** - **LABELED PULL REQUESTS ONLY**
   - **Only runs when:**
     - You add the `test-vm-boot` label to a PR
      - Does not run for pushes to `main` or unlabeled pull requests
   - Tests 2 representative configurations:
     - `base-server` (headless, minimal)
     - `xfce-workstation` (lightweight desktop)
   - Verifies each VM:
     - Boots successfully with 2GB RAM
     - Reaches `multi-user.target` or `graphical.target`
     - Completes within 15 minutes (12 min boot timeout + 3 min buffer)
     - Progress updates every minute during boot
   - Uploads serial logs on failure
   
   **When to use:** Major boot-related changes, kernel updates, or systemd configuration changes.

## Understanding the Results

### All Required Checks Passed
The required validation, dry-run, and evaluation jobs completed successfully. This does not imply that VM boot tests ran.

### Configuration Checks Failed
One or more configurations failed a dry-run or evaluation. Check the specific job for details.

### VM Boot Tests Failed
A tested configuration failed to build its VM or reach the expected systemd target. Possible causes include:
- Kernel/initrd issues
- Systemd configuration problems
- Missing required packages
- Hardware emulation issues

### Security Checks Failed
Found hardcoded secrets or sensitive data. Review and fix before merging.

## Running VM Tests Manually

VM tests are expensive (time and resources), so they only run when explicitly requested:

### Trigger VM Tests in CI
Add the label `test-vm-boot` to your PR. The VM boot tests will run for base-server and xfce-workstation.

### Local Testing
You can build and run a VM locally:

```bash
# Build a VM for testing
nix build .#nixosConfigurations.gnome-workstation.config.system.build.vm

# Run the VM interactively
./result/bin/run-*-vm

# Or test boot automatically (headless)
QEMU_KERNEL_PARAMS="console=ttyS0" ./result/bin/run-*-vm -nographic
```

### GitHub Actions Concurrency
The workflow cancels in-progress runs for the same branch, preventing wasted resources.

## Configuration Matrix

| Configuration | Dry-run/Evaluation | VM Boot Test | Notes |
|---------------|------------|--------------|-------|
| base-server | Yes | Label-gated | Headless configuration |
| cosmic-workstation | Yes | No | COSMIC desktop |
| gnome-workstation | Yes | No | GNOME desktop |
| kde-workstation | Yes | No | KDE Plasma desktop |
| cinnamon-workstation | Yes | No | Cinnamon desktop |
| xfce-workstation | Yes | Label-gated | XFCE desktop |
| hyprland-workstation | Yes | No | Hyprland desktop |

VM boot tests are limited to `base-server` and `xfce-workstation` and run only when a pull request has the `test-vm-boot` label.

## Troubleshooting

### "nix-instantiate: not found"
The `validate-basics` job installs Nix before running syntax checks. If this error occurs, check the Nix installation step in that job.

### "file 'nixpkgs/nixos' was not found in the Nix search path"
Syntax validation uses `nix-instantiate --parse` and does not require `<nixpkgs/nixos>` to be present in `NIX_PATH`.

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

**Troubleshooting:**
- The workflow allows 12 minutes for the VM to reach a target
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

## Contributing

See [CONTRIBUTING.md](../documentation/CONTRIBUTING.md) for repository contribution guidance.
