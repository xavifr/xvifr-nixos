{
  pkgs,
  secrets,
  ...
}:
{
  home.packages = with pkgs; [
    telegram-desktop
    wasistlos
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
        "git.autofetch" = true;
        "vs-kubernetes" = {
          "vs-kubernetes.crd-code-completion" = "enabled";
        };
        "terminal.external.linuxExec" = "kitty";
        "terminal.integrated.defaultProfile.linux" = "fish";
        "editor.fontFamily" = "'Fira Code Symbol'";
        "editor.inlayHints.fontFamily" = "Fira Code SymbolSymbol";
        "editor.codeLensFontFamily" = "Fira Code Symbol";
        "editor.inlineSuggest.fontFamily" = "Fira Code";
        "terminal.integrated.fontFamily" = "'Fira Code', 'Fira Code Symbol'";
        "docker.extension.experimental.composeCompletions" = true;
      };
      extensions = with pkgs.vscode-extensions; [
        golang.go
        matangover.mypy
        redhat.vscode-yaml
        charliermarsh.ruff
        ms-python.python
        ms-azuretools.vscode-docker
        jnoortheen.nix-ide
      ];
    };
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host github.com
        Hostname github.com
        IdentityFile ${secrets.secret_xvi_ssh_key.path}
        User git
        Port 22

      Host as.bitbucket.org
        Hostname github.com
        IdentityFile ${secrets.secret_as-xvi_ssh_key.path}
        User git
        Port 22

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
