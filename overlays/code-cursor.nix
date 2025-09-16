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
  overrideUrl = "https://downloads.cursor.com/production/9b5f3f4f2368631e3455d37672ca61b6dce8543e/linux/x64/Cursor-1.6.23-x86_64.AppImage";
  overrideHash = "sha256-DyWy8c+H1vhX6OGo8m78To/wExFmZ0eNeHk6YmSuOe0=";
  overrideVersion = "1.6.23";
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
