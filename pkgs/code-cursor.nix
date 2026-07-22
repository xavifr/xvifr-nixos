{
  lib,
  stdenv,
  buildVscode,
  fetchurl,
  appimageTools,
  undmg,
  commandLineArgs ? "",
  useVSCodeRipgrep ? stdenv.hostPlatform.isDarwin,
}:

let
  inherit (stdenv) hostPlatform;

  version = "3.9.16";
  vscodeVersion = "1.105.1";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://downloads.cursor.com/production/042b3c1a4c53f2c3808067f519fbfc67b72cad8b/linux/x64/Cursor-3.9.16-x86_64.AppImage";
      hash = "sha256-dG61VYGMHPip57ldzNICEi1yPc4s1dON+MlDGiKadKc=";
    };
  };

  source = sources.${hostPlatform.system};
in
(buildVscode rec {
  inherit
    commandLineArgs
    useVSCodeRipgrep
    version
    vscodeVersion
    ;

  pname = "cursor";

  executableName = "cursor";
  longName = "Cursor";
  shortName = "cursor";
  libraryName = "cursor";
  iconName = "cursor";

  src =
    if hostPlatform.isLinux then
      appimageTools.extract {
        inherit pname version;
        src = source;
      }
    else
      source;

  # for unpacking the DMG
  extraNativeBuildInputs = lib.optionals hostPlatform.isDarwin [ undmg ];

  sourceRoot =
    if hostPlatform.isLinux then "${pname}-${version}-extracted/usr/share/cursor" else "Cursor.app";

  tests = { };

  updateScript = ./update.sh;

  dontFixup = stdenv.hostPlatform.isDarwin;
  patchVSCodePath = false;

  meta = {
    description = "AI-powered code editor built on vscode";
    homepage = "https://cursor.com";
    changelog = "https://cursor.com/changelog";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [
      aspauldingcode
      prince213
    ];
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ]
    ++ lib.platforms.darwin;
    mainProgram = "cursor";
  };
}).overrideAttrs
  (oldAttrs: {
    autoPatchelfIgnoreMissingDeps =
      (oldAttrs.autoPatchelfIgnoreMissingDeps or [ ])
      ++ lib.optionals (stdenv.hostPlatform.isLinux && !stdenv.hostPlatform.isMusl) [
        "libc.musl-*.so.*"
      ];

    passthru = (oldAttrs.passthru or { }) // {
      inherit sources;
    };
  })
