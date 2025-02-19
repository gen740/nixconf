{ pkgs, ... }:
{
  home.username = "gen";
  home.homeDirectory = "/Users/gen";
  home.stateVersion = "24.11";
  home.shellAliases = {
    ls = "ls --color -F";
    dr = "direnv allow";
    ta = "tmux attach";
  };

  nixpkgs.config.allowUnfree = true;

  home.packages =
    let
      macos_applications = with pkgs; [
        skimpdf
        notion-app
        slack
        raycast
        zoom-us
        google-chrome
        chatgpt
      ];
    in
    with pkgs;
    [
      wget
      curl
      fswatch
      glab
      trash-cli
      nixd
      nixfmt-rfc-style
      rsync
      gh
    ]
    ++ pkgs.lib.optionals stdenv.isDarwin macos_applications;

  xdg.configFile."git/git-commitmessage.txt" = {
    source = ./git/git-commitmessage.txt;
  };

  nix = {
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  programs = {
    home-manager.enable = true;
    gpg.enable = true;
    ripgrep.enable = true;
    btop.enable = true;

    alacritty = {
      enable = true;
      settings = {
        general.import = [
          ./alacritty/theme.toml
          ./alacritty/keybindings.toml
        ];
        font.size = 16;
        font.normal.family = "Cica";
        window = {
          decorations = "none";
          option_as_alt = "Both";
        };
      };
    };

    fd = {
      enable = true;
      ignores = [
        ".git"
        "node_modules"
        ".cache"
        ".direnv"
        ".DS_Store"
      ];
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
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    tmux = {
      enable = true;
      escapeTime = 5;
      prefix = "C-s";
      mouse = true;
      shell = pkgs.zsh.outPath + "/bin/zsh";
      extraConfig = ''
        set-option -g status-justify "centre"
        set-option -g status-style bg=default
        set -g status-left "[#S]"
        set -g window-status-format         "#I:#W "
        set -g window-status-current-format "#[bold]#I:#W*"
        set -g status-right "#[bold]%H:%M %m-%d"
        set -g pane-border-style fg=brightblack
        set -g pane-active-border-style fg=blue
        set-window-option -g mode-keys vi
        bind -T copy-mode-vi v send -X begin-selection
        bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel pbcopy
        bind-key k select-pane -U
        bind-key j select-pane -D
        bind-key h select-pane -L
        bind-key l select-pane -R
        set-option -g focus-events on # send focus events to terminal
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
        cla = "clean -xfd -e flake.nix -e flake.lock -e .envrc";
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
        commit = {
          verbose = true;
          template = "~/.config/git/git-commitmessage.txt";
        };
      };
    };

    zsh = {
      enable = true;
      initExtra = ''
        stty stop undef
      ''; # do not stop the terminal with C-s
      defaultKeymap = "emacs";
      localVariables = {
        PROMPT = "%~ ";
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
      sessionVariables = {
        LC_ALL = "en_US.UTF-8";
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
          nightfox-nvim
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
      withNodeJs = true;
    };
  };
}
