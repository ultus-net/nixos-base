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

- Notes:
- Add your own machine by creating a file under `machines/` that `imports`
	`machines/configuration.nix` and the profile you want from `profiles/`.
	Use `common-packages.nix` for a desktop-agnostic set of utilities and add
	`kde.nix`, `cosmic.nix`, or other desktop modules in the profile.
- The flake already provides `homeManagerModules` and a `templates/home`
	example you can adapt for user dotfiles.
