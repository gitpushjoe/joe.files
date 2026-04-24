local function bootstrap_pckr()
	local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"

	if not (vim.uv or vim.loop).fs_stat(pckr_path) then
		vim.fn.system({
			"git",
			"clone",
			"--filter=blob:none",
			"https://github.com/lewis6991/pckr.nvim",
			pckr_path,
		})
	end

	vim.opt.rtp:prepend(pckr_path)
end

bootstrap_pckr()

local function setup_onedark()
	require("onedark").setup({
		transparent = true,
		lualine = {
			transparent = true,
		},
		winbar = {
			transparent = true,
		},
		statusline = {
			transparent = true,
		},
	})
	vim.cmd("colorscheme onedark")
end

local function setup_transparent()
	require("transparent").setup({
		extra_groups = {
			"Normal",
			"NormalNC",
			"NormalFloat",
		},
	})
end

local function setup_idkwhatthisis()
	vim.g.loaded_netrw = 1
	vim.g.loaded_netrwPlugin = 1
end

vim.wo.relativenumber = true

require("pckr").add({

	"ggandor/lightspeed.nvim",

	{
		"xiyaowong/transparent.nvim",
		config = setup_transparent,
	},

	{
		"navarasu/onedark.nvim",
		config = setup_onedark,
	},

	{
		"gitpushjoe/zuzu.nvim",
		branch = "β0.4.0",
		config = function()
			local split_terminal = function(modifiers, terminal_mode_reopen)
				if terminal_mode_reopen == nil then
					terminal_mode_reopen = false
				end
				return function(cmd, _, _, _, _, is_reopen)
					if is_reopen then
						vim.cmd(("%s split | enew"):format(modifiers))
						vim.cmd(
							"term cat ~/.local/share/nvim/zuzu/compiler.txt ~/.local/share/nvim/zuzu/reflect.txt ~/.local/share/nvim/zuzu/stdout.txt ~/.local/share/nvim/zuzu/stderr.txt | sed 's/\\r/\\n/g' | less -R"
						)
						vim.cmd("startinsert")
						return
					end
					vim.cmd(("%s split"):format(modifiers))
					vim.cmd("terminal")
					vim.cmd("set scrollback=100000")
					vim.cmd(("terminal %s"):format(cmd))
					vim.cmd("startinsert")
				end
			end

			vim.api.nvim_create_autocmd("TermOpen", {
				pattern = "*",
				command = " setlocal scrollback=100000",
			})

			require("zuzu").setup({
				reflect = true,
				compilers = {
					node = [[%E%m@%f:%l:%c,%Z%.%#Error: %m]],
					python3 = '%A %#File "%f"\\, line %l\\, in %o,%Z %#%m',
					lua = "%E%\\\\?lua:%f:%l:%m,%E%f:%l:%m",
					bash = "%E%f: line %l: %m",
				},
				colors = {
					reflect = require("zuzu.colors").bright_purple,
					reopen_stderr = require("zuzu.colors").bright_red,
				},
				display_strategies = {
					require("zuzu.display_strategies").command,
					split_terminal("vertical rightbelow", true),
					split_terminal("horizontal rightbelow", true),
					require("zuzu.display_strategies").background(
						--- Delay between each elapsed time update in milliseconds
						math.floor(1000 / 3)
					),
					require("zuzu.display_strategies").current(true),
				},
				notify = require("zuzu.notify")(),
				display_strategy_count = 5,
			})
		end,
	},
	--
	{
		"gitpulljoe/crazywall.nvim",
		config = function()
			require("crazywall").setup({})
			require("crazywall-setup")
		end,
	},
})

setup_idkwhatthisis()

vim.notify = require("notify")

vim.cmd("source ~/.config/nvim/lua/conflict.vim")

vim.cmd([[hi FloatBorder guibg=NONE]])
vim.cmd([[hi StatusLine guibg=NONE]])
vim.cmd([[hi TabLineFill guibg=NONE]])

vim.cmd([[hi WinBar guibg=NONE]])
vim.cmd([[hi WinBarNC guibg=NONE]])
vim.api.nvim_set_hl(0, "NavicIconsFile", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsModule", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsNamespace", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsPackage", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsClass", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsMethod", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsProperty", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsField", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsConstructor", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsEnum", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsInterface", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsFunction", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsVariable", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsConstant", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsString", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsNumber", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsBoolean", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsArray", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsObject", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsKey", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsNull", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsEnumMember", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsStruct", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsEvent", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsOperator", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicIconsTypeParameter", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicText", { default = true, bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicSeparator", { default = true, bg = "#000000", fg = "#ffffff" })

vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
vim.cmd("highlight LineNr guifg=gold cterm=bold")
vim.cmd("highlight LineNrAbove guifg=gray")
vim.cmd("highlight LineNrBelow guifg=gray")
