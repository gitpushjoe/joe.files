local get_tags = require("get_tags")

local phandle = assert(io.popen("ls -p ~/vault/**/*.md"))
for path in phandle:lines() do
	if path == "" then
		break
	end
	print(path)
	local tags, err = get_tags(path)
	if err then
		error(err)
	end
	for _, tag in ipairs(assert(tags)) do
		print("  - " .. tag)
	end
end
