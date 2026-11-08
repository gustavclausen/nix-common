{ minimal-tmux }:
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
{
  options.custom.tmux = {
    enable = mkEnableOption "Tmux configuration";
  };

  config =
    let
      cfg = config.custom.tmux;
    in
    mkIf cfg.enable {
      programs = {
        tmux = {
          enable = true;
          plugins = with pkgs; [
            tmuxPlugins.vim-tmux-navigator
            {
              plugin = minimal-tmux.packages.${pkgs.stdenv.hostPlatform.system}.default;
              extraConfig = ''
                set -g @minimal-tmux-indicator-str "🔒"
                set -g @minimal-tmux-bg "#effa87"
                set -g @minimal-tmux-right false
              '';
            }
          ];
          terminal = "screen-256color";
          prefix = "C-a";
          escapeTime = 10;
          historyLimit = 10000;
          shell = "${pkgs.bashInteractive}/bin/bash";
          extraConfig = ''
            set-option -a terminal-features 'xterm-256color:RGB'

            set-option -g focus-events on
            set-option -g pane-border-lines heavy
            set -g pane-active-border-style fg=color228
            set -g pane-border-style fg=grey
            set-option -g allow-rename off
            set-option -g renumber-windows on

            setw -g mode-keys vi
            bind 'v' copy-mode

            bind C-v split-window -c "#{pane_current_path}" -h
            bind C-x split-window -c "#{pane_current_path}" -v
            unbind '"'
            unbind %

            bind c new-window -c "#{pane_current_path}"

            bind -r M-k resize-pane -U 5
            bind -r M-j resize-pane -D 5
            bind -r M-h resize-pane -L 5
            bind -r M-l resize-pane -R 5

            bind -r N display-popup -E "~/.scripts/utils/tmux-navigator.sh"
            bind r source-file ~/.config/tmux/tmux.conf \; display-message "Tmux config is reloaded"

            set-option -g default-command ${pkgs.bashInteractive}/bin/bash
          '';
        };
      };
    };
}
