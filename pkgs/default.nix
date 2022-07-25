{ pkgs }:

with pkgs;

let
  ubootVisionFive = buildUBoot {
    version = "2022.04";

    src = fetchFromGitHub {
      owner = "NickCao";
      repo = "u-boot-starfive";
      rev = "ac75aa54020412a83b61dad46c5ea15e7f9f525c";
      sha256 = "1idh5k1479znp24rrfa0ikgk6iv5h80zscqhi6yv5ah4czia3ip3";
    };

    defconfig = "starfive_jh7100_visionfive_smode_defconfig";
    extraMeta.platforms = [ "riscv64-linux" ];
    filesToInstall = [ "u-boot.bin" "u-boot.dtb" ];
  };
in
rec {
  linux_visionfive = callPackage ./linux-visionfive.nix rec {
    kernel = linuxKernel.kernels.linux_5_18;
    kernelPatches = kernel.kernelPatches;
  };
  linuxPackages_visionfive = recurseIntoAttrs
    (linuxPackagesFor linux_visionfive);
  opensbiMaster = callPackage ./opensbi-master.nix { };
  firmware-visionfive = callPackage ./firmware-visionfive.nix {
    opensbi = opensbiMaster.override {
      withPayload = "${ubootVisionFive}/u-boot.bin";
      withFDT = "${ubootVisionFive}/u-boot.dtb";
    };
  };
}
