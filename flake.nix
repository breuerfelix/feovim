{
  description = "feovim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    # define plugin sources from git or use package from nixpkgs instead
    earthly-vim = { url = "github:earthly/earthly.vim"; flake = false; };
    github-nvim-theme = { url = "github:projekt0n/github-nvim-theme"; flake = false; };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
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
              text = fileContents ./base.vim;
            };

            vscode = mkIf vscode.enable {
              target = ".vscodevimrc";
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

        # installs a vim plugin from git
        plugin = with pkgs; repo: vimUtils.buildVimPlugin {
          pname = "${lib.strings.sanitizeDerivationName repo}";
          version = "main";
          src = builtins.getAttr repo inputs;
        };

        config = import ./config.nix { inherit pkgs plugin; };
      in
      with config; with pkgs; rec {
        apps.default = flake-utils.lib.mkApp {
          drv = packages.default;
          exePath = "/bin/nvim";
        };

        packages.default = wrapNeovim neovim-unwrapped {
          viAlias = true;
          vimAlias = true;
          withNodeJs = true;
          withPython3 = true;
          withRuby = true;
          extraMakeWrapperArgs = ''--prefix PATH : "${lib.makeBinPath extraPackages}"'';
          configure = {
            customRC = neovimConfig;
            packages.myVimPackage = with vimPlugins; {
              start = startPlugins;
              opt = optPlugins;
            };
          };
        };
      }
    );
}
