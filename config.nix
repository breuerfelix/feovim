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
    #terraform-ls terraform-lsp # TODO fix build
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
    # TODO fix this
    #"lsp_extensions-nvim" # rust inline hints
    "lsp_signature-nvim"

    # syntax highlighting
    "nvim-treesitter"
    "nvim-ts-rainbow" # bracket highlighting
    #"nvim-treesitter-context" # TODO fix this
    "editorconfig-vim"
    "earthly-vim"
    "vim-helm"
    "spellsitter-nvim" # spellchecker for comments

    # utilities
    #"popup-nvim"
    "plenary-nvim"
    #"telescope-nvim"
    "nvim-web-devicons"

    # navigation
    "vim-easymotion"
    "clever-f-vim"
    "nvim-tree-lua"
    "vista-vim"

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
    #"vim-todo"
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

  neovimConfig = with pkgs; builtins.concatStringsSep "\n" [
    (lib.strings.fileContents ./base.vim)
    (lib.strings.fileContents ./plugins.vim)
    (lib.strings.fileContents ./lsp.vim)
    ''
      lua << EOF
      ${lib.strings.fileContents ./config.lua}
      ${lib.strings.fileContents ./lsp.lua}
      ${lib.strings.fileContents ./debug.lua}
      EOF
    ''
  ];
}

