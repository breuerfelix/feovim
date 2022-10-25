{
  description = "feovim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    # define plugin sources from git or use package from nixpkgs instead
    "earthly-vim" = { url = "github:earthly/earthly.vim"; flake = false; };
    #"black-nvim" = { url = "github:averms/black-nvim"; flake = false; };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    { } //
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };

        config = import ./config.nix { inherit pkgs; };

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
      with config; with pkgs; rec {
        overlay = final: prev: {
          neovim = self.packages.${prev.system}.default;
        };

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
              start = pluginMapper startPlugins ++ [
                # TODO put this into overlay / config.nix
                (nvim-treesitter.withPlugins (plugins: tree-sitter.allGrammars))
              ];
              opt = pluginMapper optPlugins;
            };
          };
        };
      }
    );
}
