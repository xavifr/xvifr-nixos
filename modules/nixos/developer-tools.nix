{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    modules.developer-tools = {
      enable = lib.mkEnableOption "Enable developer tools";
    };
  };

  config = lib.mkIf config.modules.developer-tools.enable {
    environment.systemPackages = with pkgs; [
      code-cursor
      vscode
      slack
      buf
      openbao
      delve
      mypy
      postman
      kubernetes-helm
      go
      gcc
      jq
      opentofu
      terragrunt
      k9s
      kubectl
      (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])

      dbeaver-bin
      mysql-workbench
      gnumake
    ];

    /*
      services.pgadmin = {
         enable = true;
         initialEmail = "xavier.franquet@aistechspace.com";
         initialPasswordFile = "/etc/nixos/secrets/pgadmin_password";
         port = 5054;
       };
    */

    services.github-runners.aistechspace = {
      enable = true;
      name = "aistechspace-runner-at-xvi";
      tokenFile = config.age.secrets.secret_github_aistechspace_runner.path;
      url = "https://github.com/aistechspace";
      noDefaultLabels = true;
      extraLabels = [
        "Linux"
        "X64"
        "ubuntu-20.04"
        "ubuntu-22.04"
        "ubuntu-latest"
      ];
    };

  };

}
