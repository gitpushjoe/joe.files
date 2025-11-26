-- Returns the id for today.
return function()
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

