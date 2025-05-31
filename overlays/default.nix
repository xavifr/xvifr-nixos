# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: let
    inherit (prev) lib stdenvNoCC;
  in {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    cursor = prev.cursor.overrideAttrs (oldAttrs: rec {
      version = "0.50.7";
      pname = oldAttrs.pname;

      # Ensure rsync is available during the installPhase (and other original nativeBuildInputs)
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ (
        lib.optionals stdenvNoCC.hostPlatform.isLinux [ prev.rsync ]
      );

      cursorRawAppImageSource = prev.fetchurl {
        url = "https://downloads.cursor.com/production/02270c8441bdc4b2fdbc30e6f470a589ec78d60d/linux/x64/Cursor-0.50.7-x86_64.AppImage";
        sha256 = "ukYsLtwnM+yjeDX24Bls7c0MhxeMGOemdQFF6t8Mqvg=";
      };

      customWrappedAppimage = prev.appimageTools.wrapType2 {
        inherit pname version;
        src = cursorRawAppImageSource;
        extraPkgs = pkgsFHS: (with pkgsFHS; [
          git
          #openssh-no-checkperm
          # rsync is not needed here for the FHS env if only installPhase uses it.
          # However, having it here doesn't hurt if Cursor itself might ever call rsync.
          # For this specific error, nativeBuildInputs is the fix.
        ]);
        # If you want to re-add SSH_AUTH_SOCK forwarding for the FHS env (runtime):
        # extraMakeWrapperArgs = [ "--inherit-env" "SSH_AUTH_SOCK" ];
      };

      customAppimageContents = prev.appimageTools.extractType2 {
        inherit pname version;
        src = cursorRawAppImageSource;
      };

      src = if stdenvNoCC.hostPlatform.isLinux then customWrappedAppimage else cursorRawAppImageSource;

      installPhase =
        (lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
          runHook preInstall
          mkdir -p $out/
          cp -r bin $out/bin
          rsync -a -q ${customAppimageContents}/usr/share $out/ --exclude "*.so" # rsync is used here
          substituteInPlace $out/share/applications/${pname}.desktop \
            --replace-fail "/usr/share/${pname}/${pname}" "$out/bin/${pname}"
          
          # If you want to re-add SSH_AUTH_SOCK for the outer wrapper (runtime):
          # wrapProgram $out/bin/${pname} \
          #   --inherit-env SSH_AUTH_SOCK \ 
          #   --add-flags "--update=false" \
          #   --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}} --no-update" \
          #   --add-flags ""
          #
          # Original simpler wrapProgram if not handling SSH_AUTH_SOCK here:
          wrapProgram $out/bin/${pname} \
            --add-flags "--update=false" \
            --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}} --no-update" \
            --add-flags "" # Assuming default commandLineArgs

        runHook postInstall
        '') +
        (lib.optionalString stdenvNoCC.hostPlatform.isDarwin oldAttrs.installPhase);

      passthru = oldAttrs.passthru // {
        sources = (oldAttrs.passthru.sources or {}) // {
          ${stdenvNoCC.hostPlatform.system} = cursorRawAppImageSource;
        };
      };
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
