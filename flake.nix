{
  description = "RISC-V nixpkgs overlays and patches";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs } @ inputs:
    let
      systems = [
        "riscv64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    rec {
      nixosModules = {
        sd-image-riscv64-visionfive-installer = import
          ./modules/installer/sd-card/sd-image-riscv64-visionfive-installer.nix
          {
            inherit nixpkgs;
          };
      };

      overlays.default = final: prev: {
        riscv = packages.${prev.system};
      } // (
        if prev.stdenv.hostPlatform.isRiscV
        then (import ./overlays/host.nix final prev)
        else { }
      );

      packages = forAllSystems (system: import ./pkgs {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            overlays.default
          ];
        };
      });

      # an example which builds a riscv64 image natively from a riscv64 host.
      # note that this can be done from a x86_64 host using binfmt.
      # build this image with:
      #   nix build .\#nixosConfigurations.example.config.system.build.sdImage
      nixosConfigurations.example = nixpkgs.lib.nixosSystem {
        system = "riscv64-linux";
        specialArgs = inputs;
        modules = [
          {
            nixpkgs.overlays = [
              overlays.default
            ];
          }
          nixosModules.sd-image-riscv64-visionfive-installer
          ./example/configuration.nix
        ];
      };

      # an example which uses cross-compilation from x86_64-linux to riscv64
      # build this image with:
      #   nix build .\#nixosConfigurations.example.config.system.build.sdImage
      nixosConfigurations.example-cross = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          {
            nixpkgs.overlays = [
              overlays.default
            ];

            nixpkgs.crossSystem = {
              config = "riscv64-unknown-linux-gnu";
              system = "riscv64-linux";
            };
          }
          nixosModules.sd-image-riscv64-visionfive-installer
          ./example/configuration.nix
        ];
      };
    };
}
