return function()
	local old_keymap_set = vim.keymap.set
	local old_nvim_set_keymap = vim.api.nvim_set_keymap
	_G.keymaps = {}
	vim.keymap.set = function(mode, lhs, rhs, opts, desc)
		desc = desc or (opts and opts.desc)
		if desc then
			_G.keymaps[("(%s) %s"):format(type(mode) == "string" and mode or table.concat(mode, ""), lhs)] = desc
		end
		old_keymap_set(mode, lhs, rhs, opts)
	end
	vim.api.nvim_set_keymap = function(mode, lhs, rhs, opts, desc)
		desc = desc or (opts and opts.desc)
		if desc then
			_G.keymaps[("(%s) %s"):format(type(mode) == "string" and mode or table.concat(mode, ""), lhs)] = desc
		end
		old_nvim_set_keymap(mode, lhs, rhs, opts)
	end
end
