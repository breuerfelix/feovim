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
      with config; {
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
              customRC = neovimConfig;
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
