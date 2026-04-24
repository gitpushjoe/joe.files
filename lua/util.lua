---@generic H
---@generic T
---@generic D
---@param handle H|nil
---@param callback fun(handle: H): T
---@param default D|nil
---@param close (fun(handle: H): any)|nil
---@return T|D
local with = function(handle, callback, default, close)
	default = default or nil
	close = close or function(h)
		h:close()
	end
	if not handle then
		return default
	end
	local res = callback(handle)
	close(handle)
	return res
end

---@param cmd string
local exec = function(cmd)
	return with(io.popen(cmd), function(phandle)
		return phandle:read("*a")
	end, "")
end

return {
	with = with,
	exec = exec
}
