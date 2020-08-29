{
  description = "A CLI tool to update a duckdns DDNS entry";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.03";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        commonBuildInputs = with pkgs; [ pkg-config openssl ];
        duckdns-update = pkgs.rustPlatform.buildRustPackage rec {
          pname = "duckdns-update";
          version = "0.1.0";
          src = self;
          cargoSha256 = "fB46IkoN+kKm0jwEp+nSw92t31pluLJ5ZPKOiRMB5wU=";
          builtInputs = commonBuildInputs;
        };
      in {
        devShell = pkgs.mkShell {
          buildInputs = [ pkgs.rustfmt pkgs.cargo ] ++ commonBuildInputs;
          shellHook = ''
            export RUST_BACKTRACE=full
          '';
        };
        defaultPackage = duckdns-update;
      });
}
