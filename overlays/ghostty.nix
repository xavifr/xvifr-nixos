{
  fetchFromGitHub,
}:

oldAttrs: {
  version = "1.1.4-76a3612-nix";

  src = fetchFromGitHub {
    owner = "ghostty-org";
    repo = "ghostty";
    rev = "76a3612195bb3d67e67a1e824fb3cbdb4d339735";
    sha256 = "sha256-oMi9ViBBJv/QsUUXjPTeNasw+W8EC2cKnlaJNPRzp8M=";
    fetchSubmodules = true;
  };
}
