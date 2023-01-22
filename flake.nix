{
  description = "A CLI tool to update a duckdns DDNS entry";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    let
      withPkgs = pkgs:
        let
          commonBuildInputs = with pkgs; [ pkg-config openssl ];
          duckdns-update = pkgs.rustPlatform.buildRustPackage rec {
            pname = "duckdns-update";
            version = "0.1.0";
            src = self;
            cargoSha256 = "6zAay+LGSJ0RcQxMQ55sogQngkSyPtJI0SOpAykV6zo=";
            builtInputs = commonBuildInputs;
          };
        in {
          devShells.default = pkgs.mkShell {
            buildInputs = [ pkgs.rustfmt pkgs.cargo ] ++ commonBuildInputs;
            shellHook = ''
              export RUST_BACKTRACE=full
            '';
          };
          packages.default = duckdns-update;
        };
    in (flake-utils.lib.eachSystem
      (flake-utils.lib.defaultSystems ++ [ "armv7l-linux" ])
      (system: withPkgs (import nixpkgs { inherit system; }))) // {
        overlays.default = final: prev: {
          duckdns-update = (withPkgs prev).packages.default;
        };
      };
}
