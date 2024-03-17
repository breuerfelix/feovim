-- nvim-cmp
vim.o.completeopt = 'menu,menuone,noselect'

local cmp = require('cmp')
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-u>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'path' },
    { name = 'cmp_git' },
  },
})

-- cmp sources
require('cmp_git').setup() -- requires github cli

-- lspconfig
-- updates while typing
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
  update_in_insert = true,
})

local opts = { noremap = true, silent = true }
nmap('<leader>rd', vim.diagnostic.open_float, opts)
nmap('<leader>rl', vim.diagnostic.setloclist, opts)
nmap('<leader>rk', vim.diagnostic.goto_prev, opts)
nmap('<leader>rj', vim.diagnostic.goto_next, opts)

local lsp_signature = require('lsp_signature')
local on_attach = function(_, bufnr)
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  local bopts = { noremap = true, silent = true, buffer = bufnr }
  nmap('gD', vim.lsp.buf.declaration, bopts)
  nmap('gd', vim.lsp.buf.definition, bopts)
  nmap('gt', vim.lsp.buf.type_definition, bopts)
  nmap('gr', vim.lsp.buf.references, bopts)
  nmap('gi', vim.lsp.buf.implementation, bopts)

  nmap('<leader>f', function() vim.lsp.buf.format { async = true } end, bopts)

  nmap('<leader>rn', vim.lsp.buf.rename, bopts)
  nmap('<leader>ra', vim.lsp.buf.code_action, bopts)
  nmap('<leader>rh', vim.lsp.buf.hover, bopts)
  nmap('<leader>rs', vim.lsp.buf.signature_help, bopts)

  lsp_signature.on_attach({
    hint_enable = true,
    hint_prefix = "arg - ",
    bind = true,
    handler_opts = {
      border = "single",
    },
  }, bufnr)
end

-- highlight deno codefences
vim.g.markdown_fenced_languages = {
  "ts=typescript"
}

local lspconfig = require('lspconfig')
local servers = {
  prismals = {},
  gopls = {},
  nil_ls = {},
  terraformls = {},
  texlab = {},
  pyright = {},
  rust_analyzer = {},
  kotlin_language_server = {},
  jsonnet_ls = {},
  denols = {
    -- prevents clashing with tsserver
    root_dir = lspconfig.util.root_pattern('deno.json', 'deno.jsonc'),
  },
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT', },
        diagnostics = { globals = { 'vim' }, },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
        },
        telemetry = { enable = false, },
      },
    },
  },
}

local caps = vim.lsp.protocol.make_client_capabilities()
local capabilities = require('cmp_nvim_lsp').default_capabilities(caps)

for key, value in pairs(servers) do
  lspconfig[key].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = value.settings,
    cmd = value.cmd,
    root_dir = value.root_dir,
  }
end
