{
  description = "NixOS system flake template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs, ... } @ inputs:
    let
      lib = nixpkgs.lib;

      # Every directory under ./hosts becomes a nixosConfiguration named
      # after the directory. Adding a machine = adding a directory,
      # no flake.nix edit needed. bootstrap.sh does exactly that.
      hostNames = lib.attrNames
        (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts));

      forAllSystems = lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
    in
    {
      # No `system` here on purpose: each host's hardware-configuration.nix
      # sets `nixpkgs.hostPlatform` (nixos-generate-config emits it), so
      # x86_64 and aarch64 hosts can live in the same repo.
      nixosConfigurations = lib.genAttrs hostNames (hostname:
        lib.nixosSystem {
          specialArgs = { inherit inputs hostname; };
          modules = [
            ./hosts/${hostname}
            # Modules from flake inputs go here, e.g.:
            # inputs.yeetmouse.nixosModules.default
          ];
        });

      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            packages = [ pkgs.go-task pkgs.lefthook pkgs.nh ];
          };
        });
    };
}
