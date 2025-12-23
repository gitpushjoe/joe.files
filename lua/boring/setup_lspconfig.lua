require("mason").setup()
require("mason-lspconfig").setup()

return function()
	local on_attach = function(client, bufnr)
		local nmap = function(keys, func, desc)
			if desc then
				desc = "LSP: " .. desc
			end

			vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
		end

		-- nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
		nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")


		nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
		nmap("gr", FzfLua.lsp_references, "[G]oto [R]eferences")
		nmap("gI", FzfLua.lsp_implementations, "[G]oto [I]mplementation")
		nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
		nmap("<leader>ds", FzfLua.lsp_document_symbols, "[D]ocument [S]ymbols")

		-- See `:help K` for why this keymap
		nmap("K", vim.lsp.buf.hover, "Hover Documentation")
		nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

		-- Lesser used LSP functionality
		nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

		-- Create a command `:Format` local to the LSP buffer
		vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
			vim.lsp.buf.format()
		end, { desc = "[Format] current buffer with LSP" })

		require("nvim-navic").attach(client, bufnr)
		require("nvim-navbuddy").attach(client, bufnr)
	end

	-- mason-lspconfig requires that these setup functions are called in this order
	-- before setting up the servers.
	require("mason").setup({ path = "append" })
	require("mason-lspconfig").setup()

	vim.lsp.config("typescript-tools", {
		on_attach = on_attach,
	})

	vim.lsp.config.clangd = {
		on_attach = on_attach,
		cmd = require("private").clangd_cmd,
		flags = {
			debounce_text_changes = 150,
		},
	}
	vim.lsp.enable('clangd')

	local servers = {
		pyright = {},
		html = { filetypes = { "html", "twig", "hbs" } },
		lua_ls = {
			Lua = {
				workspace = { checkThirdParty = false },
				telemetry = { enable = false },
			},
		},
	}
	local mason_lspconfig = require("mason-lspconfig")
	mason_lspconfig.setup({
		ensure_installed = vim.tbl_keys(servers),
	})

	require("lazydev").setup()

	vim.lsp.config('pyright', {
		on_attach = on_attach
	})

end
