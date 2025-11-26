local jira_to_md_replacements = (function()
	local replacements = {
		{ "{code:lang=(%w+)}", "```%1" },
		{ "{code:(%w+)}", "```%1" },
		{ "{code}", "```" },
		{ "{noformat}", "\n```" },
		{ "[{}][{}]", "`" },
		{ "{%*}", "**" },
		{ "\n_([^\n]*)_%s*\n", "*%1*\n" },
		{ "%[([^%|]+)%|(http[^%]]+)%]", "[%1](%2)" }, -- gross
		{ "h1. ", "# " },
		{ "h2. ", "## " },
		{ "h3. ", "### " },
		{ "h4. ", "#### " },
		{ "h5. ", "##### " },
		{ "h6. ", "###### " },
		{
			"%[~([^%]]+)@mongodb%.com]",
			"**[%1]**",
		},
		-- {
		-- 	"%[~([^%]]+)@mongodb%.com]",
		-- 	"[%1](https://jira%.mongodb%.org/secure/ViewProfile%.jspa%?name=%1%%40mongodb.com)",
		-- },
	}
	for _, key in ipairs({
		"SERVER",
		"SLS",
		"BACKPORT",
		"MONGOCRYPT",
		"SLS",
		"KAFKA",
		"WRITING",
		"BF",
		"AF",
		"ANALYTICS",
		"STREAMS",
	}) do
		table.insert(replacements, {
			"(%s)(" .. key .. ")-(%d%d%d+)",
			"%1[%2-%3]%(https://jira.mongodb.org/browse/%2-%3%)",
		})
		return replacements
	end
end)()

local md_to_jira_replacements = {
	{ "```(%w+)\n", "{code:%1}\n" },
	{ "```", "{code}" },
	{ "`([^\n`]*)`", "{{%1}}" },
	-- { "%[([^%]]+)%]%(https://jira%.mongodb%.org/secure([^%)]+)%)", "%[~%1@mongodb.com]" },
	{ "%[([^%]]+)%]%(https://jira%.mongodb%.org/browse/%w+%-%w%)", "%1" },
	{ "%[([^%]]+)%]%((http[^%)]+)%)", "[%1|%2]" }, -- still gross
	{ "\n# ", "h1. " },
	{ "\n## ", "h2. " },
	{ "\n### ", "h3. " },
	{ "\n#### ", "h4. " },
	{ "\n##### ", "h5. " },
	{ "\n###### ", "h6. " },
}

---@param replacements string[]
local function apply_replacements(replacements)
	---@param str string
	return function (str)
		str = "\n" .. str
		for _, repl in ipairs(replacements) do
			local lhs, rhs = repl[1], repl[2]
			str = str:gsub(lhs, rhs)
		end
		str = str:sub(1, 1) == "\n" and str:sub(2) or str
		return str
	end
end


return {
	jira_to_md = apply_replacements(jira_to_md_replacements),
	md_to_jira = apply_replacements(md_to_jira_replacements)
}
