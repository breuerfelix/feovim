{
  description = "feovim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    # define plugin sources here
    "which-key" = { url = "github:folke/which-key.nvim"; flake = false; };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # define packages that need to be available in the neovim path
        extraPackages = with pkgs; [
          tree-sitter
          jq
          curl # rest.nvim
          bat
          ripgrep
          fd
          fzf # fzf
          nodejs # github copilot
          universal-ctags # vista

          # extra language servers
          rnix-lsp
          #terraform-ls terraform-lsp # TODO fix
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
          "which-key"
        ];

        # plugins loaded optionally
        optPlugins = [ ];

        pkgs = nixpkgs.legacyPackages.${system};
        # installs a vim plugin from git
        plugin = repo: pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = "${pkgs.lib.strings.sanitizeDerivationName repo}";
          version = "main";
          src = builtins.getAttr repo inputs;
        };
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
              packages.myVimPackage = {
                start = map (name: (plugin name)) startPlugins;
                opt = map (name: (plugin name)) optPlugins;
              };
            };
          };
        };

      }
    );
}
