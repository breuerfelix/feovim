{
  description = "feovim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    # define plugin sources here
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
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
            configure = {
              customRC = "";
            };
          };
        };

      }
    );
}
