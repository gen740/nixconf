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

    gpg = {
      enable = true;
      homedir = "${home}/.gnupg";
    };

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
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = true;
        format = "(blue)$directory$git_branch$python\n[>](blue) ";
        command_timeout = 300;
        git_branch = {
          format = "[\($symbol$branch(:$remote_branch)\)]($style) ";
          symbol = "";
          style = "green";
        };
        directory = {
          truncation_length = 5;
          truncate_to_repo = false;
          style = "blue bold";
        };
        python = {
          format = "[\${pyenv_prefix}(\${version} )(\\($virtualenv\\) )]($style)";
        };
      };
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
      initExtraBeforeCompInit = ''
        zstyle ':completion:*:default' list-colors ${"\${(s.:.)LS_COLORS}"}
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
        setopt AUTO_LIST # Automatically list choices on an ambiguous completion.
      '';
      initExtra = ''
        function h() {
            if [ -e $HOME/home ]; then
                dirname=`fd -c never -E .git . $HOME/home/ -aH --type d | fzf`
            else
                dirname=`fd -c never -E .git . $HOME/ -aH --type d | fzf`
            fi

            if [[ $dirname == ""  ]]; then
                return 1
            fi
            pushd $dirname > /dev/null
            unset dirname
        }

        function nix-search() {
            nix search nixpkgs "$1" 2> /dev/null  |
              sed -r 's/\x1B\[[0-9;]*[mG]//g'     |
              grep "^* "                          |
              grep $1                             |
              fzf
        }

        stty stop undef # do not stop the terminal with C-s

        bindkey -e
      '';
      sessionVariables = {
        LS_COLORS = "rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.7z=01;31:*.ace=01;31:*.alz=01;31:*.apk=01;31:*.arc=01;31:*.arj=01;31:*.bz=01;31:*.bz2=01;31:*.cab=01;31:*.cpio=01;31:*.crate=01;31:*.deb=01;31:*.drpm=01;31:*.dwm=01;31:*.dz=01;31:*.ear=01;31:*.egg=01;31:*.esd=01;31:*.gz=01;31:*.jar=01;31:*.lha=01;31:*.lrz=01;31:*.lz=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.lzo=01;31:*.pyz=01;31:*.rar=01;31:*.rpm=01;31:*.rz=01;31:*.sar=01;31:*.swm=01;31:*.t7z=01;31:*.tar=01;31:*.taz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tgz=01;31:*.tlz=01;31:*.txz=01;31:*.tz=01;31:*.tzo=01;31:*.tzst=01;31:*.udeb=01;31:*.war=01;31:*.whl=01;31:*.wim=01;31:*.xz=01;31:*.z=01;31:*.zip=01;31:*.zoo=01;31:*.zst=01;31:*.avif=01;35:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.crdownload=00;90:*.dpkg-dist=00;90:*.dpkg-new=00;90:*.dpkg-old=00;90:*.dpkg-tmp=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:*.swp=00;90:*.tmp=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:";
        WORDCHARS = "!$%";
        REPORTTIME = 10;
        TIMEFMT = "%*E %*U %*S CPU: %P Memory: %M KB # %J";
        EDITOR = "nvim";
        GIT_EDITOR = "nvim";
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
        LESSCHARSET = "utf-8";
        MANWIDTH = 100;
        VISUAL = "nvim";
        MANPAGER = "nvim +Man!";
        PAGER = "less";
        HISTFILE = "";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_DATA_HOME = "$HOME/.local/share";
      };
      history = {
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
          nvim-web-devicons

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
          yaml
        ]);
      viAlias = true;
    };
  };
}
