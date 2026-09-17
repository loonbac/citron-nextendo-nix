# Citron Nextendo for Nix

Small Nix flake for the official Linux builds of
[`NextendoNetwork/citron-nextendo`](https://github.com/NextendoNetwork/citron-nextendo).
It packages the upstream AppImages; it does not fork or compile the emulator.

## Install

Citron Nextendo is not currently part of nixpkgs. Install it directly from
this flake.

Generic x86-64 or AArch64 package:

```bash
nix profile install github:loonbac/citron-nextendo-nix#citron-nextendo
```

For an x86-64-v3 compatible CPU:

```bash
nix profile install github:loonbac/citron-nextendo-nix#citron-nextendo-v3
```

## Run without installing

Generic x86-64 or AArch64 package:

```bash
nix run github:loonbac/citron-nextendo-nix
```

For an x86-64-v3 compatible CPU:

```bash
nix run github:loonbac/citron-nextendo-nix#citron-nextendo-v3
```

## NixOS module

```nix
{
  inputs.citron-nextendo.url = "github:loonbac/citron-nextendo-nix";

  outputs = { nixpkgs, citron-nextendo, ... }: {
    nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        citron-nextendo.nixosModules.default
        { programs.citron-nextendo.enable = true; }
      ];
    };
  };
}
```

To select the optimized package:

```nix
programs.citron-nextendo.package =
  citron-nextendo.packages.x86_64-linux.citron-nextendo-v3;
```

The module installs the desktop entry and controller udev rules and enables
FUSE for the AppImage runtime.

## Updates and provenance

Nextendo publishes Linux AppImages under the mutable `nightly-linux` release.
This repository waits for a successful official Linux workflow, verifies the
SHA-256 digests supplied by GitHub, and copies those exact files into an
immutable `linux-<commit>` release. `nix/sources.json` then records those fixed
URLs and hashes.

No source code is modified and no independent Citron build is produced. The
AppImages contain no games, firmware, keys, or Nintendo code.
