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

          require('nvim-tree').setup {
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
