{ config, pkgs, lib, ... }:
{
  # Module to centralize common user creation across machines. It exposes
  # `machines.users` as an attribute set where each key is a username and the
  # value is a `users.users.<name>` style attribute set (same shape as
  # NixOS `users.users`). This allows machine files to declare multiple users
  # and their `openssh.authorizedKeys.keys` safely.

  options = {
    machines.users = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {
        csh = {
          isNormalUser = true;
          extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
          createHome = true;
          shell = pkgs.bashInteractive;
          # authorizedKeys example (empty by default). Provide as a list of
          # SSH public keys if you want them pre-installed.
          openssh = { authorizedKeys = { keys = []; }; };
        };
      };
      description = "Attribute set of users to create on machines. Keys are usernames.";
    };
  };

  config = {
    # Merge provided machines.users into the system users.users attribute.
    # Use mkDefault so machine files can override users.users if needed.
    users.users = lib.mkMerge [
      (lib.mkDefault config.machines.users)
    ];
  };
}
