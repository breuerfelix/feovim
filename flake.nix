{
  description = "feovim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    # define plugin sources from git or use package from nixpkgs instead
    "earthly-vim" = { url = "github:earthly/earthly.vim"; flake = false; };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # define packages that need to be available in the neovim path
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

        # installs a vim plugin from git
        plugin = with pkgs; repo: vimUtils.buildVimPluginFrom2Nix {
          pname = "${lib.strings.sanitizeDerivationName repo}";
          version = "main";
          src = builtins.getAttr repo inputs;
        };

        # uses plugin from vimPlugins or builds it from inputs if not found
        pluginMapper = with pkgs; plugins: map
          (name: if lib.hasAttr name vimPlugins then lib.getAttr name vimPlugins else (plugin name))
          plugins;
      in
      {
        apps = rec {
          default = nvim;
          nvim = flake-utils.lib.mkApp {
            drv = self.packages.${system}.default;
            exePath = "/bin/nvim";
          };
        };

        packages = with pkgs; rec {
          default = feovim;
          feovim = wrapNeovim neovim-unwrapped {
            viAlias = true;
            vimAlias = true;
            #withNodesJs = true; # TODO why is this one unexpected?
            withPython3 = true;
            withRuby = true;
            extraMakeWrapperArgs = ''--prefix PATH : "${lib.makeBinPath extraPackages}"'';
            configure = {
              # import your individual vim config files here
              customRC = builtins.concatStringsSep "\n" [
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
              packages.myVimPackage = with pkgs; {
                start = pluginMapper startPlugins;
                opt = pluginMapper optPlugins;
              };
            };
          };
        };

      }
    );
}
