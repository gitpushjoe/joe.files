local util = require("util")

-- Returns the stats for the last three week period (e.g. days 050-05e) comparing it to the three-week period before it.
---@param period integer
return function(period)
	---@param str string|number
	---@param length integer
	---@param pad_char string?
	local function rpad(str, length, pad_char)
		pad_char = pad_char or " "
		str = tostring(str)
		return str .. string.rep(pad_char, length - #str)
	end

	local function count_imp_files(p, prefix)
		return tonumber(util.exec(("find /home/ubuntu/vault/imp -name 'i%02x??%s*' | wc -l"):format(p, prefix))) or 0
	end

	local res = "> [!mstat]"
	res = res
		.. "\n> | Day      | Unanswered | Answered | Σ        | . | Incomplete | Complete | Σ        | . | New Refs | Meetings |"
		.. "\n> |----------|------------|----------|----------|---|------------|----------|----------|---|----------|----------|"

	---@class DailyStats
	---@field [1] integer unanswered question count
	---@field [2] integer answered question count
	---@field [3] integer incomplete task count
	---@field [4] integer complete task count
	---@field [5] integer pinned reference count
	---@field [6] integer new reference count
	---@field [7] integer meeting count

	-- Returns a list `tbl` where `tbl[i]` is a table containing the number of references in each section of the i'th daily note of this period.
	---@return DailyStats[]
	local get_data = function(p)
		local data = {}
		for i = 0, 14 do
			data[i] = (function()
				local default = vim.deepcopy(data[i - 1]) or {}
				local ANSWERED_QUESTION_COUNT_IDX = 2
				local COMPLETE_TASK_COUNT_IDX = 4
				local NEW_REFERENCE_COUNT_IDX = 6
				default[ANSWERED_QUESTION_COUNT_IDX] = 0
				default[COMPLETE_TASK_COUNT_IDX] = 0
				default[NEW_REFERENCE_COUNT_IDX] = 0
				return util.with(io.open(("/home/ubuntu/vault/gls/g%02x%x.md"):format(p, i), "r"), function(handle)
					local gen = handle:lines()
					local line = gen()
					local counts = {}
					while line do
						while line and not line:match("> .*:") do
							line = gen()
						end
						table.insert(counts, 0)
						line = gen()
						while line and line ~= "> " do
							counts[#counts] = counts[#counts] + 1
							line = gen()
						end
					end
					counts[#counts] = nil
					return counts
				end, default)
			end)()
		end
		return data
	end

	local data = get_data(period)
	for i = 0, 14 do
		local counts = data[i]
		if counts then
			res = res
				.. ("\n> | [[g%02x%x]]   | %s        | %s      | .        | . | %s        | %s      | .        | . | %s      | %s      |"):format(
					period,
					i,
					rpad(counts[1] or 0, 3),
					rpad(counts[2] or 0, 3),
					rpad(counts[3] or 0, 3),
					rpad(counts[4] or 0, 3),
					rpad(counts[6] or 0, 3),
					rpad(counts[7] or 0, 3)
				)
		end
	end

	-- Adds up all the notes in a particular section across all days.
	local sum = function(i, tbl)
		tbl = tbl or data
		local total = 0
		for j = 0, 14 do
			total = total + ((tbl[j] or {})[i] or 0)
		end
		return total
	end

	local prev_data = get_data(period - 1)
	local get_percent_diff = function(val1, val2)
		return val2 >= val1 and ("📈 +%3d%%"):format(math.min(999, math.floor(100 * (val2 - val1) / val1)))
			or ("📉 -% 3d%%"):format(math.min(999, 100 * (val1 - val2) / val1))
	end
	local get_percent_diff_of_sum = function(i)
		local sum1, sum2 = sum(i, prev_data), sum(i)
		return get_percent_diff(sum1, sum2)
	end

	local qst_count, task_count = count_imp_files(period, "qst"), count_imp_files(period, "task")
	res = res
		.. ("\n> | .        | .          | .        | %s | . | .          | .        | %s | . | .        | .        |"):format(
			rpad(qst_count, 8),
			rpad(task_count, 8)
		)
	res = res
		.. ("\n> | *average*  | %s      | %s    | %s    | . | %s      | %s    | %s    | . | %s    | %s    |"):format(
			rpad(("%.2f"):format(sum(1) / 15), 5),
			rpad(("%.2f"):format(sum(2) / 15), 5),
			rpad(("%.2f"):format(qst_count / 15), 5),
			rpad(("%.2f"):format(sum(3) / 15), 5),
			rpad(("%.2f"):format(sum(4) / 15), 5),
			rpad(("%.2f"):format(task_count / 15), 5),
			rpad(("%.2f"):format(sum(6) / 15), 5),
			rpad(("%.2f"):format(sum(7) / 15), 5)
		)
	res = res
		.. ("\n> | *change*   | %s   | %s | %s | . | %s   | %s | %s | . | %s | %s |"):format(
			get_percent_diff_of_sum(1),
			get_percent_diff_of_sum(2),
			get_percent_diff(count_imp_files(period - 1, "qst"), qst_count),
			get_percent_diff_of_sum(3),
			get_percent_diff_of_sum(4),
			get_percent_diff(count_imp_files(period - 1, "task"), task_count),
			get_percent_diff_of_sum(6),
			get_percent_diff_of_sum(7)
		)
	res = res .. "\n> [!statmend]"
	return res
end
