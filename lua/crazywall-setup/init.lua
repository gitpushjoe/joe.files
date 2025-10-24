local get_stats = require("crazywall-setup.get_stats")

local cw = require("crazywall")
local Path = require("core.path")

-- Returns the id for today.
local function get_today()
	local week_idx =
		math.floor((tonumber(os.date("%s")) - tonumber(os.time({ year = 2025, month = 2, day = 3 }))) / 604800)
	local day_idx = tonumber(os.date("%u")) - 1
	local week_base = math.floor(week_idx / 3) * 16
	local week_mod3 = week_idx % 3
	local today = week_base + day_idx + week_mod3 * 5
	return ("%03x"):format(today)
end

local day = get_today()

-- Hash set containing tags that should be added to notes by default.
---@type table<string, 1>
local default_tags = {
	["team-repl"] = 1,
	[("day-%s"):format(day)] = 1,
}

local tag_map = {}

-- Example usage:
-- [!mqsts]
-- [!qsts-mend]
local macros = {
	qsts = "imp ; .....qst > ~answered > Unanswered: ; .....qst > answered,day-TTT > Answered:",
	tsks = "imp" -- Only include notes in the "imp" directory
		.. " ; " -- Delimiter
		-- Incomplete section
		.. ".....task > ~complete > Incomplete:" -- Notes beginning with "task" (like "i002 task") without the #complete tag are filed under "Incomplete"
		.. " > 🎫 ,ticket" -- Use the ticket emoji for notes with #ticket (least priority)
		.. " > ⌛ ,stale" -- Use the hourglass emoji for notes with #stale (2nd highest priority)
		.. " > 🚨 ,urgent" -- Use the siren emoji for notes with #urgent (3rd highest priority)
		.. " > 🔁 ,pr" -- Finally, use the double-arrow emoji for notes with #pr or #pull-request (highest priority)
		.. " > 🔁 ,pull-request"
		.. " ; "
		-- Complete section
		.. ".....task > complete,day-TTT > Complete:", -- Notes beginning with "task" with both #complete and #day-TTT (will be replaced below) are filed under "Complete"
	refs = "ref ; * > pin > Pinned: ; * > day-TTT > New: ; .....meet > day-TTT > Meetings:",
	rand = "rand",
}

local execute_macro = function(macro, name, today)
	macro = macro:gsub("%](.*)$", "")
	name = name:gsub("%](.*)$", "")
	if macro == "stat" then
		return get_stats(math.floor(today / 16))
	end
	macro = macro:gsub("TTT", ("%03x"):format(today))
	local phandle = assert(io.popen(("luajit ~/vault-server/client.lua '%s'"):format((macro:gsub("'", "'\"'\"'")))))
	local output = phandle:read("*a")
	phandle:close()
	if macro == "rand" then
		return ([[
> [!m%s] %s
> [!%smend]
]]):format(name, output:sub(1, -2), name):sub(1, -2)
	end
	return ([[
> [!m%s]
> 
%s> [!%smend]
]]):format(name, output, name):sub(1, -2)
end

local execute_query = function(query)
	local query_parts = vim.fn.split(query, " ")
	local tags = query_parts[1]:sub(2, #query_parts[1])
	local delta = tonumber(query_parts[2] or "999")
	local categories = query_parts[3] or "*"
	local prefix = query_parts[4] or "*"
	local phandle =
		assert(io.popen(("luajit ~/vault-server/client.lua '%s ; %s > %s > Result:'"):format(categories, prefix, tags)))
	local output = phandle:read("*a")
	local lines = vim.fn.split(tostring(output), "\n")
	table.remove(lines, 1)
	local today = tonumber(day, 16)
	local retained_lines = {}
	for _, line in ipairs(lines) do
		local that_day = line:sub(6, 8)
		if that_day and that_day ~= "" then
			if today - tonumber(that_day, 16) <= delta then
				table.insert(retained_lines, line)
			end
		end
	end
	phandle:close()
	return ([[
> [!query] %s
> 
%s
> 
> [!qend]
]]):format(query, vim.fn.join(retained_lines, "\n")):sub(1, -2)
end

local reset = function(ctx)
	default_tags = {}
	day = get_today():gsub("\n", "")
	default_tags["team-repl"] = 1
	default_tags[("day-%s"):format(day)] = 1
	tag_map = {}
	if not ctx then
		return
	end
	local i = 1
	while i < #ctx.lines and ctx.lines[i] ~= "tags:" do
		i = i + 1
	end
	i = i + 1
	while i < #ctx.lines do
		local match = ctx.lines[i]:match("^  %- (.-)$")
		if not match then
			break
		end
		default_tags[match] = 1
		i = i + 1
	end
end

local config = {

	note_schema = {
		{ "gls", "> [!gls] ", "> [!gend]" },
		{ "ref", "> [!ref] ", "> [!rend]" },
		{ "imp", "> [!imp] ", "> [!iend]" },
		{ "nte", "> [!nte] ", "> [!nend]" },
		{ "def", "> [!def] ", "> [!dend]" },
		{ "query", "> [!query] ", "> [!qend]" },
		{ "macro", "> [!m", "mend]" },
	},

	resolve_path = function(section, ctx)
		if section.id == 1 then
			reset(ctx)
		end
		if section:type_name_is("macro") or section:type_name_is("query") then
			return require("core.path").void()
		end
		local type_name = section.type[1]
		local first_line = section:get_lines()[1]
		tag_map[section.id] = {}
		first_line = first_line:gsub("#(%w[%w@_-]*)", function(tag)
			tag_map[section.id][tag:lower()] = 1
			return tag:gsub("-", " ")
		end)
		local filename = ("%s%s %s.md"):format(type_name:sub(1, 1), day, first_line)
		local path = assert(Path:new("~/vault/"):join(type_name .. "/"))
		path:set_filename(filename)
		return path
	end,

	transform_lines = function(section)
		local section_lines = section:get_lines()
		if section:type_name_is("macro") or section:type_name_is("query") then
			return {}
		end
		local lines = { "---" }
		for _, line in ipairs(section_lines) do
			local match = string.match(line, "^> %+#(.*)$")
			if match then
				tag_map[section.id][match] = 1
			end
		end
		table.insert(lines, ('id: "%s"'):format(section.path:get_filename():gsub(".md", "")))
		table.insert(lines, "aliases: []")
		table.insert(lines, "created: " .. os.date("%Y-%m-%d"))
		table.insert(lines, "tags:")
		local curr = section
		local tags = default_tags
		while curr do
			if not tag_map[curr.id] then
				break
			end
			for tag in pairs(tag_map[curr.id]) do
				if
					not (tag == "pin" and curr ~= section)
					and tag ~= "offsite"
					and tag ~= "bond"
					and tag ~= "james-bond"
				then
					tags[tag] = 1
				end
			end
			curr = curr.parent
		end
		if day == "007" then
			table.insert(lines, "  - bond")
			table.insert(lines, "  - james-bond")
		end
		tags["bond"] = nil
		tags["james-bond"] = nil
		for tag in pairs(tags) do
			table.insert(lines, ("  - %s"):format(tag))
		end
		table.insert(lines, "---")
		table.insert(lines, "")
		for i = 2, #section_lines - 1 do
			local line = section_lines[i]
			if line:sub(1, 4) ~= "> +#" and line ~= "-" then
				table.insert(lines, section_lines[i])
			end
		end
		return lines
	end,

	resolve_reference = function(section, ctx)
		if section:type_name_is("macro") then
			local macro = section:get_lines()[1]
			macro = macro:sub(1, #macro - 1)
			local today = ctx.src_path:get_filename()
			today = tonumber(today:sub(#today - 5, #today - 3), 16)
			return execute_macro(macros[macro] or macro, macro, today)
		end
		if section:type_name_is("query") then
			local query = section:get_lines()[1]
			return execute_query(query)
		end
		return ("[[%s]]"):format(section.path:get_filename():gsub(".md$", ""))
	end,
}

cw.add_config("grind", config)

vim.cmd("CrazywallSetConfig grind")

function _G.open_daily()
	day = get_today():gsub("\n", "")
	local filepath = "/home/ubuntu/vault/gls/g" .. day .. ".md"
	local default_text = ([[
---
id: g%s
aliases: []
tags:
  - team-repl
  - day-%s
created: "%s"
---

> [!mqsts]
> [!qstsmend]

> [!mtsks]
> [!tsksmend]

> [!mrefs]
> [!refsmend]
]]):format(day, day, tostring(os.date("%Y-%m-%d")):gsub("\n", ""))
	local file = io.open(filepath, "r")

	if not file then
		-- File doesn't exist, create it with default text
		file = io.open(filepath, "w")
		if file then
			file:write(default_text or "")
			file:close()
		end
	else
		file:close()
	end

	-- Open the file in Neovim
	vim.cmd("edit " .. vim.fn.fnameescape(filepath))
end

vim.api.nvim_set_keymap(
	"n",
	"<leader>td",
	"<cmd>lua open_daily()<CR>",
	{ noremap = true, silent = true, unique = true, desc = "Open daily note" }
)

vim.api.nvim_set_keymap(
	"n",
	"<leader>b",
	"<cmd>lua obsidian_up()<CR>",
	{ noremap = true, silent = true, unique = true, desc = "Custom Obsidian backlink" }
)

function _G.obsidian_up()
	local obsidian = require("obsidian")
	local api = require("obsidian.api")
	local search = require("obsidian.search")
	local backlinks = search.find_backlinks(api.current_note() or {})
	local new_backlinks = (function()
		local res = {}
		for _, note in ipairs(backlinks) do
			local id = note.path.filename:sub(24)
			id = string.gsub(id, '\\', '\\\\')
			if id:sub(1, 1) ~= "g" then
				table.insert(res, note)
			end
		end
		return res
	end)()
	if #new_backlinks == 0 then
		new_backlinks = backlinks
	end
	if #new_backlinks == 0 then
		return
	end
	if #new_backlinks == 1 then
		vim.cmd("edit" .. new_backlinks[1].path.filename)
		return
	end
	vim.cmd("Obsidian backlinks")
end

vim.api.nvim_set_keymap("n", "<leader>rd", "<cmd>redraw!<CR>", { noremap = true, silent = true, unique = true })
