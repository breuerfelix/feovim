{ pkgs, unstable, plugin, ... }: {
  binaries = with pkgs; [
    nil # nix
    terraform-ls
    terraform
    tflint
    pyright
    unstable.deno # currently broken with preact
    bash-language-server
    dockerfile-language-server
    gopls
    golangci-lint-langserver
    golangci-lint
    marksman # markdown
    rust-analyzer
    jsonnet-language-server
    typescript-language-server
    typescript
    ruff # python
  ];

  lazy = with pkgs.vimPlugins;
    # lua
    ''
      {
        dir = "${nvim-lspconfig}",
        name = "nvim-lspconfig",
        -- TODO: get it working with BufReadPost and BufWritePost
        event = { "BufReadPre", "BufWritePre", "BufNewFile" },
        config = function ()
          -- Reserve a space in the gutter
          vim.opt.signcolumn = 'yes'

          -- Add cmp_nvim_lsp capabilities settings globally to all LSP servers
          vim.lsp.config('*', {
            capabilities = vim.tbl_deep_extend(
              'force',
              vim.lsp.protocol.make_client_capabilities(),
              require('cmp_nvim_lsp').default_capabilities()
            ),
          })

          -- keybindings
          vim.api.nvim_create_autocmd('LspAttach', {
            desc = 'LSP actions',
            callback = function(event)
              local opts = {buffer = event.buf}

              vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
              vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
              vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
              vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
              vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
              vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
              vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)

              -- native inlay hints
              if vim.lsp.inlay_hint then
                vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
              end
              vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
              vim.keymap.set('n', '<leader>ra', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
            end,
          })

          vim.lsp.config('nil_ls', {
            settings = {
              ['nil'] = {
                nix = {
                  flake = {
                    autoArchive = false,
                  },
                },
              },
            },
          })

          local servers = {
            'gopls',
            'golangci_lint_ls',
            'bashls',
            'nil_ls',
            'terraformls',
            'tflint',
            'marksman',
            'dockerls',
            'rust_analyzer',
            'jsonnet_ls',
            'ruff',
            'pyright',
            'gdscript',
            'denols',
            'ts_ls',
          }

          for _, server in ipairs(servers) do
            vim.lsp.enable(server)
          end

        end,
      },
    '';
}
