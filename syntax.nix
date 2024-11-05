{ pkgs, ... }: {
  binaries = with pkgs; [
    tree-sitter
  ];

  lazy = with pkgs.vimPlugins; let
    grammarsPath = pkgs.symlinkJoin {
      name = "nvim-treesitter-parsers";
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
        dir = "${nvim-treesitter}",
        name = "nvim-treesitter",
        config = function ()
          vim.opt.runtimepath:prepend("${grammarsPath}")
          require("nvim-treesitter.configs").setup {
            -- they are managed by nix
            auto_install = false,

            highlight = {
              enable = true,
              additional_vim_regex_highlighting = false,
            },
            indent = { enable = true },
          }
        end
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
        dir = "${leap-nvim}",
        name = "leap",
        -- plugin lazy loads itself
        config = function ()
          vim.keymap.set('n', 's', '<Plug>(leap)')
          vim.keymap.set('n', 'S', '<Plug>(leap-from-window)')
        end
      },
      {
        dir = "${whitespace-nvim}",
        name = "whitespace",
        event = "VeryLazy",
        config = function ()
          local whitespace = require("whitespace-nvim")
          whitespace.setup({
            ignored_filetypes = {
              'TelescopePrompt',
              -- ignore results aswell for smart-open
              -- https://github.com/johnfrankmorgan/whitespace.nvim/issues/14
              'TelescopeResults',
              -- trailing whitespace is used for linebreaks
              'markdown',
              'Trouble',
              'help',
              'dashboard',
            },
          })

          vim.keymap.set('n', '<Leader>t', whitespace.trim)
        end
      },
    '';
}
