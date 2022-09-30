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
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ['<C-j>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-k>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
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

local function keymap(...) vim.keymap.set('n', ...) end

local opts = { noremap = true, silent = true }
keymap('<leader>rd', vim.diagnostic.open_float, opts)
keymap('<leader>rk', vim.diagnostic.goto_prev, opts)
keymap('<leader>rj', vim.diagnostic.goto_next, opts)
keymap('<leader>rl', vim.diagnostic.setloclist, opts)

local lsp_signature = require('lsp_signature')
local on_attach = function(_, bufnr)
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  local bopts = { noremap = true, silent = true, buffer = bufnr }
  keymap('gD', vim.lsp.buf.declaration, bopts)
  keymap('gd', vim.lsp.buf.definition, bopts)
  keymap('gt', vim.lsp.buf.type_definition, bopts)
  keymap('gr', vim.lsp.buf.references, bopts)
  keymap('gi', vim.lsp.buf.implementation, bopts)

  keymap('<leader>f', vim.lsp.buf.formatting, bopts)

  keymap('<leader>rn', vim.lsp.buf.rename, bopts)
  keymap('<leader>ra', vim.lsp.buf.code_action, bopts)
  keymap('<leader>rh', vim.lsp.buf.hover, bopts)
  keymap('<leader>rs', vim.lsp.buf.signature_help, bopts)

  lsp_signature.on_attach({
    hint_enable = false,
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
  denols = {
    root_dir = lspconfig.util.root_pattern('deno.json', 'deno.jsonc'),
  },
  prismals = {},
  gopls = {},
  rnix = {},
  terraformls = {},
  texlab = {},
  pyright = {},
  rust_analyzer = {},
  sumneko_lua = {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT', },
        diagnostics = { globals = { 'vim' }, },
        workspace = {
          library = vim.api.nvim_get_runtime_file('', true),
        },
        telemetry = { enable = false, },
      },
    },
  },
}

local caps = vim.lsp.protocol.make_client_capabilities()
local capabilities = require('cmp_nvim_lsp').update_capabilities(caps)

for key, value in pairs(servers) do
  lspconfig[key].setup {
    on_attach = on_attach,
    flags = { debounce_text_changes = 150 }, -- default in 0.7
    capabilities = capabilities,
    settings = value.settings,
    cmd = value.cmd,
  }
end
