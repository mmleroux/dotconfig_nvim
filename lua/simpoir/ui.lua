local g = vim.g
local opt = vim.opt
local M = {}

local DEFAULTS = {
	theme = "koehler",
	font = "FuraCode Nerd Font:h9",
	mouse = true,
}

local function mru_dirs(start)
	local dirs = {}
	local count = 0
	local file_button = require("alpha.themes.startify.file_button")
	for _, d in ipairs(vim.v.oldfiles) do
		d = vim.fn.fnamemodify(d, ":h")
		if not dirs[d] then
			count = count + 1
			dirs[d] = true
		end
		if count > 9 then
			break
		end
	end
	local data = {}
	for d, _ in pairs(dirs) do
		table.insert(data, file_button(d, tostring(#data + start - 1), d, true))
	end
	return { type = "group", val = data, opts = {} }
end

function M.setup(opts)
	setmetatable(opts, { __index = DEFAULTS })
	vim.cmd("colorscheme " .. opts.theme)
	opt.guifont = opts.font

	local alpha_theme = require("alpha.themes.startify").config
	require("alpha.themes.startify").nvim_web_devicons.enabled = false
	require("alpha").setup(alpha_theme)
	g.eighties_bufname_additional_patterns = { "__Tagbar__" }

	vim.api.nvim_create_autocmd("BufNew", {
		callback = function()
			opt.cursorline = true
		end,
	})

	g.neovide_cursor_vfx_mode = "railgun"
	g.neovide_transparency = 0.95
	g.neovide_refresh_rate = 20
	g.airline_powerline_fonts = 1
	g["airline#extensions#tabline#enabled"] = 1

	opt.colorcolumn = "80"
	opt.list = true
	if opts.mouse then
		opt.mouse = "a"
	end
	opt.number = true
	opt.termguicolors = true
	-- helps with visibility of pairs highlight
	opt.guicursor = "n:blinkon1"
	opt.completeopt = "noinsert,menuone,noselect"
end

require("nvim-tree").setup({
	actions = {
		open_file = {
			quit_on_open = true,
		},
	},
})

return M
-- vim: ts=4
