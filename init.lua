-- ==================================================
-- Simpoir's unfriendly but convenient nvim config
--
-- For Neovim 0.7.0+
--
-- Copyright (c) 2019-2021 Simon Poirier
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice (including the next
-- paragraph) shall be included in all copies or substantial portions of the
-- Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.
-- ==================================================

local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local opt = vim.opt

----------------------------------------
-- Packages
----------------------------------------
local packs = {
	-- Appearance
	----------------------------------------
	"flazz/vim-colorschemes",
	"vim-airline/vim-airline",
	"vim-airline/vim-airline-themes",
	"kyazdani42/nvim-web-devicons",
	"mhinz/vim-signify", -- like gitgutter for all
	"liuchengxu/vim-which-key", -- the backslash menu
	"justincampbell/vim-eighties", -- auto 80col resizer
	"yggdroot/indentLine", -- show line indentation

	-- LSP and IDE lang stack
	----------------------------------------
	"williamboman/mason.nvim", -- lsp, dap, linter, formatter installer
	"williamboman/mason-lspconfig.nvim",
	"neovim/nvim-lspconfig", -- common configs for LSP
	"mfussenegger/nvim-dap", -- debug adapter protocol
	"nvim-lua/plenary.nvim", -- lua boilerplate, for null-ls
	"jose-elias-alvarez/null-ls.nvim", -- extra linting/formatting

	-- Coding
	----------------------------------------
	"mhinz/vim-startify",
	"embear/vim-localvimrc", -- .lvimrc support
	"janko-m/vim-test", -- generic test runner
	-- { 'jeetsukumaran/vim-python-indent-black', eager = true };
	"ray-x/lsp_signature.nvim", -- the nice floating preview with highlights
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-cmdline",
	"saadparwaiz1/cmp_luasnip",
	"L3MON4D3/LuaSnip",
	"hrsh7th/nvim-cmp",

	-- Syntax
	----------------------------------------
	"knatsakis/deb.vim", -- support for xz
	"dbeniamine/todo.txt-vim",
	"folke/trouble.nvim",
	"nvim-treesitter/nvim-treesitter",
	"nvim-treesitter/nvim-treesitter-textobjects",
	"andymass/vim-matchup",

	-- Edition
	----------------------------------------
	"tpope/vim-sleuth", -- auto shiftwidth
	"matze/vim-move", -- alt-arrow line moving
	"jqno/jqno-extractvariable.vim",
	"tpope/vim-surround",
	"tpope/vim-commentary",
	"windwp/nvim-autopairs", -- autoclose pairs
	"abecodes/tabout.nvim", -- jumps out of pairs

	-- Tooling
	----------------------------------------
	"nvim-telescope/telescope.nvim", -- like fzf, but lua
	"tpope/vim-obsession", -- auto session management
	"tpope/vim-fugitive", -- git commands
	"mhinz/vim-grepper", -- ag/rg/grep generic grepper
	"airblade/vim-rooter", -- autochdir to repo
	"junkblocker/patchreview-vim", -- side-by-side diff viewer
	"mbbill/undotree", -- visual undo tree
	"kopischke/vim-fetch", -- file:line remapper
	"kyazdani42/nvim-tree.lua", -- file tree
	"kyazdani42/nvim-web-devicons", -- file tree
	"majutsushi/tagbar", -- taglist panel
}
require("mmleroux.packman").setup(packs)

-- compat
opt.shell = "/bin/bash"

----------------------------------------
-- Look and feel
----------------------------------------
require("mmleroux.ui").setup({
	theme = "molokai",
})

vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		g.pyindent_open_paren = 4
	end,
})
-- autoclose tree with last buffer
vim.api.nvim_create_autocmd("BufEnter", {
	group = vim.api.nvim_create_augroup("NvimTreeClose", { clear = true }),
	callback = function()
		local layout = vim.api.nvim_call_function("winlayout", {})
		if
			layout[1] == "leaf"
			and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), "filetype") == "NvimTree"
			and layout[3] == nil
		then
			cmd("quit")
		end
	end,
})

opt.updatetime = 2000 -- time between keystrokes which is considered idle.
g.indentLine_char = "┊"
g.indentLine_concealcursor = "c"

----------------------------------------
-- Tooling
----------------------------------------
g.localvimrc_persistent = 1
g.localvimrc_name = { ".lvimrc", ".lvimrc.lua", "_vimrc_local.vim" }
g.rooter_change_directory_for_non_project_files = "current" -- soothes LSP in home dir
g.rooter_patterns = { ".git", ".bzr", "Makefile", "Cargo.toml" }
g.signify_vcs_cmds = { bzr = "bzr diff --diff-options=-U0 -- %f" }

require("nvim-tree").setup({
	view = {
		width = 30,
	},
	filters = {
		dotfiles = true,
	},
})
require("telescope").setup({
	defaults = {
		-- no_ignore_parent = true,
	},
})

----------------------------------------
-- LSP
----------------------------------------
require("mason-lspconfig").setup({
	automatic_installation = true,
})
require("mason").setup()
local lspconfig = require("lspconfig")
local lsp_caps = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
lspconfig.util.default_config["capabilities"] = lsp_caps
lspconfig.pylsp.setup({
	on_attach = function(client)
		client.resolved_capabilities.document_formatting = false
	end,
})
lspconfig.yamlls.setup({
	settings = {
		redhat = { telemetry = { enabled = false } },
		yaml = {
			schemas = {
				["https://cdn.jsdelivr.net/gh/techhat/openrecipeformat/schema.json"] = "*.orf.yml",
				["https://cdn.jsdelivr.net/gh/cappyzawa/concourse-pipeline-jsonschema@v6.5.0/concourse_jsonschema.json"] = "pipeline.yml",
			},
		},
	},
})

lspconfig.rust_analyzer.setup({
	-- capabilities = lsp_caps,
	settings = { ["rust-analyzer"] = { checkOnSave = { command = "clippy" } } },
})
lspconfig.sumneko_lua.setup({
	on_attach = function(client)
		client.resolved_capabilities.document_formatting = false
	end,
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
				},
				maxPreload = 10000,
				preloadFileSize = 10000,
			},
		},
	},
})

-- auto setup other installed servers
for _, srv in ipairs(require("mason-lspconfig").get_installed_servers()) do
	local loaded = lspconfig.util.available_servers()
	if not vim.tbl_contains(loaded, srv) then
		lspconfig[srv].setup({})
	end
end
-- lspconfig.ltex.setup({})
-- lspconfig.vimls.setup({})
-- lspconfig.gopls.setup({})

require("lsp_signature").setup({
	zindex = 1,
})

-- non-lsp lang bits
local nuls = require("null-ls")
nuls.setup({
	sources = {
		nuls.builtins.formatting.stylua,
		nuls.builtins.formatting.isort,
		-- method = nuls.builtins.formatting.yapf,
		nuls.builtins.formatting.black,
		nuls.builtins.diagnostics.fish,
		nuls.builtins.diagnostics.flake8,
		nuls.builtins.code_actions.shellcheck,
	},
})

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	virtual_text = false,
	underline = true,
	signs = true,
})
vim.api.nvim_create_autocmd("CursorHold", { callback = vim.diagnostic.open_float })
vim.api.nvim_create_autocmd("CursorHoldI", { callback = vim.lsp.buf.signature_help })

----------------------------------------
-- Pretty Mappings
----------------------------------------
fn["which_key#register"]("Leader", "g:lmap")
vim.api.nvim_set_keymap("n", "<leader>", "<cmd>WhichKey 'Leader'<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<leader>", "<cmd>WhichKeyVisual 'Leader'<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<leader>ev", "<Plug>(extractVariableVisual)", { noremap = true, silent = true })
g.lmap = {
	name = "Global",
	c = {
		name = "Cursor",
		b = { ":!xdg-open https://pad.lv/<cword>", "Launchpad Bug" },
	},
	d = {
		name = "Debug",
		b = { "luaeval('require\"dap\".toggle_breakpoint()')", "Break" },
		n = { "luaeval('require\"dap\".step_over()')", "Next" },
		x = { "luaeval('require\"dap\".repl.open()')", "Eval" },
		c = { "luaeval('require\"dap\".continue()')", "Continue" },
		t = { "v:lua.DbgRustTests()", "Debug tests" },
	},
	f = {
		name = "Files",
		a = { "v:lua.Alternate()", "jump to Alternate file." },
		c = { "v:lua.BufGone()", "Close buffer and switch to next" },
		d = { ":e $MYVIMRC", "Open dotfile" },
		f = { ":Telescope find_files", "Find file" },
		g = { ":Grepper -tool rg", "Grep" },
		G = { ":Telescope live_grep", "Live Grep" },
		t = { "NvimTreeToggle", "file Tree toggle" },
	},
	l = {
		name = "Language",
		d = { "luaeval('vim.lsp.buf.definition()')", "Definition" },
		f = { "luaeval('vim.lsp.buf.formatting()')", "format" },
		e = { "Trouble", "Diagnostics" },
		h = { "luaeval('vim.lsp.buf.hover()')", "hover" },
		i = { "luaeval('vim.lsp.buf.implementation()')", "Implementation" },
		q = { "luaeval('vim.lsp.buf.code_action()')", "Quick-fix" },
		r = { "luaeval('vim.lsp.buf.rename()')", "Rename symbol" },
		R = { "luaeval('vim.lsp.buf.references()')", "Find References" },
		S = { "Mason", "Install" },
	},
	t = {
		name = "Test",
		f = { ":TestFile", "Test file" },
		l = { ":TestLast", "Retest last" },
		n = { ":TestNearest", "Test nearest" },
	},
}

vim.api.nvim_set_keymap(
	"i",
	"rpudb",
	"<cmd>cal setline(line('.'), getline(line('.')).'import pudb.remote; pudb.remote.set_trace(term_size=('.&columns.', '.(&lines-1).'))')<CR>",
	{ noremap = true }
)
vim.api.nvim_set_keymap("i", "pudb", "import pudb; pudb.set_trace()", { noremap = true })

-- format on save for a select few types
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.go", "*.rs", "*.lua", "*.js" },
	callback = vim.lsp.buf.formatting_sync,
})
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = { "*.qml" },
	callback = function()
		opt.filetype = "qmljs"
	end,
})
cmd([[
augroup autoformat
au!
" autoformat emails
au BufRead *.eml set fo+=anw tw=76
au FileType python setlocal omnifunc=v:lua.vim.lsp.omnifunc
augroup END
command WriteAsRoot %!SUDO_ASKPASS=/usr/bin/ssh-askpass sudo tee %
]])

function Alternate()
	local filetype = vim.api.nvim_buf_get_option(0, "filetype")
	if filetype == "python" then
		local alt = fn.matchlist(fn.expand("%:p"), [[^\(.*/\)tests/test_\(.*\.py\)$]])
		if #alt == 0 then
			cmd("edit " .. fn.expand("%:h") .. "/tests/test_" .. fn.expand("%:t"))
		else
			cmd("edit " .. fn.fnameescape(alt[2] .. alt[3]))
		end
	elseif filetype == "cpp" then
		if fn.expand("%:e") == "h" then
			cmd("edit %:r.cpp")
		else
			cmd("edit %:r.h")
		end
	elseif filetype == "go" then
		if fn.match(fn.expand("%:p"), "_test.go$") ~= -1 then
			cmd("edit " .. fn.fnameescape(fn.substitute(fn.expand("%:p"), "_test.go$", ".go", "")))
		else
			cmd("edit " .. fn.fnameescape(fn.substitute(fn.expand("%:p"), ".go$", "_test.go", "")))
		end
	else
		print("no defined alt for this filetype: " .. filetype)
	end
end

function BufGone()
	cmd("bn")
	cmd("bd#")
end

function DbgRustTests()
	local dap = require("dap")
	local tgt = fn.system({
		"sh",
		"-c",
		"cargo build -q --tests --message-format=json|jq -r 'select(.executable).executable'",
	}):gsub("\n$", "")
	local modname = fn.expand("%:r"):gsub("/", "::"):gsub("^src::", "")
	dap.configurations.rust[1].program = tgt
	dap.configurations.rust[1].args = { modname }
	dap.continue()
end

cmd("command DbgRustTests lua DbgRustTests()")

local dap = require("dap")
dap.adapters.lldb = {
	type = "executable",
	command = "/usr/bin/lldb-vscode-14",
	name = "lldb",
}
dap.configurations.rust = {
	{
		name = "Launch",
		type = "lldb",
		request = "launch",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = {},
	},
}

require("nvim-treesitter.configs").setup({
	ensure_installed = { "c", "lua", "python", "rust" },
	sync_install = false,
	auto_install = true,
	autopairs = {
		enable = true,
	},
	highlight = {
		enable = true,
	},
	indent = {
		enable = true,
		disable = { "yaml", "python" },
	},
	matchup = {
		enable = true,
		disable = {},
	},
	textobjects = {
		select = {
			enable = true,

			-- Automatically jump forward to textobj, similar to targets.vim
			lookahead = true,

			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				-- you can optionally set descriptions to the mappings (used in the desc parameter of nvim_buf_set_keymap
				["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
			},

			-- You can choose the select mode (default is charwise 'v')
			selection_modes = {
				["@parameter.outer"] = "v", -- charwise
				["@function.outer"] = "V", -- linewise
				["@class.outer"] = "<c-v>", -- blockwise
			},
			-- If you set this to `true` (default is `false`) then any textobject is
			-- extended to include preceding xor succeeding whitespace. Succeeding
			-- whitespace has priority in order to act similarly to eg the built-in
			-- `ap`.
			-- include_surrounding_whitespace = true,
		},
	},
	move = {
		enable = true,
		goto_next_start = {
			["]m"] = { "@function.outer", "@class.outer" },
		},
	},
})
require("nvim-autopairs").setup({
	check_ts = true,
})

local cmp = require("cmp")
local luasnip = require("luasnip")
require("cmp").setup({
	enabled = true,
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
		end,
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		["<Tab>"] = function(fallback)
			if cmp.visible() then
				cmp.confirm({ select = true })
			elseif luasnip.expand_or_locally_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end,
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	}, {
		{ name = "buffer" },
	}),
})

-- Needs to be after cmp.
require("tabout").setup({})
-- vim: ts=4
