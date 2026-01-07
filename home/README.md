# Home Manager configs

Put per-user Home Manager configs in this folder.

Example:

- `home/hunter.nix` is wired up by `machines/example-machine.nix` as the
  template for a “Home Manager does everything” setup.

If you create a new machine or a new user, add another file here and point
`home-manager.users.<name>` to it.
