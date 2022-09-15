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
        extraPackages = with pkgs; [
          #nixfmt
        ];

        startPlugins = [
          "which-key"
        ];

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

        packages = rec {
          default = feovim;
          feovim = pkgs.wrapNeovim pkgs.neovim-unwrapped {
            viAlias = true;
            vimAlias = true;
            #withNodesJs = true; # TODO why is this one unexpected?
            withPython3 = true;
            withRuby = true;
            extraMakeWrapperArgs = ''--prefix PATH : "${pkgs.lib.makeBinPath extraPackages}"'';
            configure = {
              customRC = "";
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
