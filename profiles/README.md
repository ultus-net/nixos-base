README — profiles/
===================

Purpose
-------
This directory holds desktop "profiles": small NixOS module fragments that
describe a desktop environment (COSMIC, GNOME, KDE), related packages, and
profile-level features (QoL, developer packages, desktop services). Profiles
do NOT include machine-specific settings like `networking.hostName`,
`fileSystems`, or `boot.loader` configurations.

Usage
-----
- To use a profile when deploying to hardware, import it from a `machines/`
  entry. For example:

  ```nix
  imports = [ ./configuration.nix ../profiles/cosmic.nix ../modules/common-users.nix ];
  networking.hostName = "my-pc";
  ```

- Profiles are intentionally shareable: you can reuse the same profile across
  many machines.

Notes
-----
- Keep profiles focused on desktop-level concerns: session managers,
  desktop packages, and per-user Home Manager defaults. Avoid embedding
  disk UUIDs, LUKS settings, or bootloader device paths here.
