{ pkgs, plugin, ... }: {
  binaries = with pkgs; [
    ripgrep
    fd
    sqlite # smart-open
  ];

  lazy = with pkgs.vimPlugins;
    # lua
    ''
      {
        dir = "${plenary-nvim}",
        name = "plenary",
        lazy = true,
      },
      {
        dir = "${telescope-nvim}",
        name = "telescope",
        event = "VeryLazy",
        dependencies = {
          {
            dir = "${plugin("whaler")}",
            name = "whaler",
          },
          {
            dir = "${telescope-fzy-native-nvim}",
            name = "fzy-native",
          },
          -- smart-open
          {
            dir = "${sqlite-lua}",
            name = "sqlite",
          },
          {
            dir = "${smart-open-nvim}",
            name = "smart-open",
          },
        },
        event = "VeryLazy",
        config = function ()
          local telescope = require('telescope')
          telescope.setup({
            pickers = {
              find_files = {
                hidden = true
              },
              grep_string = {
                additional_args = { '--hidden' }
              },
              live_grep = {
                additional_args = { '--hidden' },
                file_ignore_patterns = { '.git/' }
              }
            },
            extensions = {
              whaler = {
                directories = {
                  { path = "~/code", alias = "code" },
                  { path = "~/code/github", alias = "github" },
                  { path = "~/code/rtl/pspdx", alias = "devx" },
                  { path = "~/code/rtl/contract", alias = "contract" },
                  { path = "~/code/rtl/systemssq", alias = "systems" },
                },
                file_explorer = "nvimtree",
              }
            }
          })

          telescope.load_extension("fzy_native")

          local builtin = require('telescope.builtin')
          -- using smart_open instead
          --vim.keymap.set('n', ';', builtin.find_files, { desc = 'Telescope find files' })
          vim.keymap.set('n', '<leader>s', builtin.live_grep, { desc = 'Telescope live grep' })
          vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
          vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

          telescope.load_extension("whaler")
          vim.keymap.set("n", "<leader>p", telescope.extensions.whaler.whaler)

          telescope.load_extension("smart_open")
          vim.keymap.set("n", ";", function () telescope.extensions.smart_open.smart_open({ cwd_only = true }) end)
        end
      },
    '';
}
