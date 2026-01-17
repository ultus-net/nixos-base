{ config, pkgs, lib, ... }:

let
  cfg = config.pince;
in {
  options.pince = {
    enable = lib.mkEnableOption "Install PINCE (AppImage) as a system package";
    version = lib.mkOption {
      type = lib.types.str;
      default = "v0.4.4";
      description = "PINCE release tag to download from GitHub (e.g. v0.4.4).";
    };
  };

  config = lib.mkIf cfg.enable {
    # Build a minimal package that downloads the official AppImage at
    # runtime of the build and places a small wrapper in $out/bin/pince.
    environment.systemPackages = with pkgs; [ (runCommand "pince-appimage" { } ''
      mkdir -p "$out/bin"
      url="https://github.com/korcankaraokcu/PINCE/releases/download/${cfg.version}/PINCE-x86_64.AppImage"
      echo "Downloading ${url}"
      curl -L -s -o "$out/PINCE.AppImage" "$url"
      chmod +x "$out/PINCE.AppImage"

      cat > "$out/bin/pince" <<'EOF'
#!${pkgs.stdenv.shell}
exec "$out/PINCE.AppImage" "$@"
EOF
      chmod +x "$out/bin/pince"
    '') ];
  };
}
