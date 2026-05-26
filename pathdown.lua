-- Read lines from stdin, find file paths, assign short keys, and write exports.

local alphabet = "abcdefghijklmnopqrstuvwxyz"
local i = 0
local keys = {}

local function get_tag()
	-- Excel/column-like sequence: a..z, aa..zz, aaa..zzz, etc.
	local n = i
	local s = ""
	repeat
		local r = n % 26
		s = alphabet:sub(r + 1, r + 1) .. s
		n = math.floor(n / 26) - 1
	until n < 0
	i = i + 1
	return s
end

local function strip_ansi_and_diff(s)
	if not s then
		return s
	end
	-- Remove ANSI SGR sequences like ESC[0m or ESC[1;32m
	s = s:gsub("\27%[[%d;]*m", "")
	s = s:gsub("^%d*m", "")
	-- Remove common git diff prefixes like '--- a/file' or '--- b/file'
	s = s:gsub("%-%-%- [ab]/?", "")
	-- Trim surrounding quotes and whitespace
	s = s:gsub("^%s*['\"]?", ""):gsub("['\"]?%s*$", "")
	if s:sub(1, 2) == "a/" or s:sub(1, 2) == "b/" then
		return s:sub(3)
	end
	return s
end

local key_map = {}

for line in io.lines() do
	local key = ""
	-- scan tokens containing word chars, punctuation and slash (so file paths included)
	local hex_digit = "[0123456789abcdef]"
	for j, pattern in ipairs({ '([%w_!"$&%+%-%./]+)', (hex_digit):rep(10) .. hex_digit .. "+" }) do
		for word in string.gmatch(line, pattern) do
			local cleaned = strip_ansi_and_diff(word)

			-- if cleaned contains only separators after stripping, skip
			if cleaned and #cleaned > 0 then
				if
					(function()
						if j == 2 then -- not a file, but a git hash
							return true
						end

						local f = io.open(cleaned, "r") or io.open("./" .. cleaned, "r")
						if not f then
							return false
						end
						f:close()
						return true
					end)()
				then
					key = key_map[cleaned] or get_tag()
					key_map[cleaned] = key
					table.insert(keys, { key, cleaned })
					-- stop at first existing file in the line
					break
				end
			end
		end
	end

	-- print colored key + original line (green key)
	io.write("\27[32m" .. "  " .. key .. (" "):rep(3 - #key) .. "\27[0m | " .. line .. "\n")
end

-- write the exports to the target shell script
local out = ""
for _, pair in ipairs(keys) do
	-- Escape any double quotes inside the path
	local path_escaped = pair[2]:gsub('"', '\\"')
	out = out .. ('export %s="%s"\n'):format(pair[1], path_escaped)
end

local script_path = ("%s/pathdown/pathdown.fish"):format(os.getenv("HOME"))
local script_handle = assert(io.open(script_path, "w"))
script_handle:write(out)
script_handle:close()
