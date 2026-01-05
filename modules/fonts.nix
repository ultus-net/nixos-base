{ config, pkgs, lib, ... }:
{
  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
      noto-fonts-emoji
    ];
  };
}
