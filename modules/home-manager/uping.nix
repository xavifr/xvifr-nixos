{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  home.packages = with pkgs; [
   (pkgs.callPackage "${inputs.uping}/pkgs/uping.nix" { })
  ];
}

