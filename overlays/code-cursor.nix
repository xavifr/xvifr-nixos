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
  overrideUrl = "https://downloads.cursor.com/production/2f2737de9aa376933d975ae30290447c910fdf46/linux/x64/Cursor-1.5.11-x86_64.AppImage";
  overrideHash = "sha256-PlZPgcDe6KmEcQYDk1R4uXh1R34mKuPLBh/wbOAYrAY=";
  overrideVersion = "1.5.11";
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
