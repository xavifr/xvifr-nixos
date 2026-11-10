{
  lib,
  appimageTools,
  fetchurl,
}:

let
  version = "1.3.9.4";
  pname = "AnycubicSlicer";

  src = fetchurl {
    url = "https://github.com/thecalamityjoe87/anycubic-slicer-next-packages/releases/download/v1.3.9.4/AnycubicSlicer-1.3.9.4-x86_64.AppImage";
    hash = "sha256-4foQjgwnmx4S5LjfTulAb5jc3EqkBN/20/MrUtzZoHg=";
  };
in
# Run only `$out/bin/${pname}` from the built package (or `AnycubicSlicer` on PATH).
# The `…-extracted` store path is an internal unpack step; executing it skips FHS/LD_LIBRARY_PATH.
appimageTools.wrapType2 rec {
  inherit pname version src;

  extraPkgs =
    pkgs: with pkgs; [
      webkitgtk_4_1
      libsoup_3
      libglvnd
    ];

  # Do not bind-mount /run/opengl-driver by store path (breaks if /newroot/run/…
  # is missing). Host /run is already visible via buildFHSEnv’s top-level binds.
  #
  # `--setenv` applies to every process in the sandbox (including WebKit helpers).
  # Multi-process WebKit often spawns several EGL users; under FHS some still fail
  # with EGL_BAD_PARAMETER even when the main process has GDK_BACKEND=x11.
  extraBwrapArgs = [
    "--setenv"
    "GDK_BACKEND"
    "x11"
    "--setenv"
    "WEBKIT_DISABLE_DMABUF_RENDERER"
    "1"
    "--setenv"
    "WEBKIT_DISABLE_COMPOSITING_MODE"
    "1"
    "--setenv"
    "WEBKIT_USE_SINGLE_WEB_PROCESS"
    "1"
  ];

  extraInstallCommands = ''
    shopt -s nullglob
    for desktop in $out/share/applications/*.desktop; do
      substituteInPlace "$desktop" \
        --replace-fail "Exec=AppRun" "Exec=$out/bin/${pname}"
    done
  '';

  meta = {
    description = "Anycubic Slicer Next";
    homepage = "https://github.com/thecalamityjoe87/anycubic-slicer-next-packages";
    downloadPage = "https://github.com/thecalamityjoe87/anycubic-slicer-next-packages/releases";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ thecalamityjoe87 ];
    platforms = [ "x86_64-linux" ];
  };
}
