{
  pkgs,
  secrets,
  ...
}:
{
  home.packages = with pkgs; [
    telegram-desktop
    gemini-cli
  ];

  programs.ruff = {
    enable = true;
    settings = {
    };
  };

  programs.uv.enable = true;

  programs.git = {
    enable = true;
    userName = "Xavier Franquet";
    userEmail = "xavier.franquet@aistechspace.com";
    extraConfig = {
      url."git@github.com:aistechspace/".insteadOf = [ "https://github.com/aistechspace/" ];
      rerere.enabled = true;
    };
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

        "editor.fontFamily" = "'JetBrainsMono Nerd Font'";
        "editor.fontWeight" = "Regular";
        "editor.fontLigatures" = true;
        "editor.fontSize" = 14;

        "terminal.external.linuxExec" = "kitty";
        "terminal.integrated.defaultProfile.linux" = "fish";
        "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
        "terminal.integrated.fontWeight" = "Regular";
        "terminal.integrated.fontLigatures" = true;
        "terminal.integrated.fontSize" = 14;

        "docker.extension.experimental.composeCompletions" = true;
        "terminal.integrated.commandsToSkipShell" = [ "-cursorai.action.generateInTerminal" ];
        "remote.SSH.useLocalServer" = false;
        "[dockercompose]" = {
          "editor.insertSpaces" = true;
          "editor.tabSize" = 2;
          "editor.autoIndent" = "advanced";
          "editor.quickSuggestions" = {
            "other" = true;
            "comments" = false;
            "strings" = true;
          };
          "editor.defaultFormatter" = "redhat.vscode-yaml";
        };
      };

      extensions =
        with pkgs.vscode-extensions;
        [
          golang.go
          matangover.mypy
          redhat.vscode-yaml
          charliermarsh.ruff
          ms-python.python
          eamodio.gitlens
          ms-azuretools.vscode-docker
          jnoortheen.nix-ide
          ms-python.python
          github.vscode-github-actions
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "gemini-cli-vscode-ide-companion";
            publisher = "google";
            version = "0.1.21";
            sha256 = "sha256-ZWQEhxO2e9h3K2UbA2uWLL5WbndybsHTmSbaLvr9vIU=";
          }
          {
            name = "vscode-coverage-gutters";
            publisher = "ryanluker";
            version = "2.14.0";
            sha256 = "sha256-waF3FmncUsXqWFWGRy9X7RQ29BDRYlaqyFhEXg4HXNo=";
          }
        ];
    };
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    extraConfig = ''
      Host github.com
        Hostname github.com
        IdentityFile ${secrets.secret_as-xvi_ssh_key.path}
        User git
        Port 22

      Host bitbucket.org
        Hostname github.com
        IdentityFile ${secrets.secret_as-xvi_ssh_key.path}
        User git
        Port 22

      Host p.github.com
        AddKeysToAgent no
        Hostname github.com
        IdentityAgent none
        IdentityFile ${secrets.secret_xvi_ssh_key.path}
        User git
        Port 22

      Host 192.168.14.254
        AddKeysToAgent no
        IdentityAgent none
        IdentityFile ${secrets.secret_xvi_ssh_key.path}
        User xavier
        Port 1179

      Host 192.168.14.21
        AddKeysToAgent no
        IdentityAgent none
        IdentityFile ${secrets.secret_xvi_ssh_key.path}
        User xavier
        
    '';
  };

  services.ssh-agent.enable = true;

}
