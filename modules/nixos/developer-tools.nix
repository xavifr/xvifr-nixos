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
      unstable.openbao
      mypy
      postman
      kubernetes-helm
      go
      jq
      opentofu
      k9s
      kubectl
      (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])

      dbeaver-bin
      mysql-workbench
    ];

    /*
      services.pgadmin = {
         enable = true;
         initialEmail = "xavier.franquet@aistechspace.com";
         initialPasswordFile = "/etc/nixos/secrets/pgadmin_password";
         port = 5054;
       };
    */

  };

}
