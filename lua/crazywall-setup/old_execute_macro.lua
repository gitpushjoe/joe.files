-- Replaced this because after some time, it was too slow.
return function(parts, name, today)
	if #parts < 2 then
		return "Not enough parts. (Hint delim = ' | ')"
	end
	local type_and_key = vim.split(parts[1], ", ")
	local directory = type_and_key[1]
	local key = type_and_key[2]
	local type = parts[2]

	local main_parts = vim.split(parts[3], ", ")
	local main_dist = tonumber(main_parts[1], 16)
	local main_tags = vim.split(main_parts[2]:gsub("TTT", ("%03x"):format(today)), "#")
	local main_header = main_parts[3]

	local alt_parts, alt_tags, alt_header, alt_dist
	if type == "nrm" or type == "rev" then
		alt_parts = vim.split(parts[4] or "", ", ")
		alt_dist = tonumber(alt_parts[1], 16)
		alt_tags = vim.split(alt_parts[2] or "", "#")
		alt_header = alt_parts[3] or ""
	end

	local base_cmd = ([[rg --files ~/vault/%s --maxdepth 1 %s --color never]]):format(
		directory,
		key and ([[--files-with-matches -g "*%s*"]]):format(key .. ": ") or ""
	)

	local sorter = function(a, b)
		if a:sub(1, #"-/home/ubuntu/vault/---/" + 5) < b:sub(1, #"-/home/ubuntu/vault/---/" + 5) then
			return true
		end
		if a:sub(1, #"-/home/ubuntu/vault/---/" + 5) > b:sub(1, #"-/home/ubuntu/vault/---/" + 5) then
			return false
		end
		return #a < #b
	end

	local make_filter = function(tag)
		return ("%s grep -L -q '^  - %s$' \"$f\""):format(
			tag:sub(1, 1) == "~" and "!" or "",
			tag:sub(1, 1) == "~" and tag:sub(2) or tag
		)
	end

	local main_filter = "true"
	if #main_tags > 0 and main_tags[1] ~= "" then
		main_filter = make_filter(main_tags[1])
		for i = 2, #main_tags do
			main_filter = ("%s && %s"):format(main_filter, make_filter(main_tags[i]))
		end
	end

	local alt_filter = "false"
	if alt_tags then
		alt_filter = "true"
		if #alt_tags > 0 and alt_tags[1] ~= "" then
			alt_filter = make_filter(alt_tags[1])
			for i = 2, #alt_tags do
				alt_filter = ("%s && %s"):format(alt_filter, make_filter(alt_tags[i]))
			end
		end
	end

	local cmd = ([[
function in_range {
    local note_day=$1
    local today=$2
    local dist=$3
    if ! (( note_day > (today - dist) && note_day <= today )); then
        return 1
    else
        return 0
    fi
}
function process_file {
    local f=$1
    if [ ${#f} -gt 1 ]; then
        if ( %s && %s ); then
            echo "m$f"
        elif ( %s && %s ); then
            echo "a$f"
        fi
    fi
}
export -f in_range process_file

files=$(%s)
echo "$files" | parallel process_file
]]):format(
		main_dist == tonumber("fff", 16) and "true"
			or ('(in_range $(printf "%%d" "0x${f:24:3}") %d %s)'):format(today, main_dist),
		main_filter,
		alt_dist == tonumber("fff", 16) and "true"
			or ('(in_range $(printf "%%d" "0x${f:24:3}") %d %s)'):format(today, alt_dist),
		alt_filter,
		base_cmd
	)

	local cmd_output = vim.fn.system(cmd)
	print(cmd_output)
	local cmd_result = vim.fn.split(cmd_output, "\n")
	table.sort(cmd_result, sorter)
	local main_result = {}
	local alt_result = {}

	for _, line in ipairs(cmd_result) do
		if #line >= 2 then
			local is_main = line:sub(1, 1) == "m" and true
				or not assert(line:sub(1, 1) == "a", vim.fn.join(cmd_result, "\n") .. "\n" .. cmd)
			line = line:sub(#"#/home/ubuntu/vault/---/" + 1)
			line = ("[[%s]]"):format(line)
			table.insert(is_main and main_result or alt_result, line)
			-- end
		end
	end

	if type == "rev" then
		main_result, alt_result = alt_result, main_result
		main_header, alt_header = alt_header, main_header
	end

	-- while true do
	-- 	if i > #cmd_result then
	-- 		break
	-- 	end
	-- 	cmd_result[i] = cmd_result[i]:sub(#"/home/ubuntu/vault/imp/" + 1)
	-- 	local note_day = tonumber(cmd_result[i]:sub(2, 4), 16)
	-- 	if note_day and (note_day > today - reach and note_day <= today or alt_tag_title) then
	-- 		cmd_result[i] = "[[" .. cmd_result[i] .. "]]"
	-- 		i = i + 1
	-- 	else
	-- 		table.remove(cmd_result, i)
	-- 	end
	-- end
	-- i = 1
	-- while true do
	-- 	if i > #alt_cmd_result then
	-- 		break
	-- 	end
	-- 	alt_cmd_result[i] = alt_cmd_result[i]:sub(#"/home/ubuntu/vault/imp/" + 1)
	-- 	local note_day = tonumber(alt_cmd_result[i]:sub(2, 4), 16)
	-- 	if note_day and note_day > today - reach and note_day <= today then
	-- 		alt_cmd_result[i] = "[[" .. alt_cmd_result[i] .. "]]"
	-- 		i = i + 1
	-- 	else
	-- 		table.remove(alt_cmd_result, i)
	-- 	end
	-- end

	local res = ([[
> [!m%s]
> 
> %s%s
> %s
> [!%smend]
]])
		:format(
			name,
			main_header and (main_header .. "\n> " or "") or "",
			vim.fn.join(main_result, "\n> "),
			(
				alt_header
					and ([[

> %s%s
> ]]):format(alt_header and (alt_header .. "\n> " or "") or "", vim.fn.join(alt_result, "\n> "))
				or ""
			),
			name
		)
		:gsub("%.md", "")
	return res:sub(1, #res - 1)
end
