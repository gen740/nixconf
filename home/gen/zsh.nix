{ pkgs, ... }:
{
  enable = true;
  initContent = ''
    stty stop undef # do not stop the terminal with C-s
    case "$(uname)" in
      Darwin)
        HM_OS_ICON=""
        ;;
      Linux)
        if [[ -f /etc/os-release ]] && grep -q '^ID=nixos' /etc/os-release; then
          HM_OS_ICON=""
        else
          HM_OS_ICON=""
        fi
        ;;
      *)
        HM_OS_ICON="?"
        ;;
    esac
    if whence __git_ps1 &>/dev/null; then
      precmd () {
      local EXIT_STATUS=$?
      if [ $EXIT_STATUS -ne 0 ]; then
         echo -e "\e[31m[${"$"}{EXIT_STATUS}]\e[0m"
      fi
      if (( ZSH_PROMPT_HAS_RUN )); then
        echo
      else
        ZSH_PROMPT_HAS_RUN=1
      fi
      __git_ps1 "$HM_OS_ICON (%m) %~" "
    > " " - \e[32m %s\e[0m"
    }
    fi
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
  sessionVariables = {
    LC_ALL = "en_US.UTF-8";
  };
  history = {
    path = "";
    save = 0;
    size = 100;
  };
  plugins = [
    {
      name = "git-prompt";
      src = pkgs.runCommand "git-prompt" { } ''
        mkdir -p $out
        cp ${
          builtins.fetchurl {
            url = "https://github.com/git/git/raw/683c54c999c301c2cd6f715c411407c413b1d84e/contrib/completion/git-prompt.sh";
            sha256 = "0fllfidrc9nj2b9mllf190y3bca1pdm95vyzgsza1l3gl3s1ixvz";
          }
        } $out/git-prompt.sh
      '';
      file = "git-prompt.sh";
    }
  ];
  localVariables = {
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
  enableCompletion = true;
}
