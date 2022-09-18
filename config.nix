{ pkgs }: {
  # binaries that should be added to neovims PATH
  extraPackages = with pkgs; [
    # utilities
    tree-sitter
    jq
    curl # rest.nvim
    bat
    ripgrep
    fd
    fzf # fzf
    nodejs # github copilot
    universal-ctags # vista

    # language servers
    rnix-lsp
    #terraform-ls # FIX fix build
    #terraform-lsp # FIX fix build
    nodePackages.typescript
    nodePackages.typescript-language-server
    gopls
    texlab
    nodePackages.pyright
    black
    rust-analyzer

    # debugging
    delve # golang
  ];

  # plugins loaded at start
  startPlugins = [
    "which-key-nvim"
    "nvim-lspconfig"

    # completion
    "nvim-cmp"
    "cmp-nvim-lsp"
    "cmp-path"
    #"cmp-buffer"
    #"cmp-nvim-lsp-document-symbol" # TODO fix it
    "cmp-git"

    # snippets are needed for many language servers
    "cmp-vsnip"
    "vim-vsnip"
    "friendly-snippets" # snippet collection for all languages

    "delimitMate" # auto bracket
    # FIX this
    #"lsp_extensions-nvim" # rust inline hints
    "lsp_signature-nvim"

    # syntax highlighting
    #"nvim-treesitter" # this package is overlayed with all grammar
    "nvim-ts-rainbow" # bracket highlighting
    #"nvim-treesitter-context" # FIX
    "editorconfig-vim"
    "earthly-vim"
    "vim-helm"
    "spellsitter-nvim" # spellchecker for comments

    # utilities
    #"popup-nvim"
    "plenary-nvim"
    "telescope-nvim"
    "nvim-web-devicons"

    # navigation
    "vim-easymotion"
    "clever-f-vim"
    "nvim-tree-lua"
    "vista-vim"
    "todo-comments-nvim"

    # highlights current variable with underline
    "nvim-cursorline"
    "gitsigns-nvim"
    "indent-blankline-nvim"

    # bars
    "lualine-nvim"
    "nvim-gps" # shows code context
    "bufferline-nvim"
    "vim-bufkill"

    # fzf
    "fzf-lua"
    "nvim-fzf"

    "vimux"

    "nvim-colorizer-lua"
    "vim-fugitive"
    "diffview-nvim"

    # wildmenu for commands
    "wilder-nvim"

    "vim-sleuth"
    "vim-smoothie"
    "nerdcommenter"
    "emmet-vim"

    "tagalong-vim"
    "codi-vim"

    # formatters
    # TODO fix this
    #"black"

    # debugging
    "nvim-dap"

    #"copilot-vim"

    # TODO lazyload
    "vimwiki"
    #vim-grammarous
    #"vim-startuptime"
    #goyo-vim
    #limelight-vim
    #"rest.nvim" # http client

    # colorschemes
    "tokyonight-nvim"
    "kanagawa-nvim"
    "ayu-vim"
  ];

  # plugins loaded optionally
  optPlugins = [ ];

  neovimConfig = with pkgs.lib.strings; builtins.concatStringsSep "\n" [
    (fileContents ./base.vim)
    (fileContents ./plugins.vim)
    (fileContents ./lsp.vim)
    ''
      lua << EOF
      ${fileContents ./plugins.lua}
      ${fileContents ./lsp.lua}
      ${fileContents ./debug.lua}
      EOF
    ''
  ];
}

