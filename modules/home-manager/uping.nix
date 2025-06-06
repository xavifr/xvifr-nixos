{
  lib,
  pkgs,
  ...
}:
let
  # Fetch and import the uping flake directly
  upingFlake = import "${
    builtins.fetchTarball {
      url = "https://github.com/xavifr/uping/archive/8cef5a4f0af838498be669bed1c6bf5f9e48694f.tar.gz";
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
        legacyPackages.${pkgs.system} = pkgs;
      };
    }
  );
in
{
  home.packages = [ upingOutputs.packages.${pkgs.system}.default ];
}
