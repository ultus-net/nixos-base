README — machines/
===================

Purpose
-------
This directory contains machine deployment entries and a master machine
configuration (`machines/configuration.nix`). Machine files should compose the
master defaults with a `profiles/<profile>.nix` entry and, when installing,
an installer-generated `hardware-configuration.nix`.

Note about moved modules
------------------------
Some helper modules that previously lived under `machines/` have been moved to
`modules/` to make them reusable across profiles and machines. The removed
files are:

- `machines/common-users.nix` (now `modules/common-users.nix`)
- `machines/zram.nix` (now `modules/zram.nix`)

See `modules/` for the canonical, reusable module implementations. Example
machine files import them via `../modules/common-users.nix` and
`../modules/zram.nix`.

Quick template
--------------

Example `machines/my-pc.nix`:

```nix
{ config, pkgs, lib, ... }:
{
  # Import the machine master defaults (./configuration.nix), the chosen
  # desktop profile (../profiles/cosmic.nix), and the shared users module
  # (../modules/common-users.nix).
  imports = [ ./configuration.nix ../profiles/cosmic.nix ../modules/common-users.nix ];
  networking.hostName = "my-pc";
  # Import hardware-configuration.nix generated during install:
  # imports = [ ./configuration.nix ../profiles/cosmic.nix ./hardware-configuration.nix ];
}
```

Zram tuning
-----------
The zram module is provided at `modules/zram.nix` and exposes `machines.zram.*`
options. By default zram size is computed as min(total RAM / 2,
`machines.zram.maxSize`). You can override explicitly with `machines.zram.size`
or disable the heuristic with `machines.zram.enableAutoSize = false`.

Users
-----
Centralized user creation lives in `modules/common-users.nix`. You can
declare multiple users by setting `machines.users` in a machine file; the
format matches the NixOS `users.users` attribute set.
