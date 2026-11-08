{
  config,
  pkgs,
  lib,
  ...
}:
{
  home = {
    packages = with pkgs; [
      (pkgs.writeShellScriptBin "gsed" "exec ${pkgs.gnused}/bin/sed \"$@\"")
      bash-completion
      bashInteractive
      coreutils
      curl
      diffutils
      doggo
      findutils
      gawk
      git
      gnumake
      gnused
      gzip
      inetutils
      just
      killall
      nil
      nixd
      nixfmt
      neovim
      openssh
      openssl
      parallel
      tree
      wget
      yq-go
      zip
    ];
  };

  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [
        "ignoredups"
        "erasedups"
      ];
      historyIgnore = [
        "pwd"
        "ls"
        "cd"
      ];
      shellOptions = [
        "histappend"
        "checkwinsize"
        "globstar"
        "nullglob"
        "cdspell"
      ];
      shellAliases = {
        ls = "ls --color=auto";
      };

      profileExtra = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin ''
        if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
          . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
          . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
        fi
      '';

      initExtra = ''
        export PATH=$HOME/.local/share/bin:$PATH
        export PATH=$HOME/.local/bin:$PATH
        export PATH=$HOME/.local/scripts:$PATH

        for file in $HOME/.secrets/*.env; do
          source "$file"
        done

        for file in $HOME/.scripts/**/*.sh; do
          source "$file"
        done

        for script_dir in $HOME/.scripts/**/; do
          PATH="$script_dir:$PATH"
        done
      '';
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    fzf = {
      enable = true;
    };

    eza = {
      enable = true;
      icons = "auto";
    };

    direnv = {
      enable = true;
      config = {
        global = {
          load_dotenv = true;
        };
      };
    };

    ripgrep = {
      enable = true;
    };

    jq = {
      enable = true;
    };

    fd = {
      enable = true;
    };
  };
}
