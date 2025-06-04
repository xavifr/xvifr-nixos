{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
{
  home.packages = with pkgs; [
    bitwarden-desktop
    telegram-desktop
    nixfmt-rfc-style
    nil
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
        "window.commandCenter" = true;
        "workbench.colorTheme" = "Cursor Dark High Contrast";
        "workbench.tree.indent" = 24;

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
    addKeysToAgent = "yes";
    extraConfig = ''
      #IdentityFile ${secrets.secret_as-xvi_ssh_key.path}

      Host p.github.com
        Hostname github.com
        IdentityFile ${secrets.secret_xvi_ssh_key.path}
        User git
        Port 22
    '';
  };

}
