# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  example = pkgs.callPackage ./example { };
  code-cursor = pkgs.callPackage ./code-cursor.nix { };
  #  anycubic-slicer = pkgs.callPackage ./anycubic-slicer.nix { };
  gemini-cli = pkgs.callPackage ./gemini-cli.nix { };

}
