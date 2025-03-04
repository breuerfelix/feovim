{ pkgs, ... }: {
  binaries = [];
  lazy = with pkgs.vimPlugins;
    # lua
    ''
      {
        dir = "${nvim-tree-lua}",
        name = "nvim-tree",
        config = function ()
          -- disable netrw at the very start of your init.lua
          vim.g.loaded_netrw = 1
          vim.g.loaded_netrwPlugin = 1
          -- set colors
          vim.opt.termguicolors = true

          local function on_attach(bufnr)
            local api = require "nvim-tree.api"

            local function opts(desc)
              return {
                desc = "nvim-tree: " .. desc,
                buffer = bufnr,
                noremap = true,
                silent = true,
                nowait = true,
              }
            end

            -- default mappings
            api.config.mappings.default_on_attach(bufnr)

            vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
            -- collides with closing vim keybind
            vim.keymap.set("n", "<C-e>", "<cmd>:q<cr>", opts("Quit"))
          end

          require('nvim-tree').setup {
            on_attach = on_attach,
            sync_root_with_cwd = true,
            git = {
              ignore = true,
            },
          }

          vim.keymap.set('n', '<leader>a', '<cmd>:NvimTreeToggle<cr>', opts)
        end
      },
    '';
}
