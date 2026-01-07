{ config, pkgs, lib, ... }:
{
  # Development tools and language stacks: provide common toolchains and
  # developer utilities at the system level. For per-user toolchain
  # management prefer Home Manager or user-level tooling.
  environment.systemPackages = with pkgs; [
    # Language Runtimes
    python3
    nodejs_22
    pnpm
    bun
    go
    rustup
    
    # Build Tools
    cmake
    pkg-config
    gnumake
    gcc
    
    # Code Quality & Formatters
    shellcheck shfmt
    black ruff
    prettier
    eslint_d
    stylua
    
    # Version Control Enhancements
    lazygit      # Git TUI
    difftastic   # Better diff tool
    
    # Database Tools
    sqlite       # SQLite CLI and library
  ];

  # Optionally set rustup default toolchain to stable on first login by
  # running a oneshot user service; this is a convenience and can be
  # removed if you prefer manual rustup management.
  systemd.user.services.rustup-default = {
    description = "Set rustup default toolchain to stable";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -lc 'rustup default stable'";
      Type = "oneshot";
    };
  };
}
