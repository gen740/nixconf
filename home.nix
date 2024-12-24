{
  pkgs,
  name,
  home,
  config,
  ...
}:
{
  home.username = name;
  home.homeDirectory = home;
  home.stateVersion = "25.05";
  home.shellAliases = {
    ls = "ls --color -F";
    dr = "direnv allow";
    ta = "tmux attach";
    rebuild-system =
      if pkgs.stdenv.isDarwin then
        "darwin-rebuild switch --flake ~/.config/nix-darwin"
      else if pkgs.stdenv.isLinux then
        "nixos-rebuild switch"
      else
        "echo 'Unsupported platform: ${config.system.platform.system}' && exit 1";
  };
  home.packages = with pkgs; [
    coreutils-full
    wget
    curl
    hyperfine

    btop
    fd
    ripgrep
    gh
    glab
    trash-cli
    nixd
    nixfmt-rfc-style
    nodejs
  ];
  programs = {
    home-manager.enable = true;
    gpg.enable = true;

    alacritty = {
      enable = true;
      settings = {
        general.import = [
          ./alacritty/theme.toml
          ./alacritty/keybindings.toml
        ];
        font.size = 14;
        font.normal.family = "FiraCode Nerd Font";
        window = {
          decorations = "none";
          option_as_alt = "Both";
          startup_mode = "Maximized";
        };
      };
    };

    fzf = {
      enable = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = [
        "--border=none"
        "--height=24"
        "--scroll-off=3"
        "--no-mouse"
        "--prompt=\ "
        "--pointer=\ "
      ];
      tmux.enableShellIntegration = true;
    };

    lazygit = {
      enable = true;
      settings = {
        gui = {
          border = "single";
          nerdFontsVersion = "3";
          showBottomLine = false;
        };
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    tmux = {
      enable = true;
      escapeTime = 5;
      baseIndex = 1;
      prefix = "C-s";
      mouse = true;
      shell = pkgs.zsh.outPath + "/bin/zsh";
      historyLimit = 10000;
      extraConfig = ''
        set-option -g status-justify "centre"
        set-option -g status-left-length 40
        set-option -g status-right-length 40
        set-option -g status-interval 1

        TMUX_STATUS_FG=#cdcecf
        TMUX_STATUS_DARKFG=#71839b
        TMUX_STATUS_BG=#393b44
        TMUX_STATUS_BLUE=#719cd6
        TMUX_STATUS_BG_BLACK=#192330
        TMUX_STATUS_GREEN=#81b29a

        set-option -g status-style bg=default

        set -g status-left "#[fg=$TMUX_STATUS_BLUE,bold,underscore]#S#[fg=$TMUX_STATUS_GREEN,nobold,nounderscore]       "
        set -g window-status-format " #[fg=$TMUX_STATUS_BG,bold]#I #[fg=$TMUX_STATUS_BG,nobold]#W"
        set -g window-status-current-format " #[fg=$TMUX_STATUS_BLUE,bold,underscore]#I #[fg=$TMUX_STATUS_BLUE,nobold]#W"
        set -g status-right "#[fg=$TMUX_STATUS_BLUE,bold,underscore]%m/%d %H:%M:%S"

        set-option -g status-position bottom
        set -g pane-border-style fg=color236
        set -g pane-active-border-style "fg=magenta"

        set-window-option -g mode-keys vi
        bind -T copy-mode-vi v send -X begin-selection
        bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"

        bind-key -n C-S-Left swap-window -t -1
        bind-key -n C-S-Right swap-window -t +1
        bind-key k select-pane -U
        bind-key j select-pane -D
        bind-key h select-pane -L
        bind-key l select-pane -R

        set-option -g focus-events on
      '';
    };

    git = {
      enable = true;
      userName = "gen740";
      userEmail = "54583542+gen740@users.noreply.github.com";
      aliases = {
        subup = "submodule update --init --recursive";
        pl = "log --graph --oneline --decorate --all --date=short --pretty='format:%C(bold magenta)%h%C(reset) - %C(green)%ad%C(reset)%C(auto)%d%C(reset) %C(ul brightmagenta)%s%C(reset) %C(yellow)@%an%C(reset)'";
        ps = "status --short --branch --show-stash  --untracked-files=all";
      };
      signing = {
        gpgPath = "gpg";
        key = "gen740 <54583542+gen740@users.noreply.github.com>";
        signByDefault = true;
      };
      extraConfig = {
        diff = {
          colorMoved = "default";
          tool = "nvimdiff";
        };
        "difftool \"nvimdiff\"" = {
          prompt = true;
          cmd = ''nvim -R -d -c "wincmd l" -d "$LOCAL" "$REMOTE"'';
        };
        merge = {
          conflictstyle = "diff3";
          tool = "nvimdiff";
        };
        mergeTool = {
          cmd = ''nvim -d -c "4wincmd w | wincmd J" "$LOCAL" "$BASE" "$REMOTE"  "$MERGED"'';
          keepBackup = false;
        };
        safe = {
          directory = "/opt/homebrew";
        };
        help = {
          autocorrect = 20;
        };
        commit = {
          verbose = true;
          template = "~/.config/nix-darwin/git/git-commitmessage.txt";
        };
      };
    };

    zsh = {
      enable = true;
      initExtra = ''
        stty stop undef # do not stop the terminal with C-s
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
        PROMPT="%~ > ";
      '';
      sessionVariables = {
        REPORTTIME = 10;
        TIMEFMT = "%*E %*U %*S CPU: %P Memory: %M KB # %J";
        EDITOR = "nvim";
        GIT_EDITOR = "nvim";
        LESSCHARSET = "utf-8";
        VISUAL = "nvim";
        MANPAGER = "nvim +Man!";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_DATA_HOME = "$HOME/.local/share";
      };
      history = {
        path = "";
        save = 0;
        size = 100;
      };
      enableCompletion = true;
    };

    neovim = {
      enable = true;
      plugins =
        (with pkgs.vimPlugins; [
          oil-nvim

          nvim-cmp
          cmp-nvim-lsp
          cmp-nvim-lsp-signature-help
          cmp-path
          cmp-vsnip

          nvim-dap
          nvim-nio
          nvim-dap-ui

          plenary-nvim
          telescope-nvim
          telescope-fzf-native-nvim
          fzf-lua

          nvim-treesitter

          vim-vsnip
          nvim-lspconfig
          tokyonight-nvim
          copilot-lua
        ])
        ++ (with pkgs.vimPlugins.nvim-treesitter-parsers; [
          asm
          c
          cpp
          diff
          git_config
          git_rebase
          gitcommit
          gitignore
          go
          javascript
          json
          latex
          lua
          nix
          python
          rust
          toml
          typescript
          vim
          vimdoc
          yaml
        ]);
      viAlias = true;
    };
  };
}
