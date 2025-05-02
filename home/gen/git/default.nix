{
  enable = true;
  userName = "gen740";
  userEmail = "54583542+gen740@users.noreply.github.com";
  aliases = {
    subup = "submodule update --init --recursive";
    pl = "log --graph --oneline --decorate --all --date=short --pretty='format:%C(bold magenta)%h%C(reset) - %C(green)%ad%C(reset)%C(auto)%d%C(reset) %C(ul brightmagenta)%s%C(reset) %C(yellow)@%an%C(reset)'";
    ps = "status --short --branch --show-stash  --untracked-files=all";
    cla = "clean -xfd -e flake.nix -e flake.lock -e .envrc";
    difftool-master = "!git difftool $(git merge-base origin/master HEAD)..HEAD";
  };
  signing = {
    signer = "gpg";
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
  ignores = [
    ".direnv"
    ".envrc"
    "flake.nix"
    "flake.lock"
    "workdir/"
  ];
}
