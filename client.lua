local socket = require("socket")

local host = "127.0.0.1"
local port = 8080

local client = assert(socket.connect(host, port))

client:settimeout(10) -- 10 seconds timeout for server response

local message = table.concat(arg, ";")
client:send(message .. "\n")

local response, err = client:receive()
if err then
	print("Error receiving response: " .. err)
end

while true do
	local new_response  = client:receive()
	if new_response then
		response = response .. "\n" .. new_response
	else
		break
	end
end

client:close()
print(response)
