{ pkgs, ... }: {
  binaries = with pkgs; [
    ripgrep
    curl
  ];

  lazy = with pkgs.vimPlugins;
    # lua
    ''
      {
        dir = "${codecompanion-nvim}",
        name = "codecompanion",
        opts = {},
        dependencies = {
          { dir = "${plenary-nvim}", name = "plenary" },
        },
      },
    '';
}
