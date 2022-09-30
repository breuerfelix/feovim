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
    universal-ctags # vista
    gh # github cli for cmp_git

    # language servers
    rnix-lsp
    terraform-ls
    deno
    nodePackages."@prisma/language-server"
    gopls
    texlab
    nodePackages.pyright
    rust-analyzer
    sumneko-lua-language-server

    # formatter
    #black

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
    "cmp-git"
    "lsp_signature-nvim"

    # snippets are needed for many language servers
    "cmp-vsnip"
    "vim-vsnip"
    "friendly-snippets" # snippet collection for all languages


    # syntax highlighting
    "nvim-ts-rainbow" # bracket highlighting
    "nvim-treesitter-context"
    "delimitMate" # auto bracket
    "editorconfig-vim"
    "earthly-vim"
    "vim-helm"
    "spellsitter-nvim" # spellchecker for comments
    "vim-illuminate" # highlight other words under cursor

    # utilities
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
    #"black-nvim" # FIX

    # debugging
    "nvim-dap"

    # could be lazy loaded
    "vimwiki"
    #"vim-grammarous"
    #"vim-startuptime"
    #"goyo-vim"
    #limelight-vim
    #"rest.nvim" # http client

    # colorschemes
    "tokyonight-nvim"
  ];

  # plugins loaded optionally
  optPlugins = [ ];

  neovimConfig = with pkgs.lib.strings; builtins.concatStringsSep "\n" [
    (fileContents ./base.vim)
    (fileContents ./plugins.vim)
    ''
      lua << EOF
      ${fileContents ./plugins.lua}
      ${fileContents ./lsp.lua}
      ${fileContents ./debug.lua}

      -- defined here in order to specify typescript lib path
      lspconfig.tsserver.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        -- prevents clashing with tsserver
        root_dir = lspconfig.util.root_pattern('package.json', 'tsconfig.json', 'jsconfig.json'),
        cmd = {
          '${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server',
          '--tsserver-path=${pkgs.nodePackages.typescript}/lib/node_modules/typescript/lib/',
          '--stdio',
        },
      }
      EOF
    ''
  ];
}

