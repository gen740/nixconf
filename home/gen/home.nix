{ ... }:
{
  nixpkgs.config.allowUnfree = true;
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.gen =
      {
        pkgs,
        ...
      }:
      {
        home.stateVersion = "24.11";
        home.shellAliases = {
          ls = "ls --color -F";
          dr = "direnv allow";
          ta = "tmux attach";
        };

        home.packages = with pkgs; [
          wget
          curl
          fswatch
          glab
          trash-cli
          nixd
          nixfmt-rfc-style
          rsync
          zstd
          gh
          gh-copilot
        ];

        xdg.configFile = {
          "git/git-commitmessage.txt" = {
            source = ./git/git-commitmessage.txt;
          };
          "nvim" = {
            source = ../../nvim;
          };
        };

        nix = {
          extraOptions = ''
            experimental-features = nix-command flakes
          '';
        };

        programs = {
          gpg.enable = true;
          ripgrep.enable = true;

          alacritty = import ./alacritty/setting.nix;

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
              set -g default-terminal "xterm-256color"
              set-window-option -g mode-keys vi
              bind -T copy-mode-vi v send -X begin-selection
              bind c new-window -c ~/home
              bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel pbcopy
              bind-key k select-pane -U
              bind-key j select-pane -D
              bind-key h select-pane -L
              bind-key l select-pane -R
              set-option -g focus-events on # send focus events to terminal
            '';
          };

          git = import ./git/setting.nix;

          zsh = {
            enable = true;
            initContent = ''
              stty stop undef # do not stop the terminal with C-s
            '';
            envExtra = ''
              unsetopt global_rcs

              # Nix
              if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
                source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
              fi
              # End Nix
            '';
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
                blink-cmp
                nvim-lspconfig
                copilot-lua
                nvim-treesitter
                github-nvim-theme
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
                vhdl
                vim
                vimdoc
                yaml
                doxygen
                typst
              ]);
            viAlias = true;
            withNodeJs = true;
            vimdiffAlias = true;
          };
        };
      };
  };
}
