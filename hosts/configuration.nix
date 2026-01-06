/* DEPRECATED
   The master configuration moved to `machines/configuration.nix` when the
   repository was reorganized to separate desktop profiles (`profiles/`) and
   machine deployments (`machines/`).

   If you are installing onto a device, use the example machine template at
   `machines/example-machine.nix` which composes `machines/configuration.nix`
   with a `profiles/*` file.
*/

{ config, pkgs, lib, ... }:
{
  # This file is intentionally left as a placeholder for backwards
  # compatibility. Please migrate callers to `machines/configuration.nix`.
}
