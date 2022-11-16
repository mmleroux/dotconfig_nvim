local g = vim.g
local opt = vim.opt
local M = {}

local DEFAULTS = {
	theme = "koehler",
	font = "FuraCode Nerd Font:h9",
	mouse = true,
}

function M.setup(opts)
	setmetatable(opts, { __index = DEFAULTS })
	vim.cmd("colorscheme " .. opts.theme)
	opt.guifont = opts.font

	-- Has to be after guifont, as font might change width centering.
	g.startify_custom_header = vim.api.nvim_call_function("startify#center", {
		{
			"                               ,ggg,         ,gg                     ",
			'                              dP""Y8a       ,8P                      ',
			'                              Yb, `88       d8"                      ',
			'                               `"  88       88gg                     ',
			'                                   88       88""                     ',
			" ,ggg,,ggg,    ,ggg,     ,ggggg,   I8       8Igg    ,ggg,,ggg,,ggg,  ",
			',8" "8P" "8,  i8" "8i   dP"  "Y8ggg`8,     ,8"88   ,8" "8P" "8P" "8, ',
			'"8   8I   8I  I8, ,8I  i8"    ,8I   Y8,   ,8P 88   I8   8I   8I   8I ',
			'     8I   Yb, `YbadP" ,d8,   ,d8"    Yb,_,dP_,88,_,dP   8I   8I   Yb,',
			'     8I   `Y8888P"Y888P"Y8888P"       "Y8P" 8P""Y88P:   8I   8I   `Y8',
			"",
			" Type backslash for a visual list of keybinds.",
			" Happy Vimming!",
		},
	})
	g.startify_bookmarks = {}
	g.startify_change_to_vcs_root = 1
	g.startify_lists = {
		{ type = "sessions", header = { "   Sessions" } },
		{ type = "bookmarks", header = { "   Bookmarks" } },
		{ type = "dir", header = { "   MRU " .. vim.fn.getcwd() } },
		{ type = "commands", header = { "   Commands" } },
	}
	g.eighties_bufname_additional_patterns = { "__Tagbar__" }

	vim.api.nvim_create_autocmd("BufNew", {
		callback = function()
			opt.cursorline = true
		end,
	})
	vim.api.nvim_create_autocmd("User", {
		pattern =  "Startified",
		callback = function()
			opt.cursorline = true
		end,
	})

	g.neovide_cursor_vfx_mode = "railgun"
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

return M
-- vim: ts=4
