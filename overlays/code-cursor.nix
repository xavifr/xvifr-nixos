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
  overrideUrl = "https://downloads.cursor.com/production/af58d92614edb1f72bdd756615d131bf8dfa5299/linux/x64/Cursor-1.4.5-x86_64.AppImage";
  overrideHash = "sha256-2Hz1tXC+YkIIHWG1nO3/84oygH+wvaUtTXqvv19ZAz4=";
  overrideVersion = "1.4.5";
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
