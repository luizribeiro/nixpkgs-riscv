# nixpkgs-riscv

This is a collection of packages and overlays which make it possible to
compile and run NixOS on RISC-V hardware.

The idea is to turn these into PRs into the `nixpkgs` repo. But using this
flake allows you to use these changes while they haven't landed on
the main repo.

As of 04/07/2022, only the StarFive VisionFive V1 SBC is supported.

## Using with flakes

The flake no this repository exposes the following outputs:

1. `nixpkgs-riscv.overlays.default`: the collection of overlays with fixes
   for building many packages. Includes fixes for both RISC-V targets and
   hosts.
2. `nixpkgs-riscv.nixosModules.sd-image-riscv64-visionfive`: a module
   which enables building of SD images for the VisionFive SBC.

See [`example/flake.nix`](example/flake.nix) for a simple example of how
to build a NixOS image with this.

In order to build that example, run:

```
nix build .\#nixosConfigurations.example.config.system.build.sdImage
```

This will create a image file under the `result/` directory which should
be flashed into an SD card.

## TODO

* Example of how to use this without flakes
* Better instructions on flashing bootloader to visionfive
