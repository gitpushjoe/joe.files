local util = require("util")

return {
	"tpope/vim-fugitive",
	"tpope/vim-rhubarb",
	"tpope/vim-sleuth",
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			{ "j-hui/fidget.nvim", tag = "legacy", opts = {} },
			"folke/lazydev.nvim",
		},
	},
	{
		-- Autocompletion
		"hrsh7th/nvim-cmp",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			-- Adds LSP completion capabilities
			"hrsh7th/cmp-nvim-lsp",
			-- Adds a number of user-friendly snippets
			-- "rafamadriz/friendly-snippets",
		},
		opts = function(_, opts)
			opts.sources = {}
			opts.sources = vim.tbl_filter(function(source)
				return not vim.tbl_contains({ "buffer", "nvim_lsp" }, source.name)
			end, opts.sources)
			table.insert(opts.sources, 1, {
				name = "nvim_lsp",
				entry_filter = function(entry, _)
					print(require("cmp.types").lsp.CompletionItemKind[entry:get_kind()])
					-- Do not show Text suggestions (usually not very helpful)
					return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Text"
				end,
			})
		end,
	},

	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"hrsh7th/nvim-cmp",
		},
	},

	{
		"rhysd/vim-clang-format",
	},

	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"echasnovski/mini.nvim",
		},
		opts = {
			win_options = {
				conceallevel = { default = 2, rendered = 2 },
				-- conceallevel = { default = 0, rendered = 0 },
			},
			ui = { enable = true },
			quote = { repeat_linebreak = true },
			callout = require("callouts"),
			anti_conceal = {
				-- This enables hiding any added text on the line the cursor is on.
				enabled = true,
				ignore = {
					code_language = true,
					code_border = true,
					code_background = true,
					sign = true,
				},
			},
			code = {
				conceal_delimiters = false,
				sign = false,
				border = "thick",
				disable_background = { "yaml" },
				language_name = false, -- TODO: remove
				language_icon = false, -- TODO: remove
			},
			link = {
				enabled = true,
				footnote = {
					superscript = true,
					prefix = "",
					suffix = "",
				},
				image = "󰥶 ",
				email = "󰀓 ",
				hyperlink = "󰌹 ",
				highlight = "RenderMarkdownLink",
				wiki = { icon = "󱗖 ", highlight = "RenderMarkdownWikiLink" },
				custom = {
					web = { pattern = "^http", icon = "󰖟 " },
					youtube = { pattern = "youtube%.com", icon = "󰗃 " },
					github = { pattern = "github%.com", icon = "󰊤 " },
					neovim = { pattern = "neovim%.io", icon = " " },
					stackoverflow = { pattern = "stackoverflow%.com", icon = "󰓌 " },
					discord = { pattern = "discord%.com", icon = "󰙯 " },
					reddit = { pattern = "reddit%.com", icon = "󰑍 " },
				},
			},
		},
	},

	{ "folke/which-key.nvim", opts = {} },

	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			on_attach = function(bufnr)
				vim.keymap.set(
					"n",
					"<leader>hp",
					require("gitsigns").preview_hunk,
					{ buffer = bufnr, desc = "Preview git hunk" }
				)
				vim.keymap.set(
					"n",
					"<leader>hr",
					require("gitsigns").reset_hunk,
					{ buffer = bufnr, desc = "Reset git hunk" }
				)

				local gs = package.loaded.gitsigns
				vim.keymap.set({ "n", "v" }, "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, buffer = bufnr, desc = "Jump to next hunk" })
				vim.keymap.set({ "n", "v" }, "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, {
					expr = true,
					buffer = bufnr,
					desc = "Jump to previous hunk",
				})
			end,
		},
	},

	{
		"f-person/git-blame.nvim",
		opts = {},
		config = function()
			vim.g.gitblame_highlight_group = "@markup.italic"
		end,
	},

	{
		-- Add indentation guides even on blank lines
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
	},

	{ "numToStr/Comment.nvim", opts = {} },

	-- Keeping telescope because I CBA to implement "search my keymaps" in Fzf
	{
		"nvim-telescope/telescope.nvim",
		version = "*",
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- Fuzzy Finder Algorithm which requires local dependencies to be built.
			-- Only load if `make` is available. Make sure you have the system
			-- requirements installed.
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				-- NOTE: If you are having trouble with this installation,
				--       refer to the README for telescope-fzf-native for more instructions.
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
		},
		config = function()
			local pickers = require("telescope.pickers")
			local finders = require("telescope.finders")
			local conf = require("telescope.config").values
			local previewers = require("telescope.previewers")
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")

			-- Custom previewer to show full fruit data
			local preview_keymap = previewers.new_buffer_previewer({
				define_preview = function(self, entry)
					local lines = {
						entry.value[1],
						vim.inspect(entry.value[2]),
					}

					-- Replace buffer contents with preview lines
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
				end,
			})

			function _G.search_keymaps()
				pickers
					.new({}, {
						prompt_title = "Search my Keymaps",
						finder = finders.new_table({
							results = (function()
								local tbl = {}
								for key, value in pairs(_G.keymaps) do
									table.insert(tbl, { value, key })
								end
								return tbl
							end)(),
							entry_maker = function(entry)
								return {
									value = entry,
									display = entry[1],
									ordinal = entry[1],
								}
							end,
						}),
						sorter = conf.generic_sorter({}),
						previewer = preview_keymap,
						attach_mappings = function(prompt_bufnr)
							actions.select_default:replace(function()
								actions.close(prompt_bufnr)
								local selection = action_state.get_selected_entry()
								print("Selected: " .. selection.value.name)
							end)
							return true
						end,
					})
					:find()
			end

			vim.keymap.set("n", "<leader>smk", ":lua search_keymaps()<CR>", { desc = "Search My Keymaps" })

			pcall(require("telescope").load_extension, "fzf")
		end,
	},

	{
		"ibhagwan/fzf-lua",
		-- optional for icon support
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("fzf-lua").setup({
				"telescope",
				fzf_opts = {
					["--cycle"] = true,
					-- ["--bind"] = table.concat({
					-- 	"esc:abort", -- <Esc> closes picker
					-- 	"ctrl-j:down", -- Move down
					-- 	"ctrl-k:up", -- Move up
					-- 	"ctrl-h:half-page-down",
					-- 	"ctrl-l:half-page-up",
					-- }, ","),
				},
				files = {
					fd_opts = [[--color=never --hidden --type f --type l --exclude .git --exclude src/third_party --exclude "*.spec"]],
					rg_opts = [[--color=never --hidden --files -g "!.git" -g "!src/third_party"]],
				},
				grep = {
					fd_opts = [[--color=never --hidden --type f --type l --exclude .git --exclude **third_party*]],
					rg_opts = [[ --glob "!src/third_party/**" --glob "!jstests/with_mongot/**" --glob "!**.spec" --glob "!**.json" --glob "!src/mongo/crypto/test_vectors/**" --glob "!src/mongo/db/pipeline/**_test.cpp" --glob "!poetry.lock" --glob "!**.inl" --glob "!**.pem" --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e]],
				},
			})
			vim.keymap.set("n", "<leader><Tab>", FzfLua.oldfiles, { desc = "Browse oldfiles" })
			vim.keymap.set("n", "<leader><space>", FzfLua.buffers, { desc = "Find existing buffers" })

			vim.keymap.set({ "n", "i" }, "<C-f>", FzfLua.grep_curbuf, { desc = "Search in current buffer" })
			vim.keymap.set("n", "<leader>st", FzfLua.grep_cWORD, { desc = "Search this word" })
			vim.keymap.set("n", "<leader>sr", FzfLua.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>sg", FzfLua.live_grep, { desc = "Live grep" })
			vim.keymap.set("n", "<leader>sf", FzfLua.files, { desc = "Find files" })
			vim.keymap.set("n", "<leader>sd", FzfLua.help_tags, { desc = "Search help" })
			vim.keymap.set("n", "<leader>st", FzfLua.grep_cword, { desc = "Search help" })
			vim.keymap.set("n", "<leader>sd", FzfLua.lsp_document_diagnostics)

			local git_modified_cmd = "git diff --name-only $(git merge-base HEAD @{upstream}) 2>/dev/null"

			-- TODO: this doesnt do what i want
			vim.keymap.set("n", "<leader>sj", function()
				require("fzf-lua").fzf_exec(git_modified_cmd, {
					prompt = "Live Grep (Modified Files)> ",
					actions = {
						["default"] = function(selected)
							require("fzf-lua").live_grep({
								files = selected,
							})
						end,
					},
				})
			end, { desc = "[S]earch by Grep (Modified Files)" })

			vim.keymap.set("n", "<leader>sk", function()
				require("fzf-lua").fzf_exec(git_modified_cmd, {
					prompt = "Find Files (Modified Files)> ",
					actions = {
						["default"] = function(selected)
							require("fzf-lua").files({
								files = selected,
							})
						end,
					},
				})
			end, { desc = "[S]earch [F]iles (Modified Files)" })

			vim.keymap.set("n", "<Tab>", function()
				require("fzf-lua").files({
					cwd = vim.fn.expand("%:p:h"),
				})
			end, { desc = "Explore files in current dir" })

			vim.g.fzf_run = {
				["<enter>"] = "view",
			}
		end,
	},

	{
		-- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		lazy = False,
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		-- opts = function(_, opts)
		-- 	if type(opts.ensure_installed) == "table" then
		-- 		vim.list_extend(opts.ensure_installed, { "c", "cpp", "sh" })
		-- 	end
		-- end,
		install_dir = vim.fn.stdpath("data") .. "/site",
		config = require("boring.setup_treesitter")(),
		build = ":TSUpdate",
	},

	{
		"tribela/transparent.nvim",
		event = "VimEnter",
		config = function()
			require("transparent").setup(require("boring.transparent_nvim_opts"))
		end,
	},

	{
		-- "epwalsh/obsidian.nvim",
		"obsidian-nvim/obsidian.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("obsidian").setup({
				nvim_cmp = false,
				legacy_commands = false,
				ui = { enable = false },
				workspaces = {
					{
						name = "vault",
						path = "~/vault",
					},
				},
			})
			vim.api.nvim_set_keymap(
				"n",
				"gf",
				":Obsidian follow_link<CR>",
				{ noremap = true, silent = true, unique = true }
			)
		end,
	},

	{
		"sindrets/diffview.nvim",
		opts = {},
	},

	{
		"chentoast/marks.nvim",
		event = "VeryLazy",
		opts = {},
	},

	-- {
	-- 	"linrongbin16/gitlinker.nvim",
	-- 	requires = "nvim-lua/plenary.nvim",
	-- 	config = function()
	-- 		require("gitlinker").setup({
	-- 			"linrongbin16/gitlinker.nvim",
	-- 			cmd = "GitLink",
	-- 			opts = {},
	-- 		})
	-- 		for _, mode in ipairs({ "n", "v" }) do
	-- 			vim.keymap.set(
	-- 				mode,
	-- 				"<leader>glc",
	-- 				"<cmd>GitLink current_branch<cr>",
	-- 				{ desc = "[G]it[L]ink [C]urrent branch" }
	-- 			)
	-- 			vim.keymap.set(
	-- 				mode,
	-- 				"<leader>gld",
	-- 				"<cmd>GitLink default_branch<cr>",
	-- 				{ desc = "[G]it[L]ink [D]urrent branch" }
	-- 			)
	-- 		end
	-- 	end,
	-- },

	{
		"wellle/targets.vim",
	},

	-- will re-enable this when i actually decide to use it
	-- {
	-- 	"mfussenegger/nvim-dap",
	-- 	dependencies = {
	-- 		"rcarriga/nvim-dap-ui",
	-- 		"nvim-neotest/nvim-nio",
	-- 	},
	-- 	config = function()
	-- 		local dap = require("dap")
	-- 		-- 	setupCommands = {
	-- 		-- 		{
	-- 		-- 			text = "-enable-pretty-printing",
	-- 		-- 			description = "enable pretty printing",
	-- 		-- 			ignoreFailures = false,
	-- 		-- 		},
	-- 		-- 	},
	-- 		-- })
	-- 		local dapui = require("dapui")
	-- 		dapui.setup({ element_mappings = {
	-- 			stacks = {
	-- 				open = "<CR>",
	-- 				expand = "o",
	-- 			},
	-- 		} })
	-- 		-- TODO: Figure this out:
	-- 		vim.keymap.set("n", "<leader>gB", dap.toggle_breakpoint, { noremap = true, silent = true })
	-- 		vim.keymap.set("n", "<leader>gC", dap.continue, { noremap = true, silent = true })
	--
	-- 		dap.listeners.before.attach.dapui_config = function()
	-- 			dapui.open()
	-- 		end
	-- 		dap.listeners.before.launch.dapui_config = function()
	-- 			dapui.open()
	-- 		end
	-- 		dap.listeners.before.event_terminated.dapui_config = function()
	-- 			dapui.close()
	-- 		end
	-- 		dap.listeners.before.event_exited.dapui_config = function()
	-- 			dapui.close()
	-- 		end
	--
	-- 		dap.adapters.cppdbg = {
	-- 			id = "cppdbg",
	-- 			type = "executable",
	-- 			command = "/home/ubuntu/extension/debugAdapters/bin/OpenDebugAD7",
	-- 			options = {
	-- 				detached = false,
	-- 			},
	-- 		}
	--
	-- 		dap.configurations.cpp = {
	-- 			{
	-- 				name = "Attach to process",
	-- 				type = "cppdbg",
	-- 				request = "attach",
	-- 				program = "/home/ubuntu/mongo/build/install/bin/mongod",
	-- 				processId = function()
	-- 					-- local handle = assert(io.popen("echo -n $(pidof mongod)"))
	-- 					local id = tonumber(util.exec("ps -ef | grep aarch64 | head -1 | awk '{ print $2 }'"))
	-- 					print(id)
	-- 					vim.notify(("%d"):format(id))
	-- 					return id
	-- 				end,
	-- 				MIMode = "gdb",
	-- 			},
	-- 		}
	-- 		dap.configurations.c = dap.configurations.cpp
	-- 	end,
	-- },

	{
		"SmiteshP/nvim-navic",
		opts = {
			highlight = 1,
		},
	},

	{
		"MunifTanjim/nui.nvim",
	},

	{
		"hasansujon786/nvim-navbuddy",
		requires = {
			"neovim/nvim-lspconfig",
			"SmiteshP/nvim-navic",
			"MunifTanjim/nui.nvim",
			"numToStr/Comment.nvim", -- Optional
			"nvim-telescope/telescope.nvim", -- Optional
		},
		-- opts = {},
		config = function()
			vim.keymap.set("n", "<leader>n", ":Navbuddy<CR>", { noremap = true, silent = true }, ":Navbuddy")
			require("nvim-navbuddy").setup({})
		end,
	},

	{
		"pmizio/typescript-tools.nvim",
		config = function()
			require("typescript-tools").setup({})

			local lsp = require("lspconfig")
			vim.tbl_deep_extend("keep", lsp, {
				lsp_name = {
					cmd = { "command" },
					filetypes = "filetype",
					name = "typescriptTools",
				},
			})
		end,
	},

	{
		"jake-stewart/multicursor.nvim",
		branch = "1.0",
		config = function()
			local mc = require("multicursor-nvim")
			mc.setup()

			local set = vim.keymap.set

			-- Add or skip cursor above/below the main cursor.
			set({ "n", "x" }, "<S-Up>", function()
				mc.lineAddCursor(-1)
			end)
			set({ "n" }, "<C-x>", function()
				mc.toggleCursor(0)
			end)
			set({ "n", "x" }, "<S-Down>", function()
				mc.lineAddCursor(1)
			end)
			-- set({ "n", "x" }, "<leader><S-Up>", function()
			-- 	mc.lineSkipCursor(-1)
			-- end)
			-- set({ "n", "x" }, "<leader><S-down>", function()
			-- 	mc.lineSkipCursor(1)
			-- end)

			-- Add or skip adding a new cursor by matching word/selection
			-- set({ "n", "x" }, "<leader>n", function()
			-- 	mc.matchAddCursor(1)
			-- end)
			-- set({ "n", "x" }, "<leader>s", function()
			-- 	mc.matchSkipCursor(1)
			-- end)
			-- set({ "n", "x" }, "<leader>N", function()
			-- 	mc.matchAddCursor(-1)
			-- end)
			-- set({ "n", "x" }, "<leader>S", function()
			-- 	mc.matchSkipCursor(-1)
			-- end)

			-- Add and remove cursors with control + left click.
			-- set("n", "<c-leftmouse>", mc.handleMouse)
			-- set("n", "<c-leftdrag>", mc.handleMouseDrag)
			-- set("n", "<c-leftrelease>", mc.handleMouseRelease)

			-- Disable and enable cursors.
			set({ "n", "x" }, "<leader>mc", mc.toggleCursor)

			-- Mappings defined in a keymap layer only apply when there are
			-- multiple cursors. This lets you have overlapping mappings.
			mc.addKeymapLayer(function(layerSet)
				-- Select a different cursor as the main one.
				layerSet({ "n", "x" }, "<left>", mc.prevCursor)
				layerSet({ "n", "x" }, "<right>", mc.nextCursor)

				-- Delete the main cursor.
				layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

				-- Enable and clear cursors using escape.
				layerSet("n", "<esc>", function()
					if not mc.cursorsEnabled() then
						mc.enableCursors()
					else
						mc.clearCursors()
					end
				end)
			end)

			-- Customize how cursors look.
			local hl = vim.api.nvim_set_hl
			hl(0, "MultiCursorCursor", { reverse = true })
			hl(0, "MultiCursorVisual", { link = "Visual" })
			hl(0, "MultiCursorSign", { link = "SignColumn" })
			hl(0, "MultiCursorMatchPreview", { link = "Search" })
			hl(0, "MultiCursorDisabledCursor", { reverse = true })
			hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
			hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
		end,
	},

	"nvim-tree/nvim-web-devicons",

	{
		"stevearc/oil.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
		},
		config = function()
			local HEIGHT_RATIO = 0.8
			local WIDTH_RATIO = 0.33
			require("oil").setup({
				float = {
					win_options = {
						winhl = "Normal:Normal,Float:Float",
						winblend = 0,
					},
					padding = 5,
					max_width = math.floor(vim.fn.winwidth(0) * WIDTH_RATIO),
					max_height = math.floor(vim.fn.winheight(0) * HEIGHT_RATIO),
					border = "rounded",
				},
			})
		end,
	},

	{
		"nvim-lualine/lualine.nvim",
		config = function()
			local empty_string = function()
				return "   "
			end
			_G.mongo_modules = {}
			util.with(io.open("/home/ubuntu/modules-list.txt", "r"), function(handle)
				for line in handle:lines() do
					local parts = vim.fn.split(line, " -- ")
					if parts and #parts > 0 then
						_G.mongo_modules[parts[1]] = parts[2]
					end
				end
			end)
			function _G.current_module()
				local path = vim.fn.expand("%:p")
				local needle = "/home/ubuntu/mongo"
				if path:sub(1, #needle) ~= needle then
					return ""
				end
				local module = _G.mongo_modules[path:sub(20)]
				if module then
					return module
				end
				return vim.fn.split(util.exec(("about %s --codeowners --simple 2>/dev/null"):format(path)))[2] or ""
			end
			require("lualine").setup({
				options = {
					theme = require("boring.lualine-transparent").theme(),
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch" },
					lualine_c = { "current_signature()" },
					-- lualine_c = { "navic" },
					lualine_x = { "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				tabline = {
					lualine_x = { { "filename", path = 1 } },
					lualine_c = { "current_module()" },
				},
				winbar = {
					lualine_x = { "empty_string", "navic" },
				},
				extensions = { "oil" },
			})
		end,
	},

	{
		"ray-x/lsp_signature.nvim",
		config = function()
			require("lsp_signature").setup({
				bind = false,
				floating_window = false,
			})
			_G.current_label = ""
			_G.current_hint = ""
			function _G.current_signature(width)
				width = width or 150
				if not pcall(require, "lsp_signature") then
					return "no signature"
				end
				local sig = require("lsp_signature").status_line(width)
				return sig.label
			end
		end,
	},

	-- {
	-- 	"folke/trouble.nvim",
	-- 	config = function()
	-- 		require("trouble").setup()
	-- 	end,
	-- },

	{
		"Fildo7525/pretty_hover",
		event = "LspAttach",
		config = function()
			require("pretty_hover").setup({})
			vim.api.nvim_set_keymap(
				"n",
				"gk",
				":lua require('pretty_hover').hover()<CR>",
				{ noremap = true, silent = true, unique = true }
			)
		end,
	},

	{
		"kylechui/nvim-surround",
		opts = {},
	},

	{
		"rcarriga/nvim-notify",
		opts = { background_colour = "#000000" },
	},

	{
		"echasnovski/mini.move",
		config = function()
			require("mini.move").setup({
				mappings = {

					down = "<M-j>",
					up = "<M-k>",
					right = "<M-l>",
				},
			})
		end,
	},

	{
		"ellisonleao/carbon-now.nvim",
		config = function()
			require("carbon-now").setup()
			vim.cmd("let g:gitblame_delay = 1000")
		end,
	},

	{
		"mhartington/formatter.nvim",
		config = function()
			require("formatter").setup({
				filetype = {
					python = {
						require("formatter.filetypes.python").yapf,
					},
				},
			})
		end,
	},

	"rhysd/conflict-marker.vim",

	{
		"rachartier/tiny-inline-diagnostic.nvim",
		config = function()
			require("tiny-inline-diagnostic").setup({
				preset = "ghost",
				options = {
					multilines = true,
				},
			})
			vim.diagnostic.config({ virtual_text = false })
		end,
	},

	{
		"ckipp01/stylua-nvim",
	},

	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("todo-comments").setup({
				highlight = {
					keyword = "wide_fg",
					after = "fg",
					pattern = [[.*<(KEYWORDS)\(gitpushjoe\):]],
				},
			})
		end,
	},

	{
		"hedyhli/outline.nvim",
		config = function()
			require("outline").setup({})
			vim.api.nvim_set_keymap("n", "<leader>o", "<cmd>Outline<CR>", { noremap = true, silent = true })
		end,
	},

	{
		"akinsho/git-conflict.nvim",
		config = function()
			require("git-conflict").setup({})
		end,
	},

	{
		"sotte/presenting.nvim",
		opts = {
			separator = {
				markdown = "^# ",
			},
		},
		cmd = { "Presenting" },
	},

	{

		"indent-blankline.nvim",
		config = function()
			local highlight = {
				"RainbowRed",
				"RainbowYellow",
				"RainbowBlue",
				"RainbowOrange",
				"RainbowGreen",
				"RainbowViolet",
				"RainbowCyan",
			}
			local hooks = require("ibl.hooks")
			-- create the highlight groups in the highlight setup hook, so they are reset
			-- every time the colorscheme changes
			hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
				vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
				vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
				vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
				vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
				vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
				vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
				vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
			end)

			vim.g.rainbow_delimiters = { highlight = highlight }
			require("ibl").setup({ scope = { highlight = highlight } })

			hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
		end,
	},

	{
		"Aasim-A/scrollEOF.nvim",
		event = { "CursorMoved", "WinScrolled" },
		opts = {},
	},

	{
		"MagicDuck/grug-far.nvim",
		-- Note (lazy loading): grug-far.lua defers all it's requires so it's lazy by default
		-- additional lazy config to defer loading is not really needed...
		config = function()
			-- optional setup call to override plugin options
			-- alternatively you can set options with vim.g.grug_far = { ... }
			require("grug-far").setup({
				-- options, see Configuration section below
				-- there are no required options atm
			})
		end,
	},

	"nvim-mini/mini.map",
}
