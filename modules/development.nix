{ config, pkgs, lib, ... }:
{
  # Language stacks
  environment.systemPackages = with pkgs; [
    python3
    nodejs_22
    pnpm
    bun
    go
    rustup
    cargo
    rustc
    cmake
    pkg-config
    shellcheck shfmt
    black ruff
    prettier
    eslint_d
    stylua
  ];

  # Rust via rustup default stable on first login (optional)
  systemd.user.services.rustup-default = {
    description = "Set rustup default toolchain to stable";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -lc 'rustup default stable'";
      Type = "oneshot";
    };
  };
}
