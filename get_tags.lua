local strip_path = require("strip_path")

---@return table<string, 1>?, string?
local function get_tags(path)
	local h = io.open(strip_path(path), "r")
	if not h then
		return nil, "Could not open path: " .. path
	end
	local reading_lines = false
	local tags = {}
	for line in h:lines() do
		local should_break = (function()
			if line:sub(1, 1) == "t" then
				reading_lines = true
				return false
			end
			if not reading_lines then
				return false
			end
			if line:sub(1, 4) ~= "  - " then
				return true
			end
			local starts_with_dollar_sign = line:sub(#"  - $", #"  - $") == "$"
			local tag = line:sub(#"  - " + 1 + (starts_with_dollar_sign and 1 or 0))
			tags[tag] = 1
			return false
		end)()
		if should_break then
			break
		end
	end
	return tags
end

return get_tags
