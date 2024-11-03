{ pkgs, ... }: {
  binaries = [];
  lazy = with pkgs.vimPlugins;
    # lua 
    ''
      {
        dir = "${nvim-web-devicons}",
        name = "nvim-web-devicons",
        lazy = true,
      },
      {
        dir = "${lualine-nvim}",
        name = "lualine",
        event = "VeryLazy",
        opts = {
          options = {
            -- gets set automatically
            -- theme = 'tokyonight',
            -- disable powerline
            section_separators = "",
            component_separators = "",
          },
        },
      },
      {
        dir = "${noice-nvim}",
        name = "noice nvim",
        event = "VeryLazy",
        dependencies = {
          {
            dir = "${nui-nvim}",
            name = "nui-nvim",
          },
        },
        config = function ()
          require("noice").setup({
            lsp = {
              -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
              override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
              },
            },
            -- you can enable a preset for easier configuration
            presets = {
              bottom_search = true, -- use a classic bottom cmdline for search
              command_palette = true, -- position the cmdline and popupmenu together
              long_message_to_split = true, -- long messages will be sent to a split
              lsp_doc_border = false, -- add a border to hover docs and signature help
            },
          })
        end
      },
      {
        dir = "${diffview-nvim}",
        name = "diffview",
        cmd = "DiffViewOpen",
      },
    '';
}
