# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications =
    final: prev:
    let
      inherit (prev) lib;
    in
    {
      # example = prev.example.overrideAttrs (oldAttrs: rec {
      # ...
      # });

      # code-cursor = prev.code-cursor.overrideAttrs (
      #   import ./code-cursor.nix {
      #     inherit lib stdenvNoCC;
      #     inherit (prev) fetchurl appimageTools rsync;
      #   }
      # );

      openssh-no-checkperm = prev.openssh.overrideAttrs (
        import ./ssh-no-perm.nix {
          inherit lib;
          patchFile = ../patches/openssh-no-checkperm.patch;
        }
      );

      # gemini-cli overlay disabled; using custom package in pkgs instead
      # gemini-cli = prev.gemini-cli.overrideAttrs (
      #   import ./gemini-cli.nix {
      #     inherit (prev) lib fetchurl fetchFromGitHub fetchNpmDeps;
      #   }
      # );

      #ghostty = prev.ghostty.overrideAttrs (
      #  import ./ghostty.nix {
      #    inherit (prev) fetchFromGitHub;
      #  }
      #);

    };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
    master = import inputs.nixpkgs-master {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
