{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.uping;

  # Fetch the uping repository
  upingSrc = builtins.fetchTarball {
    url = "https://github.com/xavifr/uping/archive/refs/tags/v3.0.0.tar.gz";
    sha256 = "1yr0f3vs3ix6ablv7r000h0pykb7kqlz39b9iph6acvri74ghvis";
  };

  # Fetch flake-utils
  flake-utils = builtins.fetchTarball {
    url = "https://github.com/numtide/flake-utils/archive/main.tar.gz";
  };

  # Import the uping flake
  upingFlake = import "${upingSrc}/flake.nix";

  # Prepare the inputs that the flake expects
  inputs = {
    nixpkgs = {
      lib = pkgs.lib;
      legacyPackages.${pkgs.system} = pkgs;
    };
    flake-utils = import flake-utils;
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
