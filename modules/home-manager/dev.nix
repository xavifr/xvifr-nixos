{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
{
  home.packages = with pkgs; [
  ];

  programs.git = {
    enable = true;
    userName = "Xavier Franquet";
    userEmail = "xavier@franquet.es";
  };

  programs.vscode = {
    enable = true;
    package = pkgs.code-cursor;
    profiles.default = {
      userSettings = {
        "editor.cursorBlinking" = "smooth";
        "files.autoSave" = "afterDelay";
        "files.autoSaveDelay" = 1000;
        "window.commandCenter" = true;
        "workbench.colorTheme" = "Monokai";
        "workbench.tree.indent" = 24;
        "workbench.activityBar.orientation" = "vertical";
        "terminal.integrated.profiles.linux" = {
          "customProfile" = {
            "path" = "/bin/bash";
            "args" = [
              "-c"
              "eval $(ssh-agent -s) >/dev/null && exec bash && echo \"KILLING $SSH_AGENT_PID\" && sleep 3 && kill $SSH_AGENT_PID"
            ];
          };
        };
        "terminal.integrated.defaultProfile.linux" = "customProfile";
      };
      extensions = with pkgs.vscode-extensions; [
        golang.go
        matangover.mypy
        redhat.vscode-yaml
        charliermarsh.ruff
        ms-python.python
        eamodio.gitlens
        ms-azuretools.vscode-docker
        jnoortheen.nix-ide
      ];
    };
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      AddKeysToAgent yes
      IdentityFile ${secrets.secret_xvi_ssh_key.path}

      Host as.github.com
          AddKeysToAgent no
          Hostname github.com
          IdentityFile ${secrets.secret_as-xvi_ssh_key.path}
          User git
          Port 22      
    '';
  };

  services.ssh-agent.enable = true;

}
