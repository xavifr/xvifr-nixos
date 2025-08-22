{
  lib,
  stdenvNoCC,
  fetchurl,
  nodejs,
}:

stdenvNoCC.mkDerivation rec {
  pname = "gemini-cli";
  version = "0.1.22";

  src = fetchurl {
    url = "https://github.com/google-gemini/gemini-cli/releases/download/v${version}/gemini.js";
    hash = "sha256-rwxmfJsN7cU8x6PxEqZdqgIFjHIzwUTCzPgOEp1AVw4=";
  };

  dontUnpack = true;

  installPhase = ''
        runHook preInstall
        install -Dm644 "$src" "$out/share/${pname}/gemini.js"
        mkdir -p "$out/bin"
        cat > "$out/bin/gemini" <<EOF
    #!/usr/bin/env bash
    exec ${lib.getExe nodejs} "$out/share/${pname}/gemini.js" "\$@"
    EOF
        chmod +x "$out/bin/gemini"
        runHook postInstall
  '';

  meta = with lib; {
    description = "Gemini CLI (single-file release)";
    homepage = "https://github.com/google-gemini/gemini-cli";
    license = licenses.asl20;
    platforms = platforms.unix;
    mainProgram = "gemini";
  };
}
