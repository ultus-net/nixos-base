# nixos-base
CI
--

This repository includes a GitHub Actions workflow at `.github/workflows/flake-check.yml`
that validates the flakes on push and pull requests to `main`. The workflow installs
Nix and runs `nix flake show` for the top-level flake and the nested GNOME flake to
catch evaluation errors and deprecations early.

Run the same checks locally with:

```bash
# show top-level flake outputs (will fail if flake evaluation errors)
nix --extra-experimental-features 'nix-command flakes' flake show .

# show the nested GNOME flake outputs
nix --extra-experimental-features 'nix-command flakes' flake show ./flakes/gnome
```

- `modules/` — small, focused NixOS module fragments (desktop support, common packages,
	development, QoL, etc.). These are intended to be imported into host-specific
	configurations.
- `hosts/` — example host modules that compose the fragments in `modules/`.
- `flake.nix` — exports dev shells, a Home Manager module and an example NixOS
	configuration called `cosmic-workstation`.

Multiple flakes
----------------

This repo supports both a single top-level flake and additional nested flakes
for per-desktop workflows. For example, there's a dedicated GNOME flake at
`./flakes/gnome/flake.nix` exposing `gnome-workstation`. You can reference it like
`./flakes/gnome#gnome-workstation` when building or switching.

Helper script
-------------

Use `scripts/switch-host.sh` to build or switch to a host. The script defaults
to the top-level `cosmic-workstation` configuration when no argument is
provided. Examples:

```bash
# Build the default (cosmic) host locally (non-root)
./scripts/switch-host.sh

# Build / switch to GNOME host via the nested flake (switch requires root)
sudo ./scripts/switch-host.sh ./flakes/gnome#gnome-workstation
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

The pattern used here is composition: each host file under `hosts/` imports the
desktop-agnostic pieces plus a small desktop module (for example, `modules/kde.nix`
or `modules/cosmic.nix`). To use or build a particular host configuration from
the flake you can reference its name from the flake outputs.

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

Notes:
- Add your own host by creating a file under `hosts/` that `imports` the
	fragments you want. Use `common-packages.nix` for a desktop-agnostic set of
	utilities and add `kde.nix`, `cosmic.nix`, or other desktop modules as needed.
- The flake already provides `homeManagerModules` and a `templates/home`
	example you can adapt for user dotfiles.
