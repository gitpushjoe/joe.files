-- Requires luajit & luasocket
local get_tags = require("get_tags")
local socket = require("socket")
local strip_path = require("strip_path")

---@param inp string
---@param sep string
---@return string[]
local function split(inp, sep)
	local tbl = {}
	local pattern = "(.-)" .. sep
	local last_end = 1
	local start, _end, cap = inp:find(pattern, 1)
	while start do
		if start ~= 1 or cap ~= "" then
			table.insert(tbl, cap)
		end
		last_end = _end + 1
		start, _end, cap = inp:find(pattern, last_end)
	end
	if last_end <= #inp then
		cap = inp:sub(last_end)
		table.insert(tbl, cap)
	end
	return tbl
end

local ABSOLUTE_VAULT_PATH = arg[1] or ("%s/vault"):format(os.getenv("HOME"))

local category_list = {
	"gls",
	"ref",
	"imp",
	"nte",
	"def",
}

local get_categories = function()
	return ipairs(category_list)
end

local get_map_of_tags_to_paths, get_paths_with_tag, reset_map_of_tags_to_paths = (function()
	-- Maps [note type] -> { [tag (string)] -> [list of absolute paths to notes with tag `tag`] }
	---@type table<string, table<string, string[]>>
	local map = {
		gls = {},
		ref = {},
		imp = {},
		nte = {},
		def = {},
	}

	---@param cat string
	return function(cat)
		return map[cat]
	end,
	---@param cat string
	---@param tag string
	function(cat, tag)
		return map[cat][tag]
	end,
	function()
		map = { gls = {}, ref = {}, imp = {}, nte = {}, def = {} }
	end
end)()

local get_tags_of_path, set_tags_of_path, path_has_tag, reset_path_to_tag_map = (function()
	-- Maps absolute note paths to the set of its tags.
	---@type table<string, {string: 1}>
	local map = {}

	---@param path string
	return function(path)
		return map[path]
	end,
	---@param path string
	---@param tags string[]|nil
	function(path, tags)
		map[path] = tags
	end,
	---@param path string
	---@param tag string
	function(path, tag)
		return map[path] and map[path][tag] == 1 or false
	end,
	function()
		map = {}
	end
end)()

local get_all_paths_in_category, reset_all_note_paths = (function()
	-- Maps note types to the list of absolute paths of notes of that type.
	---@type table<string, string[]>
	local map = {
		gls = {},
		ref = {},
		imp = {},
		nte = {},
		def = {},
	}
	---@param cat 'gls'|'ref'|'imp'|'nte'|'def'
	return function(cat)
		return map[cat]
	end, function()
		map = {
			gls = {},
			ref = {},
			imp = {},
			nte = {},
			def = {},
		}
	end
end)()

-- Retuns the name of the most recent commit.
---@return string
local get_latest_commit_name = function()
	local phandle = assert(io.popen("cd ~/vault; echo -n $(git log -1 --pretty=%B)"))
	local out = phandle:read("*a")
	phandle:close()
	return out
end

---Returns the day_id of the current day
local get_day = function()
	local hour_to_avoid_daylight_savings_time_annoyances = 6
	local week_idx = math.floor(
		(
			tonumber(os.date("%s"))
			- tonumber(
				os.time({ year = 2025, month = 2, day = 3, hour = hour_to_avoid_daylight_savings_time_annoyances })
			)
		) / 604800
	)
	local day_idx = tonumber(os.date("%u")) - 1
	local week_base = math.floor(week_idx / 3) * 16
	local week_mod3 = week_idx % 3
	local today = week_base + day_idx + week_mod3 * 5
	return ("%03x"):format(today)
end

-- Returns a string such as "day042" depending on the current day.
local get_target_commit_name = function()
	return ("day%s"):format(get_day())
end

---@param group string|nil
---@return file*
local get_all_paths_phandle = function(group)
	group = group or "**"
	return assert(io.popen(("ls -1p -Q ~/vault/" .. group .. "/*.md")))
end

-- Check if the vault has been modified since we last checked.
local check_if_sync_is_necessary = function()
	local phandle = assert(io.popen("cd ~/vault && git status --porcelain"))
	local output = phandle:read("*a")
	local is_necessary = output ~= ""
	phandle:close()
	return is_necessary, output
end

---@param path string
---@param paths string[]
local remove_from_list = function(path, paths)
	local removals = 0
	for i = #paths, 1, -1 do
		if paths[i] == path then
			table.remove(paths, i)
			removals = removals + 1
		end
	end
	return removals
end

---Updates our understanding of the path `path` in category `cat`
local sync_path = function(path, cat)
	if path == "" then
		return
	end
	local tags = assert(get_tags(path))
	local note_was_deleted = tags == nil
	local note_existed = get_tags_of_path(path) ~= nil
	-- If the note was deleted or previously existed, we want to try to delete
	-- everything we knew about the note.
	if note_was_deleted or note_existed then
		print(("forgetting %s in category %s"):format(path, cat))
		local tag_to_paths_map = get_map_of_tags_to_paths(cat)
		for _, paths in pairs(tag_to_paths_map) do
			assert(remove_from_list(path, paths) < 2)
		end
		set_tags_of_path(path, nil)
		assert(remove_from_list(path, get_all_paths_in_category(cat)) < 2)
		if note_was_deleted then
			-- We have no more work to do.
			return
		end
	end
	print(("syncing %s in category %s"):format(path, cat))
	tags[""] = 1 -- Insert the null tag
	table.insert(assert(get_all_paths_in_category(cat)), path)
	set_tags_of_path(path, {})
	for tag in pairs(tags) do
		local tag_to_paths = get_map_of_tags_to_paths(cat)
		tag_to_paths[tag] = tag_to_paths[tag] or {}
		table.insert(tag_to_paths[tag], path)
		get_tags_of_path(path)[tag] = 1
	end
end

---@param lines string[]
local git_status_to_full_paths = function(lines)
	for i, line in ipairs(lines) do
		local start, stop = #" M " + 1, #line
		if line:sub(start, start) == '"' then
			start = start + 1
			stop = stop - 1
		end
		local path = ('"%s/%s"'):format(ABSOLUTE_VAULT_PATH, line:sub(start, stop))
		lines[i] = path
		print("modified path: " .. path)
	end
	return lines
end

-- Re-sync the in-memory data structures with the current state of the vault.
---@param only_these_paths (string[])|nil
local sync = function(only_these_paths)
	if not only_these_paths then
		reset_map_of_tags_to_paths()
		reset_all_note_paths()
		reset_path_to_tag_map()
	end
	os.execute("cd ~/vault && git add .")
	if only_these_paths then
		for _, path in ipairs(only_these_paths) do
			local cat = path:sub(#ABSOLUTE_VAULT_PATH + #"/" + 1, #ABSOLUTE_VAULT_PATH + #"/" + 3)
			assert(({
				gls = 1,
				ref = 1,
				imp = 1,
				nte = 1,
				def = 1,
			})[cat] == 1, cat)
			sync_path(path, cat)
		end
	end
	for _, cat in get_categories() do
		if not only_these_paths then
			reset_map_of_tags_to_paths[cat] = {}
			local phandle = get_all_paths_phandle(cat)
			for path in phandle:lines() do
				sync_path(path, cat)
			end
			phandle:close()
		end
	end
	if get_latest_commit_name() == get_target_commit_name() then
		os.execute("cd ~/vault && git commit --amend -m " .. get_target_commit_name() .. "; exit")
		return
	end
	os.execute("cd ~/vault && git commit -m " .. get_target_commit_name())
end

-- Returns a list of absolute note paths in the specified categories, that
-- contain the specified tags (if the first tag starts with "~", then that tag
-- is negated), and whose filename matcvhes the specified Lua filter.
---@param categories string[]
---@param tags string[]
---@param filter string
---@return string[]?, string?
local function fetch_note_paths(categories, tags, filter)
	local res = {}
	local category_iter = (#categories == 1 and categories[1] == "*") and get_categories() or ipairs(categories)
	for _, cat in category_iter do
		local paths = {}
		-- If there are no tags, we want to fetch everything.
		if #tags == 0 then
			table.insert(tags, 1, "")
		end
		-- If the first tag is inverted, then we still want to fetch everything,
		-- so that we can filter for only the notes that *don't* have this tag.
		if tags[1]:sub(1, 1) == "~" then
			table.insert(tags, 1, "")
		end
		local fetched_paths = get_paths_with_tag(cat, tags[1]) or {}
		-- Copy the list
		for _, path in ipairs(fetched_paths) do
			table.insert(paths, path)
		end
		for j = #paths, 1, -1 do
			(function()
				local path = paths[j]
				local stripped_note_path = strip_path(path, true, ABSOLUTE_VAULT_PATH)
				if filter ~= "*" and filter ~= "" then
					if not string.match(stripped_note_path, "^" .. filter) then
						table.remove(paths, j)
						return
					end
				end
				-- We can skip the first tag since we already filtered for it.
				for i = 2, #tags do
					local tag = tags[i]
					---@type boolean?
					local expected = true
					if tag:sub(1, 1) == "~" then
						tag = tag:sub(2)
						expected = false
					end
					if path_has_tag(path, tag) ~= expected then
						table.remove(paths, j)
						return
					end
				end
				paths[j] = path
			end)()
		end
		for _, path in ipairs(paths) do
			table.insert(res, path)
		end
	end

	local sorter = function(a, b)
		a, b = strip_path(a, true, ABSOLUTE_VAULT_PATH), strip_path(b, true, ABSOLUTE_VAULT_PATH)
		if a:sub(1, 5) < b:sub(1, 5) then
			return true
		end
		if a:sub(1, 5) > b:sub(1, 5) then
			return false
		end
		return #a < #b
	end

	table.sort(res, sorter)
	return res
end

---@class Query
---@field filter string
---@field tags string[]
---@field header string
---@field mods string[]

---@param categories string[]
---@param queries Query[]
---@return string?, string?
local function generate(categories, queries)
	local str = "> "
	for i, query in ipairs(queries) do
		local mods = query.mods
		str = str .. query.header .. "\n> "
		local main_files, err = fetch_note_paths(categories, query.tags, query.filter)
		if not main_files then
			return nil, err
		end
		for _, file in ipairs(main_files) do
			local prefix = ""
			if mods and #mods > 0 then
				prefix = "   "
				local tags = get_tags_of_path(file)
				for _, mod in ipairs(mods) do
					local display, tag = mod[1], mod[2]
					-- print(display, tag, mod[1], mod[2])
					if tags[tag] then
						prefix = display
					end
				end
			end
			str = str .. prefix .. "[[" .. strip_path(file, true, ABSOLUTE_VAULT_PATH) .. "]]\n> "
		end
		if i ~= #queries and #main_files == 0 then
			str = str .. "\n> "
		end
		str = str .. "\n> "
	end
	return str
end

-- Returns a random path in the specified category.
---@param cat string
local function fetch_random_path(cat)
	local paths = get_all_paths_in_category(cat)
	return assert(paths[math.floor(math.random() * #paths)])
end

-- Returns the first few lines of a random note in the specified category.
---@param cat string
---@return string?, string?
local function get_random_note(cat)
	local path = fetch_random_path(cat)
	path = strip_path(path, false, ABSOLUTE_VAULT_PATH)
	local handle = assert(io.open(path, "r"))
	local txt = ""
	local i = 1
	local is_first_line = true
	local parsed_header = false
	for line in handle:lines() do
		if is_first_line then
			is_first_line = false
		elseif not parsed_header then
			if line == "---" then
				parsed_header = true
			end
		elseif i <= 12 then
			txt = txt .. line .. "\n"
			i = i + 1
		else
			txt = txt .. "..."
			break
		end
	end
	txt = txt:gsub("\n$", ""):gsub("^\n*", "")
	return path:sub(#ABSOLUTE_VAULT_PATH + #"/zzz/" + 1, -4) .. "\n" .. "> \n> " .. txt:gsub("\n", "\n> ")
end

sync()

local host = "127.0.0.1"
local port = 8080

local server = assert(socket.bind(host, port))

server:settimeout(0)

print("Server listening on " .. host .. ":" .. port)
io.flush()

while true do
	local client = server:accept()
	if client then
		client:settimeout(10)
		local now = socket.gettime()
		local response = (
			(function()
				local inp, err = client:receive()
				if err then
					print("err", err)
					return err
				end

				if inp == "rand" then
					return get_random_note("ref")
				end

				local inp_parts = split(inp, " ; ")
				local queries = {}

				err = #inp_parts < 2 and 'error: expected 2 or more " ; "-separated groups, received ' .. #inp_parts
				if err then
					print("err", err)
					return err
				end

				for i = 2, #inp_parts do
					local query_str = inp_parts[i]
					print(query_str)
					local query_parts = split(query_str, " > ")
					if #query_parts < 3 then
						return ('error: expected group #%d to be split into at least 3 " > "-separated groups, received %d'):format(
							i - 1,
							#query_parts
						)
					end
					local mods = {}
					for j = 4, #query_parts do
						local mod = query_parts[j]
						if not mod:find(",") then
							return ('error: expected to find "," in mod: "%s"'):format(mod)
						end
						table.insert(mods, split(query_parts[j], ","))
					end
					---@type Query
					local query = {
						filter = query_parts[1],
						tags = split(query_parts[2], ","),
						header = query_parts[3],
						mods = mods,
					}
					table.insert(queries, query)
				end

				local sync_is_necessary, output = check_if_sync_is_necessary()
				if sync_is_necessary then
					sync(git_status_to_full_paths(split(output, "\n")))
				-- sync()
				else
					print("sync skipped!")
				end
				local text
				text, err = generate(split(inp_parts[1], ","), queries)
				text = text or ("error: " .. err)
				print(text)
				return text
			end)() .. "\n"
		)
		local diff = socket.gettime() - now
		print("responded in " .. math.floor(diff * 1000 * 100) / 100 .. "ms")
		client:send(response)
		print("closing!")
		client:close()
	end
end
