{ config, pkgs, lib, ... }:
# Example Home Manager snippet to install common gaming Flatpaks and helpers.
# Drop this into your Home Manager configuration (e.g. import it from
# `~/.config/nixpkgs/home.nix`) and run `home-manager switch` to apply.

let
  flathub = "https://flathub.org/repo/flathub.flatpakrepo";
in
{
  # Activation script: adds Flathub remote if missing and installs a small
  # set of user Flatpaks. This is intentionally conservative and idempotent.
  home.activation.install-gaming-flatpaks = {
    text = ''
      set -euo pipefail

      # Ensure flatpak remote exists
      if ! flatpak remote-list | grep -q "^flathub\s"; then
        echo "Adding Flathub remote..."
        flatpak remote-add --if-not-exists flathub ${flathub}
      fi

      # ProtonTricks (wrapper for protontricks inside Flatpak)
      echo "Installing ProtonTricks (Flatpak)..."
      flatpak install --user -y com.github.Matoking.protontricks || true

      # ProtonUp-Qt: uncomment and set the correct Flatpak ID if you want it
      # (ID varies; check Flathub or use the system package if available).
      # Example placeholder:
      # flatpak install --user -y <PROTONUPQT_APP_ID> || true

      # Decky Loader / EmuDeck / other Game UX tools are often AppImages or
      # installed via user scripts — prefer explicit user install or a tiny
      # helper script rather than forcing system-wide installs here.
    '';
  };

  # Optional: add some convenience aliases in the user's bash/zshrc via
  # `home.sessionCommands` so users can run common tools easily.
  home.sessionCommands = lib.mkAfter [ ''
    # Short aliases for flatpak-run wrappers
    alias protontricks='flatpak run com.github.Matoking.protontricks'
  '' ];
}
