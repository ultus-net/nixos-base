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

GC / generation retention
-------------------------
The machine master config (`machines/configuration.nix`) includes a weekly
systemd timer that:

- keeps the last **3** system generations (so rollbacks are still possible)
- runs `nix-collect-garbage --delete-older-than 14d` to remove older store paths

This is the default retention policy for machines; you can override it per
machine by replacing/disabled the unit.

OpenSSH hardening
-----------------
OpenSSH is enabled by default to ease initial bring-up, but it’s configured
with safe defaults:

- password authentication disabled
- keyboard-interactive authentication disabled
- root login disabled

Override these per-machine if you need a different behavior.

Override examples
-----------------

Temporarily allow SSH password login for an install session (not recommended
long-term):

```nix
services.openssh.settings.PasswordAuthentication = true;
services.openssh.settings.KbdInteractiveAuthentication = true;
```

Change retention policy (example: keep 5 generations and keep store paths for
30 days):

```nix
systemd.services.nixos-gc-keep-generations.serviceConfig.ExecStart = lib.mkForce ''
  /bin/sh -e -c '\
    PROFILE=/nix/var/nix/profiles/system; \
    KEEP=5; \
    GENS=$(nix-env --list-generations --profile "$PROFILE" | awk '\''/^[[:space:]]*[0-9]+/{gsub("\\*","",$1); print $1}'\'' | sort -n || true); \
    if [ -n "$GENS" ]; then \
      MAX=$(echo "$GENS" | tail -n1); \
      if [ "$MAX" -gt "$KEEP" ]; then \
        THRESH=$((MAX - KEEP)); \
        nix-env --profile "$PROFILE" --delete-generations "1-$THRESH" || true; \
      fi; \
    fi; \
    nix-collect-garbage --delete-older-than 30d || true'
'';
```

Users
-----
Centralized user creation lives in `modules/common-users.nix`. You can
declare multiple users by setting `machines.users` in a machine file; the
format matches the NixOS `users.users` attribute set.
