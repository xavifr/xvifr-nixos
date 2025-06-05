{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
   (pkgs.callPackage "${builtins.fetchTarball "https://github.com/xavifr/uping/flake.nix" { }}/pkgs/uping.nix" { })
  ];
}

