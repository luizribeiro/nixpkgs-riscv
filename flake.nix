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
      };

      packages = forAllSystems (system: import ./pkgs {
        pkgs = import nixpkgs { inherit system; };
      });

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

    };
}
