{ pkgs, unstable, plugin, ... }: {
  binaries = with pkgs; [
    black
    ruff
    isort
    nodePackages.prettier
    nixfmt-rfc-style
  ];

  lazy = with pkgs.vimPlugins;
    # lua
    ''
      {
        dir = "${conform-nvim}",
        name = "conform",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        keys = {
          {
            "<leader>f",
            function()
              require("conform").format({ async = true })
            end,
            mode = "",
            desc = "Format buffer",
          },
        },
        ---@module "conform"
        ---@type conform.setupOpts
        opts = {
          formatters_by_ft = {
            python = { "isort", "black", "ruff_fix", "ruff_format" },
            javascript = { "prettier" },
            nix = { "nixfmt" },
          },
          default_format_opts = {
            lsp_format = "fallback",
          },
          -- Set up format-on-save
          -- format_on_save = { timeout_ms = 500 },
        },
      },
    '';
}
