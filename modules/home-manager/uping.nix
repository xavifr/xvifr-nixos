{
  lib,
  pkgs,
  ...
}:
let
  # Fetch and import the uping flake directly
  upingFlake = import "${
    builtins.fetchTarball {
      url = "https://github.com/xavifr/uping/archive/e9ffbfda0116b60ba7a22ecbe9fa6b1a367d0ec6.tar.gz";
      sha256 = "0arqikz5b9hmw3nyjwfz53gr0l1815b5xk3c04jv7kdgmd5q83q1";
    }
  }/flake.nix";

  # Evaluate the flake outputs with nixpkgs input
  upingOutputs = lib.fix (
    self:
    upingFlake.outputs {
      inherit self;
      nixpkgs = {
        lib = pkgs.lib;
        legacyPackages.${pkgs.stdenv.hostPlatform.system} = pkgs;
      };
    }
  );
in
{
  home.packages = [ upingOutputs.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
