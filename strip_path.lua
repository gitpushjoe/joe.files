-- Converts a path like '"foo \\"bar\\""' -> 'foo "bar"'.
-- If `full` is `true`, then it also tries to convert an absolute path to a 
-- relative path.
---@param path string
---@param full boolean
return function(path, full)
	if path:sub(1, 1) == '"' and path:sub(-1, -1) == '"' then
		path = path:sub(2, -2):gsub('\\"', '"')
	end
	path = path:gsub("\\\\", "\\")
	if full then
		path = path:gsub("^/home/ubuntu/vault/.../", ""):gsub(".md$", "")
	end
	return path
end
