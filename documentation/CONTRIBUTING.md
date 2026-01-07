# Contributing to nixos-base

Thank you for your interest in improving this NixOS starter repository!

## How to Contribute

### Reporting Issues
- Check existing issues before creating a new one
- Include your NixOS version and desktop environment
- Provide reproduction steps if reporting a bug

### Adding a New Desktop Environment

To add a new desktop environment to this repository:

1. **Create a module** in `modules/<desktop>.nix`:
   ```nix
   { config, pkgs, lib, ... }:
   let
     cfg = config.<desktop>;
   in {
     options.<desktop> = {
       enable = lib.mkEnableOption "Enable <Desktop> desktop environment";
       extraPackages = lib.mkOption {
         type = lib.types.listOf lib.types.package;
         default = [];
         description = "Extra packages to install.";
       };
     };

     config = lib.mkIf cfg.enable {
       services.xserver.enable = true;
       # ... desktop-specific configuration
     };
   }
   ```

2. **Create a profile** in `profiles/<desktop>.nix`:
   ```nix
   { config, pkgs, lib, inputs, ... }:
   {
     imports = [
       ../machines/configuration.nix
       ../modules/common-packages.nix
       ../modules/<desktop>.nix
       ../modules/home-manager.nix
     ];

     # Placeholder filesystems for flake validation
     fileSystems."/" = lib.mkDefault {
       device = "/dev/disk/by-label/nixos-root";
       fsType = "ext4";
     };

     fileSystems."/boot" = lib.mkDefault {
       device = "/dev/disk/by-label/EFI";
       fsType = "vfat";
     };

     <desktop>.enable = true;
   }
   ```

3. **Add to flake.nix**:
   ```nix
   nixosConfigurations = {
     # ... existing configs
     <desktop>-workstation = mkSystem ./profiles/<desktop>.nix;
   };
   ```

4. **Update documentation**:
   - Add entry to `README.md` desktop table
   - Add section to `profiles/README.md`
   - Update CI workflow in `.github/workflows/flake-check.yml`

5. **Test your changes**:
   ```bash
   nix flake check
   nix build .#nixosConfigurations.<desktop>-workstation.config.system.build.toplevel
   ```

### Code Style

- Use 2 spaces for indentation
- Follow existing naming conventions
- Add comments explaining non-obvious configurations
- Use `lib.mkDefault` for values that should be easily overridable
- Keep modules focused and composable

### Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-improvement`)
3. Make your changes
4. Test with `nix flake check`
5. Commit with clear messages
6. Push to your fork
7. Open a Pull Request with a description of changes

### What We're Looking For

**High Priority:**
- Bug fixes
- Documentation improvements
- New desktop environment support
- Security enhancements

**Medium Priority:**
- New modules (gaming, multimedia, etc.)
- Home Manager configuration examples
- Helper scripts

**Nice to Have:**
- Performance optimizations
- Additional hardware support
- Alternative init systems

## Questions?

Open an issue for discussion before starting major changes.

## License

By contributing, you agree that your contributions will be licensed under the same license as this project.
