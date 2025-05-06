{ pkgs, ... }:

let
  tree-sitter-with-grammars =
    langs:
    let
      grammars = builtins.listToAttrs (
        map (lang: {
          name = lang;
          value = {
            grammar = pkgs.tree-sitter-grammars."tree-sitter-${lang}";
            parser = pkgs.vimPlugins.nvim-treesitter-parsers.${lang};
          };
        }) langs
      );

      names = builtins.attrNames grammars;
      allInputs = map (n: grammars.${n}.grammar) names ++ map (n: grammars.${n}.parser) names;

      script = builtins.concatStringsSep "\n" (
        map (
          lang:
          let
            g = grammars.${lang}.grammar;
            p = grammars.${lang}.parser;
          in
          ''
            mkdir -p $out/parser $out/queries/${lang}
            ln -s ${g}/parser $out/parser/${lang}.so
            for f in ${g}/queries/*.scm; do
              test -e "$f" && ln -s "$f" $out/queries/${lang}/
            done
          ''
        ) names
      );
    in
    pkgs.runCommand "tree-sitter-with-grammars" { nativeBuildInputs = allInputs; } script;
in
{
  enable = true;

  plugins = with pkgs.vimPlugins; [
    oil-nvim
    copilot-lua
    github-nvim-theme
    (tree-sitter-with-grammars [
      "c"
      "cpp"
      "nix"
      "python"
    ])
  ];

  viAlias = true;
  withNodeJs = true;
  vimdiffAlias = true;
}
