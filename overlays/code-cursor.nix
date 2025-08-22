{
  lib,
  stdenvNoCC,
  fetchurl,
  appimageTools,
  rsync,
}:
oldAttrs:
let
  # Set these to override; keep as null to preserve existing values
  overrideUrl = "https://downloads.cursor.com/production/99e3b1b4d8796e167e72823eadc66ac2d51fd40c/linux/x64/Cursor-1.5.1-x86_64.AppImage";
  overrideHash = "sha256-1gLVVZPHs38LCE/l1XcGv6VyZ11oKQQNw8EU3MAjQ1I=";
  overrideVersion = "1.5.1";
  overridePname = oldAttrs.pname;
in
# Only override when both URL and hash are provided
(lib.optionalAttrs (overrideUrl != null && overrideHash != null && overrideVersion != null) rec {
  pname = overridePname;
  version = overrideVersion;
  src = appimageTools.extract {
    inherit pname version;
    src = fetchurl {
      url = overrideUrl;
      hash = overrideHash;
    };
  };
  sourceRoot = "${overridePname}-${overrideVersion}-extracted/usr/share/cursor";
})
