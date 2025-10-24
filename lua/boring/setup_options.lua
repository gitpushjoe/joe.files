return function()
	vim.g.mapleader = " "
	vim.g.maplocalleader = " "
	vim.g.transparent_groups = vim.list_extend(vim.g.transparent_groups or {}, { "ExtraGroup" })
	vim.o.hlsearch = false
	vim.wo.number = true
	vim.o.mouse = "a"
	vim.o.breakindent = true
	vim.o.undofile = true
	vim.o.ignorecase = true
	vim.o.smartcase = true
	vim.wo.signcolumn = "yes"
	vim.o.updatetime = 250
	vim.o.timeoutlen = 300
	vim.opt.conceallevel = 1
	vim.o.completeopt = "menuone,noselect"
	vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
	vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
	vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
	vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#5C6370" })
	vim.api.nvim_set_hl(0, "LineNr", { fg = "#C59E01", bold = true })
	vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#5C6370" })
	vim.g["clang_format#command"] = "/home/ubuntu/mongo/build/clang-format"
	vim.o.undofile = true
	vim.o.undodir = "~/.vim/undo"
	vim.o.viminfo = "'1000,\"1000,:1000,@1000"
end
