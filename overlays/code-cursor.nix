{
  lib,
  stdenvNoCC,
  fetchurl,
  appimageTools,
  rsync,
}:

oldAttrs: rec {
  version = "0.50.7";
  pname = oldAttrs.pname;

  # Ensure rsync is available during the installPhase (and other original nativeBuildInputs)
  nativeBuildInputs =
    (oldAttrs.nativeBuildInputs or [ ]) ++ (lib.optionals stdenvNoCC.hostPlatform.isLinux [ rsync ]);

  cursorRawAppImageSource = fetchurl {
    url = "https://downloads.cursor.com/production/02270c8441bdc4b2fdbc30e6f470a589ec78d60d/linux/x64/Cursor-0.50.7-x86_64.AppImage";
    sha256 = "ukYsLtwnM+yjeDX24Bls7c0MhxeMGOemdQFF6t8Mqvg=";
  };

  customWrappedAppimage = appimageTools.wrapType2 {
    inherit pname version;
    src = cursorRawAppImageSource;
    extraPkgs =
      pkgsFHS:
      (with pkgsFHS; [
        git
        openssh-no-checkperm
      ]);
    # If you want to re-add SSH_AUTH_SOCK forwarding for the FHS env (runtime):
    # extraMakeWrapperArgs = [ "--inherit-env" "SSH_AUTH_SOCK" ];
  };

  customAppimageContents = appimageTools.extractType2 {
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
    '')
    + (lib.optionalString stdenvNoCC.hostPlatform.isDarwin oldAttrs.installPhase);

  passthru = oldAttrs.passthru // {
    sources = (oldAttrs.passthru.sources or { }) // {
      ${stdenvNoCC.hostPlatform.system} = cursorRawAppImageSource;
    };
  };
}
