{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-riscv = {
      url = "github:luizribeiro/nixpkgs-riscv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-riscv } @ inputs: {
    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      system = "riscv64-linux";
      specialArgs = inputs;
      modules = [
        {
          nixpkgs.overlays = [
            nixpkgs-riscv.overlays.default
          ];
        }
        nixpkgs-riscv.nixosModules.sd-image-riscv64-visionfive
        ./configuration.nix
      ];
    };
  };
}
