{ pkgs, plugin }: {
  # binaries that should be added to neovims PATH
  extraPackages = with pkgs; [
    # utilities
    git
    tree-sitter

    # rest.nvim
    jq # formats json
    html-tidy # formats html
    curl

    bat
    ripgrep
    fd
    fzf
    universal-ctags # vista
    gh # github cli for cmp_git

    # language servers
    nil # nix
    terraform-ls
    terraform
    tflint
    deno
    nodePackages."@prisma/language-server"
    nodePackages.bash-language-server
    dockerfile-language-server-nodejs
    gopls
    golangci-lint-langserver
    golangci-lint
    marksman
    nodePackages.pyright
    rust-analyzer
    sumneko-lua-language-server
    jsonnet-language-server

    # debugging
    delve # golang
  ];

  # plugins loaded at start
  startPlugins = with pkgs.vimPlugins; [
    which-key-nvim
    nvim-lspconfig

    # completion
    nvim-cmp
    cmp-nvim-lsp
    cmp-path
    cmp-git
    lsp_signature-nvim
    copilot-lua
    copilot-cmp

    # snippets are needed for many language servers
    cmp-vsnip
    vim-vsnip
    friendly-snippets # snippet collection for all languages

    # syntax highlighting
    nvim-treesitter.withAllGrammars
    rainbow-delimiters-nvim # bracket highlighting
    nvim-treesitter-context
    nvim-lint
    delimitMate # auto bracket
    editorconfig-vim
    (plugin "earthly-vim") # built from inputs
    vim-helm
    spellsitter-nvim # spellchecker for comments
    vim-illuminate # highlight other words under cursor

    # utilities
    plenary-nvim
    telescope-nvim
    nvim-web-devicons

    # navigation
    hop-nvim
    clever-f-vim
    nvim-tree-lua
    vista-vim
    todo-comments-nvim

    # highlights current variable with underline
    nvim-cursorline
    gitsigns-nvim
    indent-blankline-nvim

    # bars
    lualine-nvim
    bufferline-nvim
    vim-bufkill

    # fzf
    fzf-lua
    nvim-fzf

    nvim-colorizer-lua
    vim-fugitive
    diffview-nvim

    # wildmenu for commands
    wilder-nvim

    vim-sleuth
    nerdcommenter
    emmet-vim

    # examples: https://github.com/rest-nvim/rest.nvim/tree/main/tests
    rest-nvim # http client

    tagalong-vim
    codi-vim

    # debugging
    nvim-dap

    # diagnostics
    vim-startuptime

    # colorschemes
    tokyonight-nvim
    (plugin "github-nvim-theme")
  ];

  # plugins loaded optionally
  optPlugins = [ ];

  neovimConfig = with pkgs.lib.strings; builtins.concatStringsSep "\n" [
    (fileContents ./base.vim)
    (fileContents ./theme.vim)
    (fileContents ./plugins.vim)
    ''
      lua << EOF
      ${fileContents ./utils.lua}
      ${fileContents ./plugins.lua}
      ${fileContents ./lsp.lua}
      ${fileContents ./debug.lua}

      -- defined here in order to specify typescript lib path
      lspconfig.tsserver.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        -- prevents clashing with denols
        single_file_support = false,
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

