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

        export CDPATH=".:$HOME/.local/share/src"
        export GPG_TTY=$(tty)

        source ${pkgs.git}/share/git/contrib/completion/git-prompt.sh
        GIT_PS1_SHOWDIRTYSTATE=1

        __prompt() {
          local status=$?
          local reset='\[\e[0m\]'
          local color_status='\[\e[33m\]'
          [[ $status -ne 0 ]] && color_status='\[\e[31m\]'

          PS1="\[\e[35m\]\u@''${HOSTNAME%%.*} ❯$reset "

          if command -v kubectl >/dev/null 2>&1; then
            local ctx
            ctx=$(kubectl config current-context 2>/dev/null)
            [[ -n $ctx ]] && PS1+="\[\e[36m\]$ctx ❯$reset "
          fi

          PS1+="\[\e[33m\]\W$reset"
          [[ $(jobs -p | wc -l) -gt 0 ]] && PS1+=" \[\e[34m\]*$reset"
          PS1+="$(__git_ps1 ' \[\e[32m\](%s)'"$reset")"
          PS1+=" $color_status|$reset "
        }
        PROMPT_COMMAND="__prompt''${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

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
