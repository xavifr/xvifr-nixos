# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  inherit lib

  # example = pkgs.callPackage ./example { };
  cursor = pkgs.callPackage ./cursor-overlay.nix { 
    newCursorVersion = "0.50.7";
    newCursorUrl = "https://downloads.cursor.com/production/02270c8441bdc4b2fdbc30e6f470a589ec78d60d/linux/x64/Cursor-0.50.7-x86_64.AppImage";
    newCursorSha256 = "ukYsLtwnM+yjeDX24Bls7c0MhxeMGOemdQFF6t8Mqvg=";
    # cursorPname = "code-cursor"; # Optional, defaults to "code-cursor" in the overlay file };
}
