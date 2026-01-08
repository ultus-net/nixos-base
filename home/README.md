# Home Manager Configurations

This directory contains per-user Home Manager configurations. Home Manager manages user-specific packages, dotfiles, and application settings.

## Usage

### With NixOS (Integrated)

When using Home Manager integrated with NixOS (recommended), add this to your machine configuration:

```nix
{ config, pkgs, ... }:
{
  imports = [
    ../modules/home-manager.nix
  ];
  
  # Configure home-manager for your user
  home-manager.users.yourusername = import ../home/yourusername.nix;
}
```

Then rebuild your system:
```bash
sudo nixos-rebuild switch --flake .#your-machine
```

### Standalone (Non-NixOS)

For using Home Manager on non-NixOS systems (macOS, other Linux distros):

1. **First time setup:**
```bash
# Install home-manager
nix run home-manager/master -- init --switch
```

2. **Switch to this flake's configuration:**
```bash
home-manager switch --flake .#yourusername@x86_64-linux
```

Available configurations:
- `hunter@x86_64-linux` - Example user on x86_64 Linux
- Add more in `flake.nix` under `homeConfigurations`

### Creating Your Own Configuration

1. **Copy the template:**
```bash
cp home/hunter.nix home/yourusername.nix
```

2. **Edit your config:**
```nix
{ config, pkgs, lib, ... }:
{
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
  };
  
  # Add your packages
  home.packages = with pkgs; [
    # your tools here
  ];
}
```

3. **Add to flake.nix** (for standalone usage):
```nix
homeConfigurations = {
  "yourusername@x86_64-linux" = mkHomeConfiguration "x86_64-linux" "yourusername" "/home/yourusername";
};
```

## Available Configurations

### `hunter.nix` (Example/Template)
Comprehensive example configuration including:
- Shell setup (bash with starship prompt)
- Git configuration with delta
- Neovim with plugins
- VS Code with extensions
- Modern CLI tools (fzf, zoxide, bat, eza)
- Development LSPs and tooling

## Key Features

### Shell Environment
- **Starship** - Fast, customizable prompt
- **direnv** - Per-directory environments
- **fzf** - Fuzzy finder for files, history, etc.
- **zoxide** - Smarter cd command

### Development Tools
- **Neovim** - Configured with LSP and treesitter
- **VS Code** - Extensions and settings managed
- **Git** - Delta pager, useful aliases
- **LSPs** - TypeScript, Python, Rust, Nix, Markdown

### Quality of Life
- Shell aliases (ls → eza, cat → bat, etc.)
- XDG directories properly configured
- Font configuration
- Dotfile management

## Tips

### Update Home Manager
```bash
# NixOS integrated
sudo nixos-rebuild switch --flake .#your-machine

# Standalone
home-manager switch --flake .#yourusername@x86_64-linux
```

### List Generations
```bash
home-manager generations
```

### Rollback
```bash
# List generations first
home-manager generations

# Switch to a specific generation
/nix/store/xxx-home-manager-generation/activate
```

### Check What Would Change
```bash
# NixOS
nixos-rebuild build --flake .#your-machine
nix store diff-closures /run/current-system ./result

# Standalone
home-manager build --flake .#yourusername@x86_64-linux
```

### Search for Options
```bash
# Search home-manager options
home-manager option <search-term>

# Online documentation
# https://nix-community.github.io/home-manager/options.xhtml
```

## Common Configurations

### Enable Firefox
```nix
programs.firefox = {
  enable = true;
  profiles.default = {
    bookmarks = [ ];
    settings = {
      "browser.startup.homepage" = "https://nixos.org";
    };
  };
};
```

### Enable Alacritty Terminal
```nix
programs.alacritty = {
  enable = true;
  settings = {
    font.size = 12;
    window.opacity = 0.95;
  };
};
```

### Enable tmux
```nix
programs.tmux = {
  enable = true;
  terminal = "screen-256color";
  keyMode = "vi";
  customPaneNavigationAndResize = true;
};
```

## Troubleshooting

### "collision between" errors
Home Manager packages conflict with system packages. Remove the duplicate from either `environment.systemPackages` or `home.packages`.

### Changes not taking effect
Make sure you're switching, not just building:
```bash
home-manager switch --flake .#yourusername@x86_64-linux
```

### Can't find home-manager command
If using standalone, ensure home-manager is installed:
```bash
nix profile install nixpkgs#home-manager
```

## Resources

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Home Manager Options Search](https://mipmip.github.io/home-manager-option-search/)
- [Example Configurations](https://github.com/nix-community/home-manager/tree/master/tests)

## Compatibility Note

Some older Home Manager releases use `programs.*.initExtra` for shell
initialization content while newer releases prefer `programs.*.initContent`.
This repository aims for broad compatibility; if you target a specific
Home Manager version, prefer `initContent` for newer versions and
`initExtra` for older ones. When running into evaluation errors referencing
`initContent`/`initExtra`, align the attribute in your `home/*.nix` to the
Home Manager release you're using.

