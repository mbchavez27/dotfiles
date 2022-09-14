-- = = = = = =   = = = =  =       =
-- =   = =   =   =     =    =   =
-- =   = =   =   = = = =      = 
-- =         =   =     =    =   =
-- =         =   =     =  =       =

--Vim Configs
local set = vim.opt 

set.number = true
set.relativenumber = true
set.mouse = "a"
set.clipboard = "unnamedplus"
set.background = "dark"
set.termguicolors = true
set.ignorecase = true 
set.completeopt = {'menu', 'menuone', 'noselect'}


--Plugins Configs
--Start Screen
require'alpha'.setup(require'alpha.themes.startify'.config)

--File Explorer
require("nvim-tree").setup({
    view = {
        side = 'right'
    }
    }
)

--Colorizer
require'colorizer'.setup({
	'*';
	css = {names = true;};
	html = {names = true;};
})

--Color Picker
require("color-picker").setup({ -- for changing icons & mappings
	-- ["icons"] = { "ﱢ", "" },
	-- ["icons"] = { "ﮊ", "" },
	-- ["icons"] = { "", "ﰕ" },
	-- ["icons"] = { "", "" },
	["icons"] = { "", "" },
	-- ["icons"] = { "ﱢ", "" },
	["border"] = "rounded", -- none | single | double | rounded | solid | shadow
	["keymap"] = { -- mapping example:
		["U"] = "<Plug>ColorPickerSlider5Decrease",
		["O"] = "<Plug>ColorPickerSlider5Increase",
	},
})
vim.cmd([[hi FloatBorder guibg=NONE]])
--Comment
require('Comment').setup()

--Buffers
require("bufferline").setup{}

--Status Line 
require('lualine').setup()
options = { theme = 'gruvbox' }

--Highlight Words and Lines 
require('nvim-cursorline').setup {
  cursorline = {
    enable = true,
    timeout = 0,
    number = false,
  },
  cursorword = {
    enable = true,
    min_length = 3,
    hl = { underline = true },
  }
}

--TreeSitter
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = false,
  }

}

--LSP Config
local lsp_defaults = {
  flags = {
    debounce_text_changes = 150,
  },
  capabilities = require('cmp_nvim_lsp').update_capabilities(
    vim.lsp.protocol.make_client_capabilities()
  ),
  on_attach = function(client, bufnr)
    vim.api.nvim_exec_autocmds('User', {pattern = 'LspAttached'})
  end
}

local lspconfig = require('lspconfig')
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

lspconfig.util.default_config = vim.tbl_deep_extend(
  'force',
  lspconfig.util.default_config,
  lsp_defaults
)

--Servers
--Web Development
lspconfig.tsserver.setup({
 autostart = true,
 on_attach = function(client)
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false
    end,
 capabilities = capabilities,
 root_dir = function(fname)    
        return vim.loop.cwd()
    end,
})
lspconfig.emmet_ls.setup({
 autostart = true,
 on_attach = on_attach,
 capabilities = capabilities,
})
lspconfig.html.setup {
 autostart = true,
 on_attach = function(client)
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false
    end,
 capabilities = capabilities,
}
lspconfig.cssls.setup {
 autostart = true,
 on_attach = function(client)
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false
    end,
 capabilities = capabilities,
}
lspconfig.eslint.setup {
 autostart = true,
 -- on_attach = function(client)
 --        client.resolved_capabilities.document_formatting = false
 --        client.resolved_capabilities.document_range_formatting = false
 --    end,
 -- capabilities = capabilities,
 -- root_dir = function(fname)   
 --        return vim.loop.cwd()
 --    end,
}
lspconfig.jsonls.setup {
 autostart = true,
 on_attach = function(client)
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false
    end,
 capabilities = capabilities,
}

--TUI Apps
lspconfig.rust_analyzer.setup({
 autostart = true,
 on_attach = function(client)
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false
    end,
 capabilities = capabilities,
})

--Machine Learning 
lspconfig.pyright.setup({
 autostart = true,
 capabilities = capabilities,
})

-- --KeyBinds
-- vim.api.nvim_create_autocmd('User', {
--   pattern = 'LspAttached',
--   desc = 'LSP actions',
--   callback = function()
--     local bufmap = function(mode, lhs, rhs)
--       local opts = {buffer = true}
--       vim.keymap.set(mode, lhs, rhs, opts)
--     end
--
--     -- Displays hover information about the symbol under the cursor
--     bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')
--
--     -- Jump to the definition
--     bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
--
--     -- Jump to declaration
--     bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')
--
--     -- Lists all the implementations for the symbol under the cursor
--     bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')
--
--     -- Jumps to the definition of the type symbol
--     bufmap('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')
--
--     -- Lists all the references
--     bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')
--
--     -- Displays a function's signature information
--     bufmap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>')
--
--     -- Renames all references to the symbol under the cursor
--     bufmap('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')
--
--     -- Selects a code action available at the current cursor position
--     bufmap('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')
--     bufmap('x', '<F4>', '<cmd>lua vim.lsp.buf.range_code_action()<cr>')
--
--     -- Show diagnostics in a floating window
--     bufmap('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')
--
--     -- Move to the previous diagnostic
--     bufmap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
--
--     -- Move to the next diagnostic
--     bufmap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')
--   end
-- })
--

--LSP Saga
local saga = require 'lspsaga'

saga.init_lsp_saga({})


--CMP
require('luasnip.loaders.from_vscode').lazy_load()

local cmp = require('cmp')
local luasnip = require('luasnip')

local select_opts = {behavior = cmp.SelectBehavior.Select}

cmp.setup({
snippet = {
  expand = function(args)
    luasnip.lsp_expand(args.body)
  end
},

sources = {
  {name = 'path'},
  {name = 'nvim_lsp'},
  {name = 'buffer'},
  {name = 'luasnip'},
  {name = 'orgmode' },
},

window = {
  documentation = cmp.config.window.bordered()
},

formatting = {
	  fields = {'menu', 'abbr', 'kind'},
  format = function(entry, item)
    local menu_icon = {
      nvim_lsp = 'λ',
      luasnip = '⋗',
      buffer = 'Ω',
      path = '🖫',
    }

    item.menu = menu_icon[entry.source.name]
    return item
  end,
 },
 mapping = {
  ['<CR>'] = cmp.mapping.confirm({select = true}),
  ['<Up>'] = cmp.mapping.select_prev_item(select_opts),
['<Down>'] = cmp.mapping.select_next_item(select_opts),

['<C-p>'] = cmp.mapping.select_prev_item(select_opts),
['<C-n>'] = cmp.mapping.select_next_item(select_opts),
['<C-u>'] = cmp.mapping.scroll_docs(-4),
['<C-f>'] = cmp.mapping.scroll_docs(4),
['<C-e>'] = cmp.mapping.abort(),

['<C-d>'] = cmp.mapping(function(fallback)
  if luasnip.jumpable(1) then
    luasnip.jump(1)
  else
    fallback()
  end
end, {'i', 's'}),

['<C-b>'] = cmp.mapping(function(fallback)
  if luasnip.jumpable(-1) then
    luasnip.jump(-1)
  else
    fallback()
  end
end, {'i', 's'}),

['<Tab>'] = cmp.mapping(function(fallback)
  local col = vim.fn.col('.') - 1

  if cmp.visible() then
    cmp.select_next_item(select_opts)
  elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
    fallback()
  else
    cmp.complete()
  end
end, {'i', 's'}),

['<S-Tab>'] = cmp.mapping(function(fallback)
  if cmp.visible() then
    cmp.select_prev_item(select_opts)
  else
    fallback()
  end
end, {'i', 's'}),
}
})


--CMP Comamand Line 
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

--Diagnostics
local sign = function(opts)
  vim.fn.sign_define(opts.name, {
    texthl = opts.name,
    text = opts.text,
    numhl = ''
  })
end

sign({name = 'DiagnosticSignError', text = '✘'})
sign({name = 'DiagnosticSignWarn', text = '▲'})
sign({name = 'DiagnosticSignHint', text = '⚑'})
sign({name = 'DiagnosticSignInfo', text = ''})

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = false,
  float = true,
})

--Windows with Borders
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
  vim.lsp.handlers.hover,
  {border = 'rounded'}
)

vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  {border = 'rounded'}
)

--Error Tabs
require("trouble").setup {}

--Format on Save
require("null-ls").setup({
    sources = {
        require("null-ls").builtins.formatting.eslint_d,
        require("null-ls").builtins.formatting.prettierd,
        require("null-ls").builtins.formatting.black,
	require("null-ls").builtins.formatting.rustfmt,
    },
})

--Terminal 
require("toggleterm").setup{}

--Git
require('gitsigns').setup()

--Zen mode
require("zen-mode").setup {
  }

--Ascii Image
require('image').setup {
  min_padding = 5,
  -- show_label = true,
  -- render_using_dither = true,
}
