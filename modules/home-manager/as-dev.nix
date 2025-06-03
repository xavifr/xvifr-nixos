{ config
, lib
, pkgs
, secrets
, ...
}:

with lib;

let
  cfg = config.modules.as-dev;
in {
  options.modules.as-dev = {
    enable = mkEnableOption "Aistech Dev";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      code-cursor
    ];


    programs.git = {
      enable = true;
      userName = "Xavier Franquet";
      userEmail = "xavier.franquet@aistechspace.com";
    };

    programs.vscode = {
      enable = true;
      package = pkgs.code-cursor;
      profiles.default = {
        userSettings = {
          "editor.cursorBlinking" = "smooth";
          "files.autoSave" = "afterDelay";
          "files.autoSaveDelay" = 1000;
          "window.commandCenter"= true;
          "workbench.colorTheme"= "Cursor Dark High Contrast";
        };

        extensions = with pkgs.vscode-extensions; [
          golang.go
          matangover.mypy
          redhat.vscode-yaml
          charliermarsh.ruff
          ms-python.python
          eamodio.gitlens
          ms-azuretools.vscode-docker
          bbenoist.nix
        ];
      };
    };

    programs.ssh = {
      enable = true;
      addKeysToAgent = "yes";
      extraConfig = ''
        IdentityFile ${secrets.secret_as-xvi_ssh_key.path}
      '';    
    };

    
    # Optional: Add kubectl configuration
    # xdg.configFile."kubectl/config".source = ./kubectl-config;
  };
} 