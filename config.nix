{ pkgs, unstable, plugin }: {
  # binaries that should be added to neovims PATH
  extraPackages = with pkgs; [
    # utilities
    git
    lazygit
  ];

  # plugins loaded at start
  startPlugins = with pkgs.vimPlugins; [
    which-key-nvim

    # syntax highlighting
    rainbow-delimiters-nvim # bracket highlighting
    nvim-lint
    delimitMate # auto bracket
    editorconfig-vim
    vim-helm


    # navigation
    hop-nvim
    leap-nvim
    clever-f-vim
    (plugin "whaler")

    diffview-nvim

  ];

  # plugins loaded optionally
  optPlugins = [ ];

  neovimConfig = with pkgs.lib.strings; builtins.concatStringsSep "\n" [
    (fileContents ./base.vim)
    #(fileContents ./theme.vim)
    #(fileContents ./plugins.vim)

    #${fileContents ./utils.lua}
    #  ${fileContents ./plugins.lua}
    #  ${fileContents ./lsp.lua}
    #  ${fileContents ./debug.lua}
    ''
      lua << EOF
      --local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      --vim.opt.rtp:prepend(lazypath)
      vim.g.mapleader = " "
      vim.g.maplocalleader = "\\"
      require("lazy").setup({
        rocks = { enabled = false },
        change_detection = { enabled = false },
        spec = {
          {
            dir = "${pkgs.vimPlugins.nvim-cursorline}",
            name = "nvim-cursorline",
            even = "VeryLazy",
            opts = {},
          },
        },
      })
      EOF
    ''
  ];
}

