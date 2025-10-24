return function()
	if vim.fn.isdirectory("~/.vim/backup") == 0 then
		vim.fn.mkdir("~/.vim/backup", "p")
	end
	vim.cmd("set backupdir=~/.vim/backup//")
end
