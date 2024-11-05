{
  description = "feovim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # define plugin sources from git or use package from nixpkgs instead
    whaler = { url = "github:SalOrak/whaler"; flake = false; };
    inlay-hints = { url = "github:MysticalDevil/inlay-hints.nvim"; flake = false; };
  };

  outputs = { self, nixpkgs, flake-utils, nixpkgs-unstable, ... }@inputs:
    {
      overlay = final: prev: {
        neovim = self.packages.${prev.system}.default;
      };

      # home-manager module for IdeaVim + VSCode integration
      feovim = { config, lib, ... }: with lib; {
        options.feovim = {
          ideavim.enable = mkEnableOption "IntelliJ IDEA integration";
          vscode.enable = mkEnableOption "VSCode integration";
        };

        config = with config.feovim; {
          home.file = {
            ideavim = mkIf ideavim.enable {
              target = ".ideavimrc";
              # TODO auto import all .vim files
              text = fileContents ./base.vim;
            };

            vscode = mkIf vscode.enable {
              target = ".vscodevimrc";
              # TODO auto import all .vim files
              text = fileContents ./base.vim;
            };
          };
        };
      };
    } //
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };

        unstable = import nixpkgs-unstable { inherit system; };

        # installs a vim plugin from git
        plugin = with pkgs; repo: vimUtils.buildVimPlugin {
          pname = "${lib.strings.sanitizeDerivationName repo}";
          version = "main";
          src = builtins.getAttr repo inputs;
        };

        # TODO auto import all nix files except flake.nix itself
        files = [
          ./lsp.nix
          ./syntax.nix
          ./completion.nix
          ./ui.nix
          ./tree.nix
          ./telescope.nix
        ];
        plugins = map (name: import name { inherit pkgs plugin unstable; }) files;
        binaries = map (x: x.binaries) plugins;
        lazySpec = builtins.concatStringsSep "\n" (map (x: x.lazy) plugins);

      in
      with pkgs; rec {
        apps.default = flake-utils.lib.mkApp {
          drv = packages.default;
          exePath = "/bin/nvim";
        };

        packages.default = wrapNeovimUnstable neovim-unwrapped {
          viAlias = true;
          vimAlias = true;
          # use unique to filter out duplicates
          wrapperArgs = with lib; ''--prefix PATH : "${makeBinPath (lists.unique (lists.flatten binaries))}"'';
          # only lazy is needed, it handles the rest
          plugins = with pkgs.vimPlugins; [ lazy-nvim ];
          luaRcContent =
            # lua
            ''
              -- i want my basics to be in vimscript
              -- they are used by vscode and intellij aswell
              -- TODO auto import all .vim files
              vim.cmd([[
                ${builtins.readFile ./base.vim}
              ]])

              -- TODO: maybe also allow non lazy lua config?
              ${builtins.readFile ./base.lua}

              require("lazy").setup({
                -- disable all update / install features
                -- this is handled by nix
                rocks = { enabled = false },
                pkg = { enabled = false },
                install = { missing = false },
                change_detection = { enabled = false },
                spec = {
                  ${lazySpec}
                },
              })
            '';
        };
      }
    );
}
