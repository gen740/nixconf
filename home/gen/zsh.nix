{
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
}
