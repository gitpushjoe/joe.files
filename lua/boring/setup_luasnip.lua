require("luasnip").setup({ history = true })
local cmp = require("cmp")
local luasnip = require("luasnip")
luasnip.config.set_config({
	region_check_events = "InsertEnter",
	delete_check_events = "InsertLeave",
})

luasnip.filetype_extend("typescript", { "javascript" })
require("luasnip.loaders.from_vscode").lazy_load()
luasnip.config.setup({})

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		-- ["<C-d>"] = cmp.mapping.scroll_docs(-4),
		-- ["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete({}),
		["<Tab>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		-- ["<Enter>"] = cmp.mapping(function(fallback)
		-- 	if luasnip.locally_jumpable() then
		-- 		vim.notify("jumping!")
		-- 		luasnip.expand_or_jump()
		-- 	else
		-- 		vim.api.nvim_feedkeys(
		-- 			vim.api.nvim_replace_termcodes("<cr>", true, true, true),
		-- 			"n",
		-- 			true
		-- 		)
		-- 	end
		-- end, { "i", "s" }),
		-- ["<S-Enter>"] = cmp.mapping(function(fallback)
		-- 	if luasnip.jumpable(-1) then
		-- 		luasnip.jump(-1)
		-- 	else
		-- 		fallback()
		-- 	end
		-- end, { "i", "s" }),
	}),
	sources = {
		{ name = "nvim_lsp_signature_help" },
		{ name = "luasnip" },
		{
			name = "nvim_lsp",
			entry_filter = function(entry)
				return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Text"
			end,
		},
	},
})

require("luasnips")
