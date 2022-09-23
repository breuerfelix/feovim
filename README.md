# feovim

This is my customized neovim with language servers and configuration already applied.

## Usage

If this repo is cloned locally:
```bash
nix run .#
```

Run anywhere (if nix is installed):
```bash
nix run github:breuerfelix/feovim# .
```

Used as a package:
```nix
# inputs from flakes
{ inputs, ... }: {
  nixpkgs.overlays = [
    (self: super: {
      neovim = inputs.feovim.packages.${self.system}.default;
    })
  ];
}
```

## Update Plugins

```bash
nix flake update
```

# Make it your own

You can use this boilerplate code and fill out your config, plugins and binaries that should be added to the path.  
If you want to create your own, make sure to have a git repository and stage / commit all files.  
Nix flakes behave strange on unstaged files.

```nix
{
  description = "Neovim Template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    # all plugins that are not present in nixpkgs.vimPlugins need to be added here
    # they get directly fetched from git and build on the fly
    "earthly-vim" = { url = "github:earthly/earthly.vim"; flake = false; };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          # enable all packages
          config = { allowUnfree = true; };
        };

        # define packages that need to be available in the neovim path
        # for example language servers
        extraPackages = with pkgs; [
          # utilities
          tree-sitter

          # language servers
          rnix-lsp
        ];

        # plugins loaded at start
        startPlugins = [
          "nvim-lspconfig" # will be used from pkgs.vimPlugins
          "earthly-vim" # will be built on the fly from inputs
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
      rec {
        apps = {
          default = flake-utils.lib.mkApp {
            drv = packages.default;
            exePath = "/bin/nvim";
          };
        };

        packages = with pkgs; {
          default = wrapNeovim neovim-unwrapped {
            viAlias = true;
            vimAlias = true;
            withPython3 = true;
            withNodeJs = true;
            withRuby = true;
            extraMakeWrapperArgs = ''--prefix PATH : "${lib.makeBinPath extraPackages}"'';
            configure = {
              # import your individual vim config files here
              # you can import from files
              # or directly add the config here as a string
              customRC = builtins.concatStringsSep "\n" [
                (lib.strings.fileContents ./config.vim)
                ''
                  lua << EOF
                  -- if you have some lua config
                  ${lib.strings.fileContents ./config.lua}
                  EOF
                ''
                ''
                  " you can also directly write your configuration here
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
```

## Philosophy

The philosophy behind this flake configuration is to allow for easily configurable and reproducible neovim environments. Enter a directory and have a ready to go neovim configuration that is the same on every machine. Whether you are a developer, writer, or live coder, quickly craft a config that suits every project's need. Think of it like a distribution of Neovim that takes advantage of pinning vim plugins and third party dependencies (such as tree-sitter grammars, language servers, and more).

As a result, one should never get a broken config when setting options. If setting multiple options results in a broken neovim, file an issue! Each plugin knows when another plugin which allows for smart configuration of keybindings and automatic setup of things like completion sources and languages.

