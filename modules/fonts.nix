{ config, pkgs, lib, ... }:
{
  # Fonts module: enable fontconfig and provide a small curated list of
  # fonts (including patched Nerd Fonts for icons and programming fonts).
  fonts = {
    fontconfig.enable = true; # ensure fontconfig is enabled for font rendering
    packages = with pkgs; [
      # Nerd fonts provide icon glyphs useful in terminals and prompts
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
      noto-fonts-emoji # emoji font for consistent emoji rendering
    ];
  };
}
