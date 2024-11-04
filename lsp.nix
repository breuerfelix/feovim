{ pkgs, unstable, ... }: {
  binaries = with pkgs; [
    nil # nix
    terraform-ls
    terraform
    tflint
    pyright
    unstable.deno # currently broken with preact
    nodePackages."@prisma/language-server"
    nodePackages.bash-language-server
    dockerfile-language-server-nodejs
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

          local lspconfig = require('lspconfig')

          -- Add cmp_nvim_lsp capabilities settings to lspconfig
          -- This should be executed before you configure any language server
          local lspconfig_defaults = lspconfig.util.default_config
          lspconfig_defaults.capabilities = vim.tbl_deep_extend(
            'force',
            lspconfig_defaults.capabilities,
            vim.lsp.protocol.make_client_capabilities(),
            require('cmp_nvim_lsp').default_capabilities()
          )

          -- TODO
          --nmap('<leader>rd', vim.diagnostic.open_float, opts)
          --nmap('<leader>rl', vim.diagnostic.setloclist, opts)
          --nmap('<leader>rk', vim.diagnostic.goto_prev, opts)
          --nmap('<leader>rj', vim.diagnostic.goto_next, opts)

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

              vim.keymap.set('n', '<leader>ff', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
              vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
              vim.keymap.set('n', '<leader>ra', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
            end,
          })

          local servers = {
            prismals = {},
            gopls = {},
            golangci_lint_ls = {},
            bashls = {},
            nil_ls = {},
            terraformls = {},
            tflint = {},
            marksman = {},
            dockerls = {},
            rust_analyzer = {},
            jsonnet_ls = {},
            ruff = {},
            pyright = {},
            denols = {
              -- prevents clashing with tsserver
              root_dir = lspconfig.util.root_pattern('deno.json', 'deno.jsonc'),
            },
            ts_ls = {
              -- prevents clashing with tsserver
              root_dir = lspconfig.util.root_pattern('package.json', 'tsconfig.json', 'jsconfig.json'),
              single_file_support = false,
            },
          }

          for key, value in pairs(servers) do
            lspconfig[key].setup(value)
          end

          -- codelens
          -- TODO: test this
          vim.api.nvim_create_autocmd({"BufEnter", "CursorHold", "InsertLeave"}, {
            buffer = 0,
            callback = function(event)
              vim.lsp.codelens.refresh({ bufnr = event.buf })
            end
          })

          -- inlay hints
          -- TODO: test this
          vim.api.nvim_create_autocmd('LspAttach', {
            desc = 'Inlay Hints',
            callback = function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)

              if client.supports_method("textDocument/inlayHint") or client.server_capabilities.inlayHintProvider then
                vim.lsp.inlay_hint(args.buf, true)
              end
            end,
          })
        end,
      },
    '';
}
