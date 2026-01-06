# nixos-base

![Flake validation](https://github.com/ultus-net/nixos-base/actions/workflows/flake-check.yml/badge.svg)

CI and local validation
-----------------------

This repository includes a GitHub Actions workflow at `.github/workflows/flake-check.yml`
that validates the top-level flake on push and pull requests to `main`. The workflow
installs Nix and runs `nix flake show` plus explicit checks for the `cosmic-workstation`,
`gnome-workstation`, and `kde-workstation` outputs.

Run the same checks locally with one of these approaches:

1) Quick human-readable listing:

```bash
# show top-level flake outputs (will fail if flake evaluation errors)
nix --extra-experimental-features 'nix-command flakes' flake show .
```

2) Machine-checkable JSON (recommended for scripts / CI):

```bash
# dump flake outputs as JSON and verify expected outputs exist
nix --extra-experimental-features 'nix-command flakes' flake show --json . > flake.json
jq '.nixosConfigurations | keys' flake.json
# exit non-zero if missing
jq -e '.nixosConfigurations | has("cosmic-workstation")' flake.json
jq -e '.nixosConfigurations | has("gnome-workstation")' flake.json
jq -e '.nixosConfigurations | has("kde-workstation")' flake.json
```

Note: some versions of the `nix` CLI don't accept a fragment (the `#name` suffix)
directly with `nix flake show` (you may see "unexpected fragment" errors). Use
the JSON approach above or reference the flake via an absolute path if needed.

- `modules/` — small, focused NixOS module fragments (desktop support, common packages,
	development, QoL, etc.). These are intended to be imported into profile or
	machine-specific configurations.
- `profiles/` — example desktop profiles that compose the fragments in `modules/`.
- `machines/` — machine deployment entries that import `machines/configuration.nix`
	and a `profiles/*` file (or `hardware-configuration.nix` produced at install time).
- `flake.nix` — exports dev shells, a Home Manager module and an example NixOS
	configuration called `cosmic-workstation`.

Multiple desktops (single top-level flake)
-----------------------------------------

This repo exposes desktop workstation configurations from the top-level flake.
`cosmic-workstation`, `gnome-workstation`, and `kde-workstation` are available as top-level
outputs so you can reference them like `.#cosmic-workstation`, `.#gnome-workstation`, or `.#kde-workstation`.
This keeps the repository surface area to a single flake and avoids nested
flake duplication.

Refactor & repository layout
----------------------------

Recent refactors split desktop concerns (profiles) from machine deployments.
- `profiles/` contains desktop profiles (COSMIC, GNOME, KDE) — reusable across many machines.
- `machines/` contains machine deployment entries and the master machine defaults in `machines/configuration.nix`.
- `modules/common-users.nix` centralizes per-machine user creation.
- `modules/zram.nix` provides a tunable zram module with an automatic sizing heuristic and compression option.
- Old `hosts/` files were archived to `hosts-deprecated/` during the migration.
  
Note about moved files
----------------------
During a recent refactor some helper modules were moved out of `machines/`
and into `modules/` to make them reusable across profiles and machines. The
following files were moved and the old copies removed:

- `machines/common-users.nix` -> `modules/common-users.nix`
- `machines/zram.nix` -> `modules/zram.nix`

Machine examples and docs now import these from `../modules/...` (see
`machines/example-machine.nix` for an example). This change doesn't affect
the option names exposed by the modules — options still live in the
`machines.*` namespace (for example `machines.zram.*` and `machines.users`).

The CI validation was updated to ensure `profiles/` and `machines/` exist and
to run `./scripts/validate-hosts-home-manager.sh` which checks that profiles
and deployment entries import the Home Manager module appropriately.

Using unstable
--------------

This flake uses the `nixpkgs-unstable` input by default to pick up newer
packages and desktop features. If you prefer a stable channel for a given
machine, create a machine entry that pins `nixpkgs` locally or override the
flake input when building/installing.

Snapshot retention
------------------

To avoid accumulating old generations and GC roots on devices, the machine
master sets Nix garbage collection options that delete items older than 14
days by default. You can override this in a machine file by setting
`nix.gc.options` or disabling `nix.gc.automatic` if you prefer manual control.

Helper script
-------------

Use `scripts/switch-host.sh` to build or switch to a host. The script defaults
to the top-level `cosmic-workstation` configuration when no argument is
provided. Examples:

```bash
# Build the default (cosmic) host locally (non-root)
./scripts/switch-host.sh

# Build / switch to GNOME host via the top-level flake (switch requires root)
sudo ./scripts/switch-host.sh .#gnome-workstation

# Build / switch to KDE host via the top-level flake (switch requires root)
sudo ./scripts/switch-host.sh .#kde-workstation
```

CI
--

There's a GitHub Actions workflow at `.github/workflows/flake-check.yml` that
evaluates the top-level flake and the GNOME flake on push and PRs to `main`.
It simply installs Nix and runs `nix flake show` to catch evaluation errors early.

Installation
------------

See `INSTALL.md` for a step-by-step installation and deployment guide (UEFI and
LUKS examples) describing how to install this flake on a fresh VM or device.

## Switching desktops & machines (quick start)

The pattern used here is composition: desktop profiles live under `profiles/` and
contain desktop-agnostic pieces plus a small desktop module (for example,
`modules/kde.nix` or `modules/cosmic.nix`). To deploy to a physical device,
create a `machines/<name>.nix` entry that imports `machines/configuration.nix`
and the chosen `profiles/<profile>.nix` file. The flake still exposes the
desktop profiles as top-level NixOS outputs for convenience.

Examples:


Build and switch to the `cosmic-workstation` configuration defined by this flake:

```bash
sudo nixos-rebuild switch --flake .#cosmic-workstation
```

Alternatively, to build or test the KDE example host locally (no switch):

```bash
nix build .#nixosConfigurations.kde-workstation.config.system.build.toplevel
# or
nixos-rebuild build --flake .#kde-workstation
```

- Notes
-----

- Add your own machine by creating a file under `machines/` that `imports`
	`machines/configuration.nix` and the profile you want from `profiles/`.
	Use `modules/common-packages.nix` for a desktop-agnostic set of utilities
	and add `modules/kde.nix`, `modules/cosmic.nix`, or other desktop modules
	in the profile.
- The flake exposes desktop profiles as top-level Nix outputs for convenience
	(so `.#cosmic-workstation` still works). For real device installs it's
	recommended to generate and import an installer-produced
	`hardware-configuration.nix` into a `machines/<name>.nix` entry.
- The flake already provides `homeManagerModules` and a `templates/home`
	example you can adapt for user dotfiles.
