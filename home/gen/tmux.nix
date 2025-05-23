{ pkgs }:
{
  enable = true;
  escapeTime = 5;
  prefix = "C-s";
  mouse = true;
  shell = pkgs.zsh.outPath + "/bin/zsh";
  extraConfig = ''
    set-option -g status-justify "centre"
    set-option -g status-style bg=default
    set -g status-left "[#S]          "
    set -g window-status-format         "#I:#W "
    set -g window-status-current-format "#[bold]#I:#W*"
    set -g status-right "#[bold]%H:%M %m-%d"
    set -g pane-border-style fg=brightblack
    set -g pane-active-border-style fg=blue
    set -g default-terminal "screen-256color"
    set-window-option -g mode-keys vi
    bind -T copy-mode-vi v send -X begin-selection
    bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel pbcopy
    bind-key k select-pane -U
    bind-key j select-pane -D
    bind-key h select-pane -L
    bind-key l select-pane -R
    set-option -g focus-events on # send focus events to terminal
  '';
}
