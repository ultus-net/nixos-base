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

## Keys added from COSMIC export (what was mapped into `home/hunter.nix`)

When exporting COSMIC settings and mapping them into `home/hunter.nix`, the
following per-component keys were added so the desktop state is reproducible
from Home Manager. These are stored under `xdg.configFile` in the example
`home/hunter.nix` and as managed `home.file` entries for `monitors.xml` and
the custom wallpaper.

- `cosmic/com.system76.CosmicComp/v1/xkb_config` — XKB layout (`nz`) and model
- `cosmic/com.system76.CosmicComp/v1/autotile` and `autotile_behavior`
- `cosmic/com.system76.CosmicComp/v1/focus_follows_cursor`
- `cosmic/com.system76.CosmicComp/v1/active_hint`
- `cosmic/com.system76.CosmicTheme.Mode/v1/is_dark` — enable dark theme
- `cosmic/com.system76.CosmicPanel/v1/entries` — panel applet ordering
- `cosmic/com.system76.CosmicPanel.Panel/v1/plugins_center` — center plugins
- `cosmic/com.system76.CosmicPanel.Panel/v1/plugins_wings` — left/right wings
- `cosmic/com.system76.CosmicPanel.Dock/v1/size` — dock size (`M`)
- `cosmic/com.system76.CosmicPanel.Dock/v1/anchor` — dock anchor (`Bottom`)
- `cosmic/com.system76.CosmicPanel.Dock/v1/autohide` — autohide timings
- `cosmic/com.system76.CosmicPanel.Dock/v1/opacity` — dock opacity (0.5)
- `cosmic/com.system76.CosmicTk/v1/interface_density` — `Compact`
- `cosmic/com.system76.CosmicAppletTime/v1/show_date_in_top_panel`
- `cosmic/com.system76.CosmicAppletTime/v1/military_time`
- `cosmic/com.system76.CosmicBackground/v1/default` — global wallpaper rotation
- `cosmic/com.system76.CosmicBackground/v1/output.HDMI-A-4` — per-output wallpaper
- `home.file.".config/monitors.xml"` — saved monitor layout (two displays)
- `home.file.".wallpapers/nix-d-nord-1080p.png"` — repo-provided wallpaper file

Keep in mind:
- `xdg.configFile` entries write JSON-like/text files for COSMIC components;
  if you prefer strictly declarative options instead of file writes, translate
  these values into a custom Nix module or `home-manager` options where
  available.

