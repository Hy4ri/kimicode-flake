{
  description = "Kimi Code — AI-powered coding assistant CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
  in {
    packages = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      kimi-code = pkgs.callPackage ./package.nix {};
      default = self.packages.${system}.kimi-code;
    });

    overlays.default = final: _prev: {
      kimi-code = final.callPackage ./package.nix {};
    };
  };
}
