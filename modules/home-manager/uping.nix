{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.uping;

  # Fetch the uping repository from GitHub (using latest commit hash)
  # To update: get the latest commit hash from https://github.com/xavifr/uping/commits/main
  # and update both the URL and sha256 hash
  upingSrc = builtins.fetchTarball {
    url = "https://github.com/xavifr/uping/archive/8cef5a4f0af838498be669bed1c6bf5f9e48694f.tar.gz";
    sha256 = "0arqikz5b9hmw3nyjwfz53gr0l1815b5xk3c04jv7kdgmd5q83q1";
  };

  # Import the uping flake
  upingFlake = import "${upingSrc}/flake.nix";

  # Prepare the inputs that the flake expects
  inputs = {
    nixpkgs = {
      lib = pkgs.lib;
      legacyPackages.${pkgs.system} = pkgs;
    };
  };

  # Evaluate the flake outputs function with a fixed-point to resolve self-reference
  upingOutputs = lib.fix (self: upingFlake.outputs (inputs // { inherit self; }));

  # Get the uping package
  upingPackage = upingOutputs.packages.${pkgs.system}.default;
in
{
  options.modules.uping = {
    enable = mkEnableOption "UPing";
  };

  config = mkIf cfg.enable {
    home.packages = [ upingPackage ];
  };
}
