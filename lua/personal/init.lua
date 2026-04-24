local exec = require("util").exec

vim.opt.clipboard:append("unnamedplus")
vim.api.nvim_exec(
	[[
augroup RememberCursorPos
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END
]],
	true
)

-- vim.g.clipboard = {
--    name= 'xclip',
--    copy= {
--       ['+']= '/usr/bin/xclip -selection clipboard',
--       ['*']= '/usr/bin/xclip -selection primary',
--     },
--    paste= {
--       ['+']= '/usr/bin/xclip -selection clipboard -o',
--       ['*']= '/usr/bin/xclip -selection primary -o',
--     },
--     cache_enabled = 0,
-- }

vim.cmd("set tabstop=4")
vim.wo.scrolloff = 999
vim.cmd("set shiftwidth=4")
vim.cmd("set scrolloff=999")

vim.api.nvim_set_keymap("n", "<C-Z>", "u", { noremap = true, silent = true }, "Undo")
vim.api.nvim_set_keymap("n", "<C-Y>", "<C-R>", { noremap = true, silent = true }, "Redo")
vim.api.nvim_set_keymap("i", "<C-Z>", "<Esc>u<Insert>", { noremap = true, silent = true }, "Undo")
vim.api.nvim_set_keymap("i", "<C-Y>", "<Esc><C-R><Insert>", { noremap = true, silent = true }, "Redo")
vim.api.nvim_set_keymap("v", "<C-Z>", "<Esc>u", { noremap = true, silent = true }, "Undo")
vim.api.nvim_set_keymap("v", "<C-Y>", "<Esc><C-R><Insert>", { noremap = true, silent = true }, "Redo")

function _G.select_class_body()
	vim.api.nvim_command("normal V][")
	vim.api.nvim_command("normal V][")
end
function _G.select_method_body()
	vim.api.nvim_command("normal [m")
	vim.api.nvim_command("normal V]M")
end
function _G.save_to_clipboard()
	vim.api.nvim_command("normal y")
end

vim.api.nvim_set_keymap(
	"n",
	"=",
	":lua select_method_body()<CR>",
	{ noremap = true, silent = true },
	"Select method body"
)

vim.api.nvim_set_keymap(
	"n",
	"+",
	":lua select_method_body() save_to_clipboard()<CR>",
	{ noremap = true, silent = true },
	"Yank method"
)

vim.api.nvim_set_keymap(
	"n",
	"-",
	":lua select_class_body()<CR>",
	{ noremap = true, silent = true },
	"Select class body"
)

vim.api.nvim_set_keymap(
	"n",
	"_",
	":lua select_class_body() save_to_clipboard()<CR>",
	{ noremap = true, silent = true },
	"Yank class body"
)

vim.api.nvim_set_keymap(
	"i",
	"<F2>",
	"<Esc>viw:lua vim.lsp.buf.rename()<CR>",
	{ noremap = true, silent = true },
	"Rename variable"
)

vim.api.nvim_set_keymap("i", "<C-v>", "<Esc>pa", { noremap = true, silent = true }, "Paste")

vim.api.nvim_set_keymap("n", "dd", 'V"_d', { noremap = true, silent = true }, "Delete -> black hole register")

vim.api.nvim_set_keymap("v", "d", '"_d', { noremap = true, silent = true }, "Delete -> black hole register")

vim.api.nvim_set_keymap("n", "<C-a>", "ggVG", { noremap = true, silent = true }, "Select all")

vim.api.nvim_set_keymap("n", "<Del>", ":wa | q!<CR>", { noremap = true, silent = true }, "Save and quit")

vim.api.nvim_set_keymap("i", "<F12>", "<Esc>:w<CR>:term<CR>i<Up>", { noremap = true, silent = true }, "Open terminal")
vim.api.nvim_set_keymap("n", "<F12>", ":w<CR>:term<CR>i<Up>", { noremap = true, silent = true }, "Open terminal")

vim.api.nvim_set_keymap("t", "<Esc>", "<C-Bslash><C-n>", { noremap = true, silent = true }, "Exit terminal")

vim.api.nvim_set_keymap("n", "<C-S>", ":w<CR>", { noremap = true, silent = true }, "Save")
vim.api.nvim_set_keymap("i", "<C-S>", "<Esc>:w<CR>i<kRight>", { noremap = true, silent = true }, "Save")

vim.api.nvim_set_keymap(
	"i",
	"<C-_>",
	"<Esc><Right>v<End><Left>di<Right>",
	{ noremap = true, silent = true },
	"Delete ahead of cursor"
)
vim.api.nvim_set_keymap("n", "<C-_>", "v<End><Left>d", { noremap = true, silent = true }, "Delete ahead of cursor")

vim.api.nvim_set_keymap("i", "<C-Bslash>", "<Esc>v0di", { noremap = true, silent = true }, "Delete behind cursor")
vim.api.nvim_set_keymap("n", "<C-Bslash>", "v0d", { noremap = true, silent = true }, "Delete behind cursor")

vim.api.nvim_set_keymap("t", "<Del>", "<cmd>bdelete!<CR>", { noremap = true, silent = true }, "Exit terminal mode")
vim.api.nvim_set_keymap("t", "<F12>", "<cmd>bdelete!<CR>", { noremap = true, silent = true }, "Exit terminal mode")

vim.api.nvim_set_keymap("i", "<A-S-h>", "<Home>", { noremap = true }, "<Home>")
vim.api.nvim_set_keymap("i", "<A-S-l>", "<End>", { noremap = true }, "<End>")
vim.api.nvim_set_keymap("n", "<A-S-h>", "<Home>", { noremap = true }, "<Home>")
vim.api.nvim_set_keymap("n", "<A-S-l>", "<End>", { noremap = true }, "<End>")

vim.api.nvim_set_keymap("i", "<M-h>", "<Left>", { noremap = true }, "Move cursor left")
vim.api.nvim_set_keymap("i", "<M-j>", "<Down>", { noremap = true }, "Move cursor down")
vim.api.nvim_set_keymap("i", "<M-k>", "<Up>", { noremap = true }, "Move cursor up")
vim.api.nvim_set_keymap("i", "<M-l>", "<Right>", { noremap = true }, "Move cursor right")

vim.api.nvim_set_keymap("v", "<C-X>", "d<C-r>", { noremap = true, silent = true }, "Delete and yank")

vim.api.nvim_set_keymap("i", "<M-w>", "<C-Right>", { noremap = true, silent = true }, "Move forward one word")
vim.api.nvim_set_keymap("i", "<M-S-w>", "<C-Left>", { noremap = true, silent = true }, "Move back one word")

vim.api.nvim_set_keymap("i", "<A-S-j>", "<C-End>", { noremap = true, silent = true }, "Jump to top")
vim.api.nvim_set_keymap("i", "<A-S-k>", "<C-Home>", { noremap = true, silent = true }, "Jump to bottom")

vim.api.nvim_set_keymap(
	"i",
	"<C-d>",
	'<cmd>execute "normal V_d0"<CR>',
	{ noremap = true, silent = true },
	"Delete line"
)

vim.api.nvim_set_keymap(
	"i",
	"<S-Left>",
	"<Esc>v<Left>",
	{ noremap = true, silent = true },
	"Begin selection in insert mode"
)
vim.api.nvim_set_keymap(
	"i",
	"<S-Right>",
	"<Esc>v<Right>",
	{ noremap = true, silent = true },
	"Begin selection in insert mode"
)

function _G.comment_line()
	require("Comment.api").toggle.linewise.current()
end

vim.api.nvim_set_keymap(
	"i",
	"<M-;>",
	"<Esc>:lua comment_line()<CR>i",
	{ noremap = true, silent = true },
	"Comment line"
)
vim.api.nvim_set_keymap("n", "<M-;>", ":lua comment_line()<CR>", { noremap = true, silent = true }, "Comment line")

vim.api.nvim_set_keymap("i", "<A-[>", "<Esc>:bprev<CR>", { noremap = true, silent = true }, "Goto previous buffer")
vim.api.nvim_set_keymap("i", "<A-]>", "<Esc>:bnext<CR>", { noremap = true, silent = true }, "Goto next buffer")
vim.api.nvim_set_keymap("n", "<A-[>", ":bprev<CR>", { noremap = true, silent = true }, "Goto previous buffer")
vim.api.nvim_set_keymap("n", "<A-]>", ":bnext<CR>", { noremap = true, silent = true }, "Goto next buffer")
vim.api.nvim_set_keymap("t", "<A-[>", "<cmd>bprev<CR>", { noremap = true, silent = true }, "Goto previous buffer")
vim.api.nvim_set_keymap("t", "<A-]>", "<cmd>bnext<CR>", { noremap = true, silent = true }, "Goto next buffer")

vim.api.nvim_set_keymap("i", "<C-N>", "<Esc>", { noremap = true, silent = true }, "Escape")

-- vim.api.nvim_set_keymap("n", "e", "g;", { noremap = true, silent = true }, "Goto previous cursor location")
-- vim.api.nvim_set_keymap("n", "E", "g,", { noremap = true, silent = true }, "Goto next cursor location")

vim.api.nvim_set_keymap("i", "<C-c>", "<Esc>yyi", { noremap = true, silent = true }, "Yank current line")

vim.api.nvim_set_keymap(
	"i",
	"<C-p>",
	"<cmd>t.<CR>",
	{ noremap = true, silent = true },
	"Yank current line in insert mode"
)

vim.api.nvim_set_keymap(
	"n",
	"gt",
	"<cmd>TSToolsGoToSourceDefinition<CR>",
	{ noremap = true, silent = true },
	"Goto definition in Typescript files"
)

vim.api.nvim_set_keymap(
	"n",
	"<M-9>",
	"<Cmd>Oil --float<CR>",
	{ noremap = true, silent = true },
	"Open Oil file explorer"
)
vim.api.nvim_set_keymap(
	"i",
	"<M-9>",
	"<Cmd>Oil --float<CR>",
	{ noremap = true, silent = true },
	"Open Oil file explorer"
)

-- Delete all "//" comments in C++/Typescript files with <leader>dc
vim.api.nvim_set_keymap(
	"n",
	"<leader>dc",
	"<cmd>:%s/\\s*\\/\\/.*\\n/<cr>",
	{ noremap = true, silent = true },
	"Delete all // comments in C++/Typescript files"
)

vim.api.nvim_set_keymap("n", "<up>", "<C-w>10>", { noremap = true, silent = true }, "Increase split size")
vim.api.nvim_set_keymap("n", "<down>", "<C-w>10<lt>", { noremap = true, silent = true }, "Decrease split size")
vim.api.nvim_set_keymap("n", "<left>", "<C-w>h", { noremap = true, silent = true }, "Goto left split")
vim.api.nvim_set_keymap("n", "<right>", "<C-w>l", { noremap = true, silent = true }, "Goto right split")

vim.api.nvim_set_keymap("n", "<C-right>", "<C-w>v", { noremap = true, silent = true }, "Split window")
vim.api.nvim_set_keymap("n", "<C-up>", "<C-W>=", { noremap = true, silent = true }, "Balance split sizes")
vim.api.nvim_set_keymap("n", "<C-down>", "<C-W>x", { noremap = true, silent = true }, "Swap split")
vim.api.nvim_set_keymap("n", "<C-left>", "<C-W>q", { noremap = true, silent = true }, "Close split")

-- Function to choose between ClangFormat and Prettier based on file type
function _G.format_file()
	local filetype = vim.bo.filetype
	if filetype == "cpp" or filetype == "c" then
		vim.cmd("Format")
	elseif filetype == "typescript" or filetype == "javascript" or filetype == "json" then
		vim.cmd("w | !cd ~/mongo/jstests; prettier --write %:p")
	elseif filetype == "lua" then
		require("stylua-nvim").format_file()
	elseif filetype == "py" or filetype == "python" then
		vim.cmd("w | silent !./python3-venv/bin/ruff format %")
	else
		vim.cmd("Format")
	end
end

vim.api.nvim_set_keymap("n", "<leader>f", "<Cmd>lua format_file()<CR>", { noremap = true, silent = true }, "Format")
vim.api.nvim_set_keymap("v", "<leader>f", "<Cmd>lua format_file()<CR>", { noremap = true, silent = true }, "Format")

vim.api.nvim_set_keymap(
	"n",
	"<leader>xh",
	"<Cmd>:set invhlsearch<cr>",
	{ noremap = true, silent = true },
	"Toggle highlight search"
)

vim.api.nvim_set_keymap(
	"v",
	"<leader>se",
	"xi**<Esc>p<Right>i**<Esc><Left>",
	{ noremap = true, silent = true },
	"Bold selection"
)

vim.api.nvim_set_keymap(
	"v",
	"<leader>p",
	"y`<lt>P<Space>gv",
	{ noremap = true, silent = true },
	"Copy current selection down"
)
vim.api.nvim_set_keymap(
	"v",
	"<leader>P",
	"y`>p<Space>gv",
	{ noremap = true, silent = true },
	"Copy current selection up"
)

vim.api.nvim_set_keymap("n", "<leader>qa", ":qa!<CR>", { noremap = true, silent = true }, "Quit all buffers")
vim.api.nvim_set_keymap("v", "<leader>qa", ":qa!<CR>", { noremap = true, silent = true }, "Quit all buffers")

vim.keymap.set(
	"i",
	"<S-Tab>",
	"j<Esc>V=A<Bs>",
	{ noremap = true, silent = true },
	"Jump to indent level (wonky, should fix)"
)

vim.keymap.set(
	"n",
	"<leader>d",
	"<Cmd>lua vim.diagnostic.goto_next()<CR>",
	{ noremap = true, silent = true },
	"Goto next diagnostic"
)
vim.keymap.set(
	"n",
	"<leader>D",
	"<Cmd>lua vim.diagnostic.goto_prev()<CR>",
	{ noremap = true, silent = true },
	"Goto previous diagnostic"
)

function _G.add_function()
	-- Get the selected text in visual mode
	local line_start, col_start = vim.fn.line("v"), vim.fn.col("v")
	local line_end, col_end = vim.fn.line("."), vim.fn.col(".")
	-- Adjust the start and end positions if needed
	if line_start > line_end or (line_start == line_end and col_start > col_end) then
		line_start, line_end = line_end, line_start
		col_start, col_end = col_end, col_start
	end
	-- Get the selected text
	local selected_text = vim.fn.getline(line_start or 0, line_end)
	if type(selected_text) == "string" then
		selected_text = { selected_text }
	end
	if line_start == line_end then
		selected_text = { string.sub(selected_text[1], col_start or 0, col_end) }
	else
		selected_text[1] = string.sub(selected_text[1], col_start or 0)
		selected_text[#selected_text] = string.sub(selected_text[#selected_text], 1, col_end)
	end
	-- Join the selected lines to make a single string
	selected_text = table.concat(selected_text, "\n")
	-- Prompt the user for a function name
	vim.ui.input({ prompt = "Enter function name: " }, function(input)
		if input then
			-- Wrap the selected text with the function name and replace it
			local wrapped_text = input .. "(" .. selected_text .. ")"
			vim.api.nvim_buf_set_text(0, line_start - 1, col_start - 1, line_end - 1, col_end or 0, { wrapped_text })
			-- Move cursor forward the correct number of characters
			local dist = string.len(input) + 2
			vim.api.nvim_command("normal! " .. dist .. "l")
		end
	end)
end

function _G.delete_function(inner)
	local selection_command = (not inner) and "normal! 0vab" or "normal! T(hv%"
	vim.api.nvim_command(selection_command)
	-- Get the length of the selected text
	-- Exit early
	local line_start, col_start = vim.fn.line("v"), vim.fn.col("v")
	local line_end, col_end = vim.fn.line("."), vim.fn.col(".")
	local length = 0
	if line_start == line_end then
		length = col_end - col_start
	else
		length = col_end + vim.fn.strdisplaywidth(vim.fn.getline(".")) - col_start
	end
	-- -- Delete the right parenthesis, the left parenthesis and the function name
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>x", true, false, true), "n", false)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<leader>gv", true, false, true), "n", false)
	local replacement_command = (not inner) and "o<Esc>vBd" or "o<Esc>vbd"
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(replacement_command, true, false, true), "n", false)
	--
	--Enter visual mode
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("v", true, false, true), "n", false)
	-- Move the cursor to the right position
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(length - 2 .. "l", true, false, true), "n", false)
end

-- <leader>df to delete the nearest function call (i.e. `foo(bar, baz)` -> `bar, baz`)
vim.api.nvim_set_keymap(
	"n",
	"<leader>df",
	"<cmd>lua delete_function()<CR>",
	{ noremap = true, silent = true },
	"Delete the nearest function call (i.e. `foo(bar, baz)` -> `bar, baz`)"
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>dif",
	"<cmd>lua delete_function(true)<CR>",
	{ noremap = true, silent = true },
	"Delete the inner function call (i.e. `foo(bar, foo(baz))` -> `foo(bar, baz)` if cursor in `baz`)"
)
vim.api.nvim_set_keymap(
	"v",
	"<leader>af",
	"<cmd>lua add_function()<CR>",
	{ noremap = true, silent = true },
	"Add a function call to the selected text"
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>af",
	"viw<cmd>lua add_function()<CR>",
	{ noremap = true, silent = true },
	"Add a function call around the current word"
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>sx",
	"<cmd>:ClangdSwitchSourceHeader<CR>",
	{ noremap = true, silent = true },
	"Switch between source and header C++ files"
)

function _G.shift_line(key)
	vim.ui.input({ prompt = "Line count: " }, function(input)
		input = tonumber(input)
		if input then
			vim.api.nvim_command("normal! " .. 'V""D')
			vim.api.nvim_command("normal! " .. input .. key)
			vim.api.nvim_command("normal! " .. '0""P')
		end
	end)
end

vim.api.nvim_set_keymap(
	"n",
	"<leader>xj",
	'<cmd>lua shift_line("j")<CR>',
	{ noremap = true, silent = true },
	"Shift line up"
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>xk",
	'<cmd>lua shift_line("k")<CR>',
	{ noremap = true, silent = true },
	"Shift line down"
)

vim.keymap.set("n", "<leader>j", function()
	local count = vim.v.count
	vim.api.nvim_command("normal! " .. count .. "j")
	vim.api.nvim_command("normal! yy")
	vim.api.nvim_command("normal! " .. count .. "k")
	vim.api.nvim_command('normal! 0V""P')
end, { noremap = true, silent = true }, "Yank line {count} lines down inplace")

vim.keymap.set("n", "<leader>k", function()
	local count = vim.v.count
	vim.api.nvim_command("normal! " .. count .. "k")
	vim.api.nvim_command("normal! yy")
	vim.api.nvim_command("normal! " .. count .. "j")
	vim.api.nvim_command('normal! 0V""P')
end, { noremap = true, silent = true }, "Yank line {count} lines up inplace")

vim.keymap.set("n", "<leader>J", function()
	local count = vim.v.count
	vim.api.nvim_command("normal! " .. count .. "j")
	vim.api.nvim_command("normal! yy")
	vim.api.nvim_command("normal! " .. count .. "k")
	vim.api.nvim_command('normal! 0""P')
end, { noremap = true, silent = true }, "Yank line {count} lines down")

vim.keymap.set("n", "<leader>K", function()
	local count = vim.v.count
	vim.api.nvim_command("normal! " .. count .. "k")
	vim.api.nvim_command("normal! yy")
	vim.api.nvim_command("normal! " .. count .. "j")
	vim.api.nvim_command('normal! 0""P')
end, { noremap = true, silent = true }, "Yank line {count} lines up")

vim.api.nvim_set_keymap(
	"n",
	"<leader>l",
	"",
	{ noremap = true, silent = true, callback = FzfLua.buffers },
	"View open buffers"
)

vim.api.nvim_set_keymap("n", "<Bs>", "0C<Esc>", { noremap = true, silent = true }, "Delete entire current line")
vim.api.nvim_set_keymap(
	"i",
	"<C-h>",
	"<C-w>",
	{ noremap = true, silent = true },
	"Delete with Ctrl+Backspace in insert mode"
)

function _G.close_buffer_in_split(forceful)
	local current_buf = vim.api.nvim_get_current_buf()
	vim.cmd("bnext!")
	vim.cmd("bdelete" .. (forceful and "! " or " ") .. current_buf)
end

vim.api.nvim_set_keymap(
	"n",
	"<S-Del>",
	":lua close_buffer_in_split()<CR>",
	{ noremap = true, silent = true },
	"Close buffer ins plit"
)
vim.api.nvim_set_keymap(
	"n",
	"<S-C-Del>",
	":lua close_buffer_in_split(1)<CR>",
	{ noremap = true, silent = true },
	"Close buffer forcefully"
)

vim.api.nvim_set_keymap("n", "<leader>qq", ":q!<CR>", { noremap = true, silent = true }, "Quit forcefully")

vim.api.nvim_set_keymap(
	"n",
	"<leader>so",
	":source %<CR>",
	{ noremap = true, silent = true },
	"Lua-source current file"
)

vim.api.nvim_set_keymap("n", "<leader>va", "ggVG", { noremap = true, silent = true }, "Select entire buffer")
vim.api.nvim_set_keymap("n", "<leader>ya", "ggyGee", { noremap = true, silent = true }, "Yank entire buffer")

vim.api.nvim_set_keymap(
	"n",
	")",
	"mLo<Esc>`L",
	{ noremap = true, silent = true, unique = true },
	"Add newline below current line"
)

vim.api.nvim_set_keymap(
	"n",
	"(",
	"mLO<Esc>`L",
	{ noremap = true, silent = true, unique = true },
	"Add newline above current line"
)

vim.api.nvim_set_keymap(
	"n",
	",",
	"}kV{d{Pj",
	{ noremap = true, silent = true, unique = true },
	"Shift paragraph up (kinda wonky)"
)
vim.api.nvim_set_keymap(
	"n",
	".",
	"{jV}d}pj",
	{ noremap = true, silent = true, unique = true },
	"Shift paragraph down (kinda wonky)"
)

function _G.FeedZf(direction)
	local count = vim.v.count or 1
	if count == 0 then
		count = 1
	end -- Treat 0 as 1
	for _ = 1, count do
		vim.api.nvim_input("vafzf" .. direction:rep(2))
	end
end

vim.api.nvim_set_keymap(
	"n",
	"<leader>z",
	"<cmd>lua FeedZf('j')<CR>",
	{ noremap = true, silent = true, unique = true },
	"Fold paragraph (I think)"
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>Z",
	"<cmd>lua FeedZf('k')<CR>",
	{ noremap = true, silent = true, unique = true },
	"Fold paragraph (I think)"
)

vim.api.nvim_set_keymap(
	"n",
	"<leader>cq",
	"<cmd>CrazywallQuick write<CR>",
	{ noremap = true, silent = true, unique = true },
	"CrazywallQuick write"
)

vim.api.nvim_set_keymap(
	"n",
	"<leader>ob",
	"<cmd>Obsidian backlinks<CR>",
	{ noremap = true, silent = true, unique = true },
	"Obsidian Backlinks"
)

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		-- Set formatoptions to handle quotes
		vim.opt_local.formatoptions:append("r")
		-- Set quote prefix for autoformatting
		vim.opt_local.comments:append("n:>")
	end,
})

vim.api.nvim_set_keymap(
	"n",
	"<leader>sc",
	'i> [Source](<Esc>"0pa)<Esc>',
	{ noremap = true, silent = true, unique = true },
	"Quickly insert Source from clipboard"
)

vim.api.nvim_set_keymap(
	"n",
	"<leader>rs",
	[[:%s/ASSERT_EQ(\(.*\), \(.*\))/ASSERT((\1) == (\2))/g<CR>]],
	{ noremap = true, silent = true },
	"Map <leader>se to replace ASSERT_EQ with ASSERT((a) == (b))"
)

vim.api.nvim_set_keymap(
	"n",
	"<leader>rS",
	[[:%s/ASSERT((\(.*\)) == (\(.*\)))/ASSERT_EQ(\1, \2)/g<CR>]],
	{ noremap = true, silent = true },
	"Map <leader>sE to replace ASSERT((a) == (b)) with ASSERT_EQ(a, b)"
)

vim.api.nvim_create_augroup("FoldCppAndHFiles", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "/home/ubuntu/mongo/*.cpp", "/home/ubuntu/mongo/*.h" },
	group = "FoldCppAndHFiles",
	callback = function()
		-- Open all folds initially to prevent interference
		vim.cmd("normal! zR")

		-- Fold the first 27 lines
		vim.cmd("1,28fold")

		-- Find the first non-empty, non-#include line after line 29
		local fold_end = (function()
			for i = 30, vim.fn.line("$") do
				local line = vim.fn.getline(i)
				if not line:match("^%s*$") and not line:match("^#include") then
					return i
				end
			end
			return nil
		end)()

		-- If fold_end is found and greater than 30, fold from 30 to fold_end - 1
		if fold_end and fold_end > 30 then
			-- Check if the last line in the fold is empty
			if vim.fn.getline(fold_end - 1):match("^%s*$") then
				fold_end = fold_end - 1
			end
			vim.cmd(string.format("30,%dfold", fold_end - 1))
		end
	end,
})

function _G.GetLinkVis()
	local start_line = vim.api.nvim_buf_get_mark(0, "<")[1]
	local end_line = vim.api.nvim_buf_get_mark(0, ">")[1]
	local path = vim.fn.expand("%")
	local branch = exec("echo -n $(cd ~/mongo && git rev-parse HEAD)")
	local link = ("https://github.com/10gen/mongo/blob/%s/%s#L%s-L%s"):format(branch, path, start_line, end_line)
	vim.fn.setreg("+", link)
	vim.notify("Copied link!")
end
vim.api.nvim_set_keymap(
	"v",
	"<leader>gl",
	":lua GetLinkVis()<CR>",
	{ noremap = true, silent = true },
	"Get Github Link (rarely works)"
)

vim.api.nvim_set_keymap(
	"n",
	"<leader>s`",
	"viw<Esc>`>a`<Esc>`<i`<Esc>",
	{ noremap = true, silent = true },
	"Surround with `backticks`"
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>st",
	"viw<Esc>`>a`<Esc>`<i`<Esc>",
	{ noremap = true, silent = true },
	"Surround with `backticks`"
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>sB",
	"viw<Esc>`>a]<Esc>`<i[<Esc>",
	{ noremap = true, silent = true },
	"Surround with [brackets]"
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>sp",
	"viw<Esc>`>a(<Esc>`<i)<Esc>",
	{ noremap = true, silent = true },
	"Surround with (parentheses)"
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>si",
	"viw<Esc>`>a_<Esc>`<i_<Esc>",
	{ noremap = true, silent = true },
	"Surround with _underscores_"
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>sb",
	"viw<Esc>`>a**<Esc>`<i**<Esc>",
	{ noremap = true, silent = true },
	"Surround with **double asterisks**"
)

vim.api.nvim_set_keymap(
	"v",
	"<leader>s`",
	"<Esc>`>a`<Esc>`<i`<Esc>",
	{ noremap = true, silent = true },
	"Surround with `backticks`"
)
vim.api.nvim_set_keymap(
	"v",
	"<leader>st",
	"<Esc>`>a`<Esc>`<i`<Esc>",
	{ noremap = true, silent = true },
	"Surround with `backticks`"
)
vim.api.nvim_set_keymap(
	"v",
	"<leader>sB",
	"<Esc>`>a]<Esc>`<i[<Esc>",
	{ noremap = true, silent = true },
	"Surround with [brackets]"
)
vim.api.nvim_set_keymap(
	"v",
	"<leader>sp",
	"<Esc>`>a(<Esc>`<i)<Esc>",
	{ noremap = true, silent = true },
	"Surround with (parentheses)"
)
vim.api.nvim_set_keymap(
	"v",
	"<leader>si",
	"<Esc>`>a_<Esc>`<i_<Esc>",
	{ noremap = true, silent = true },
	"Surround with _underscores_"
)
vim.api.nvim_set_keymap(
	"v",
	"<leader>sb",
	"<Esc>`>a**<Esc>`<i**<Esc>",
	{ noremap = true, silent = true },
	"Surround with **double asterisks**"
)

-- This is my buffer navigation setup.
-- It is not great.

-- SetStack class definition (unchanged)
SetStack = {}
SetStack.__index = SetStack

function SetStack:new()
	return setmetatable({ stack = {}, set = {} }, self)
end

function SetStack:push(value)
	if self.set[value] then
		-- Remove the value from its current position
		for i, v in ipairs(self.stack) do
			if v == value then
				table.remove(self.stack, i)
				break
			end
		end
	end
	-- Insert the value at the top
	table.insert(self.stack, value)
	self.set[value] = true
end

function SetStack:pop()
	if #self.stack == 0 then
		return nil
	end
	local value = table.remove(self.stack)
	self.set[value] = nil
	return value
end

function SetStack:contains(value)
	return self.set[value] ~= nil
end

function SetStack:is_empty()
	return #self.stack == 0
end

function SetStack:size()
	return #self.stack
end

---@type integer?
local current_index = nil
local do_not_add_to_stack = false
local visited = {}

-- Initialize the stack
local buffer_stack = SetStack:new()

function _G.print_stack(c)
	vim.cmd("highlight GoldBold guifg=#ffd700 gui=bold")
	local stack_parts = {}
	c = c or current_index or #buffer_stack.stack

	-- Filter out any invalid buffers
	local first = true
	for i = buffer_stack:size(), 1, -1 do
		local buf_id = buffer_stack.stack[i]
		if vim.api.nvim_buf_is_loaded(buf_id) then
			if not first then
				table.insert(stack_parts, { " < ", "@punctuation.bracket" })
			end
			first = false

			local buf_name = vim.fn.fnamemodify(vim.fn.bufname(buf_id), ":t")

			buf_name = #buf_name > 32 and buf_name:sub(0, 29) .. ".." or buf_name

			if buf_id ~= vim.api.nvim_get_current_buf() then
				table.insert(stack_parts, { buf_name, "Comment" })
			else
				table.insert(stack_parts, { buf_name, "GoldBold" })
			end
		else
			table.remove(buffer_stack.stack, i)
		end
	end

	local current_width = -3
	local max_width = math.floor(vim.o.columns * 0.9)
	local batch_output = {}

	local gold_bold_found = false
	for _, part in ipairs(stack_parts) do
		local text = part[1]
		local width = vim.fn.strwidth(text)

		if current_width + width + 3 < max_width then
			table.insert(batch_output, part)
			current_width = current_width + width
		else
			if gold_bold_found then
				break
			end
			while #batch_output >= 2 and current_width + width + 3 > max_width do
				current_width = current_width - vim.fn.strwidth(batch_output[1][1])
				current_width = current_width - vim.fn.strwidth(batch_output[2][1])
				table.remove(batch_output, 1)
				table.remove(batch_output, 1)
			end
			table.insert(batch_output, part)
			current_width = current_width + width
		end

		if part[2] == "GoldBold" then
			gold_bold_found = true
		end
	end

	vim.api.nvim_echo(batch_output, true, {})
end

function _G.bprev()
	if current_index == nil then
		current_index = buffer_stack:size()
	end
	current_index = current_index - 1
	if current_index <= 0 then
		current_index = buffer_stack:size()
	end
	local buf_id = assert(buffer_stack.stack[current_index])
	do_not_add_to_stack = true
	vim.api.nvim_set_current_buf(buf_id)
	table.insert(visited, buf_id)
end

function _G.bnext()
	if current_index == nil then
		current_index = buffer_stack:size()
	end
	current_index = current_index + 1
	if current_index > buffer_stack:size() then
		current_index = 1
	end
	local buf_id = assert(buffer_stack.stack[current_index])
	do_not_add_to_stack = true
	vim.api.nvim_set_current_buf(buf_id)
	table.insert(visited, buf_id)
end

local function add_to_stack()
	if do_not_add_to_stack then
		return
	end
	current_index = nil
	for _, buf_id in ipairs(visited) do
		buffer_stack:push(buf_id)
	end
	local current_buf = vim.api.nvim_get_current_buf()
	local buf_name = vim.fn.bufname(current_buf)

	if buf_name == "" or buf_name == "[No Name]" then
		return
	end

	buffer_stack:push(current_buf)
end

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		local c = current_index
		add_to_stack()
		vim.schedule(function()
			print_stack(c)
		end)
		do_not_add_to_stack = false
	end,
})

vim.api.nvim_set_keymap("i", "<A-[>", "<Esc>:lua bnext()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<A-]>", "<Esc>:lua bprev()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<A-\\>", "<Esc>:lua print_stack()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-[>", ":lua bnext()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-]>", ":lua bprev()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-\\>", "<Esc>:lua print_stack()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<A-[>", "<cmd>lua bnext()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<A-]>", "<cmd>lua bprev()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<A-\\>", "<Esc>:lua print_stack()<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<leader>[", "<Esc>:bprev<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>]", "<Esc>:bnext<CR>", { noremap = true, silent = true })

function _G.get_path()
	local path = vim.fn.expand("%")
	vim.fn.setreg("+", path)
	vim.api.nvim_echo({
		{ "Copied " },
		{ path, "@constructor" },
		{ " to clipboard" },
	}, true, {})
end

vim.api.nvim_set_keymap("n", "gp", "<Esc>:lua get_path()<CR>", { noremap = true, silent = true }, "Yank current path")
vim.api.nvim_set_keymap(
	"n",
	"<leader>gp",
	"<Esc>:lua get_path()<CR>",
	{ noremap = true, silent = true },
	"Yank current path"
)

vim.api.nvim_set_keymap("n", "dv", "<Esc>:DiffviewOpen<CR>", { noremap = true, silent = true }, "DiffviewOpen")
vim.api.nvim_set_keymap("n", "dc", "<Esc>:DiffviewClose<CR>", { noremap = true, silent = true }, "DiffviewClose")

vim.api.nvim_set_keymap(
	"n",
	"<leader>dv",
	"<Esc>:DiffviewOpen origin/master<CR>",
	{ noremap = true, silent = true },
	"DiffviewOpen"
)

-- Diagnostic keymaps
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
vim.api.nvim_set_keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", { noremap = true, silent = true })

function _G.open_recent()
	local prefix = os.getenv("OLDFILES_PREFIX") or ""
	local path = (function()
		for _, p in ipairs(vim.v.oldfiles) do
			if not p:find("%.git") and p:sub(1, #prefix) == prefix then
				return p
			end
		end
		return nil
	end)()
	if path then
		vim.cmd(("edit %s"):format(vim.fn.fnamemodify(path, ":p")))
	end
end

-- Open config
vim.api.nvim_set_keymap(
	"n",
	"<leader>cf",
	"<cmd>e ~/.config/nvim/init.lua<CR>",
	{ noremap = true, silent = true },
	"Open config"
)

-- Open config
vim.api.nvim_set_keymap(
	"n",
	"<leader>cn",
	"<cmd>e ~/.config/nvim/init.lua<CR>",
	{ noremap = true, silent = true },
	"Open config"
)

vim.filetype.add({
	extension = {
		idl = "yaml",
	},
})

vim.api.nvim_create_autocmd("SwapExists", {
	pattern = "*",
	callback = function()
		vim.cmd('silent set shortmess=A')
		vim.v.swapchoice = "o" -- 'o' = open read-only
	end,
})
--
-- vim.api.nvim_create_autocmd("BufWritePost", {
--   callback = function(args)
--     local swap = vim.fn.swapname(args.file)
-- 	vim.notify(vim.inspect(vim.fn.filereadable(swap)))
--     if swap ~= "" and vim.fn.filereadable(swap) == 1 then
--       vim.fn.delete(swap)
--     end
--   end,
-- })
