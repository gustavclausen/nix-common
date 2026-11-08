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
    zsh = {
      enable = true;
      autocd = false;
      cdpath = [ "${config.home.homeDirectory}/.local/share/src" ];
      dotDir = "${config.home.homeDirectory}/.config/zsh";
      plugins = [
        {
          name = "zsh-autosuggestions";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-autosuggestions";
            rev = "v0.7.1";
            sha256 = "KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
          };
        }
        {
          name = "zsh-completions";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-completions";
            rev = "v0.36.0";
            sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
          };
        }
        {
          name = "zsh-z";
          src = pkgs.fetchFromGitHub {
            owner = "agkozak";
            repo = "zsh-z";
            rev = "acd0e1984df350c189f8f9c4956ec586b6c73fca";
            sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
          };
        }
        {
          name = "common";
          src = pkgs.fetchFromGitHub {
            owner = "jackharrisonsherlock";
            repo = "common";
            rev = "44b6b34d8feef721a6e4a7df272c740e3d2bd8f4";
            sha256 = "NmAZ/7FhdGzmXgEgWnqHViXH1+ksfsyS4K9i+S5Y8s4=";
          };
          file = "common.zsh-theme";
        }
      ];

      syntaxHighlighting.enable = true;

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "z"
        ];
        extraConfig = ''
          DISABLE_AUTO_TITLE="true"
          ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#737373"
        '';
      };

      initContent =
        let
          zshConfigEarlyInit = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
            lib.mkOrder 500 ''
              if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
                . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
                . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
              fi
            ''
          );
          zshConfig = lib.mkOrder 1000 ''
            export PATH=$HOME/.local/share/bin:$PATH
            export PATH=$HOME/.local/bin:$PATH
            export PATH=$HOME/.local/scripts:$PATH

            export HISTIGNORE="pwd:ls:cd"

            alias ls='ls --color=auto'

            COMMON_COLORS_CURRENT_DIR=yellow
            COMMON_COLORS_RETURN_STATUS_TRUE=yellow
            COMMON_COLORS_RETURN_STATUS_FALSE=red
            COMMON_PROMPT_SYMBOL="|"

            ctx() {
              if [[ (( $+commands[kubectl] )) ]]; then
                local current_ctx=$(kubectl config current-context 2> /dev/null)

                if [[ -n "$current_ctx" ]]; then
                  echo -n "%{$fg[cyan]%}$current_ctx ❯%{$reset_color%} "
                fi
              fi
            }

            host() {
              echo -n "%{$fg[magenta]%}''${USER}@''${HOST%%.*} ❯%{$reset_color%} "
            }

            PROMPT='$(host)$(ctx)$(common_current_dir)$(common_bg_jobs)$(common_return_status)'
            RPROMPT='$(common_git_status)'

            GPG_TTY=$(tty)

            setopt extendedglob
            if [[ -n $HOME/.secrets/*.env(#qN) ]]; then
              for file in $HOME/.secrets/*.env; do
                  source "$file"
              done
            fi

            if [[ -n $HOME/.scripts/**/*.zsh(#qN) ]]; then
              for file in $HOME/.scripts/**/*.zsh; do
                  source "$file"
              done

              script_dirs=($HOME/.scripts/**/)
              for script_dir in $script_dirs; do
                PATH="$script_dir:$PATH"
              done
            fi

            unsetopt extendedglob
          '';
        in
        lib.mkMerge [
          zshConfigEarlyInit
          zshConfig
        ];
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
