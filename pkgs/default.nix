# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  inherit lib

  # example = pkgs.callPackage ./example { };
  cursor = pkgs.callPackage ./cursor-overlay.nix { pkgs = pkgs };
}
