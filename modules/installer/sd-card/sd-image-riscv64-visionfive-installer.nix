{ nixpkgs }:

{
  imports = [
    "${nixpkgs}/nixos/modules/profiles/installation-device.nix"
    ./sd-image-riscv64-visionfive.nix
  ];

  # the installation media is also the installation target,
  # so we don't want to provide the installation configuration.nix.
  installer.cloneConfig = false;
}
