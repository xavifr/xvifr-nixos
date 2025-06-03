# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  # my-module = import ./my-module.nix;
  kubernetes = import ./kubernetes.nix;
  plasma = import ./plasma.nix;
  as-dev = import ./as-dev.nix;
  dev = import ./dev.nix;
  print-3d-tools = import ./3d-printer.nix

}
