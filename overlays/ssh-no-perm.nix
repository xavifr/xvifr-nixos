{
  lib,
  patchFile,
}:
oldAttrs: {
  # Create a distinct package name by appending a suffix
  pname = "openssh-no-checkperm";
  # Version remains the same as the base openssh package
  #version = oldAttrs.version;

  patches = (oldAttrs.patches or [ ]) ++ [
    patchFile # Apply the provided patch
  ];

}
