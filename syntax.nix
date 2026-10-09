{ pkgs, ... }: {
  # tree-sitter binary is not needed
  binaries = [];

  lazy = with pkgs.vimPlugins; let
    grammarsPath = pkgs.symlinkJoin {
      name = "nvim-treesitter-grammars";
      paths = nvim-treesitter.withAllGrammars.dependencies;
    }; in
    # lua
    ''
      {
        dir = "${catppuccin-nvim}",
        name = "catppuccin",
        priority = 1000,
        config = function ()
          require("catppuccin").setup({
            flavour = "mocha",
            dim_inactive = {
              enabled = true,
            },
          })

          vim.cmd.colorscheme("catppuccin")
        end
      },
      {
        dir = "${grammarsPath}",
        name = "treesitter-grammars",
        lazy = false,
        priority = 1000,
        config = function ()
          vim.opt.runtimepath:append("${grammarsPath}")

          vim.api.nvim_create_autocmd("FileType", {
            callback = function(ev)
              pcall(vim.treesitter.start, ev.buf)
            end,
          })
          if vim.bo.filetype ~= "" then
            pcall(vim.treesitter.start)
          end
        end,
      },
      {
        -- TODO: check if this can be lazy loaded
        dir = "${nvim-cursorline}",
        name = "nvim-cursorline",
        opts = {},
      },
      {
        dir = "${indent-blankline-nvim}",
        name = "indent-blankline",
        main = "ibl",
        event = "VeryLazy",
        ---@module "ibl"
        ---@type ibl.config
        opts = {},
      },
      {
        dir = "${gitsigns-nvim}",
        name = "gitsigns",
        event = "VeryLazy",
        opts = {
          current_line_blame = true,
        },
      },
      {
        dir = "${vim-sleuth}",
        name = "sleuth",
      },
      {
        dir = "${whitespace-nvim}",
        name = "whitespace",
        event = "VeryLazy",
        config = function ()
          local whitespace = require("whitespace-nvim")
          whitespace.setup()
          vim.keymap.set('n', '<Leader>t', whitespace.trim)
        end
      },
    '';
}
