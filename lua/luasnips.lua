local ls = require("luasnip")
local cmp = ls.cmp
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node
local fn = ls.function_node
local extras = require("luasnip.extras")
local util = require("util")

local rep = extras.rep

function _G.leave_snippet()
	if
		((vim.v.event.old_mode == "s" and vim.v.event.new_mode == "n") or vim.v.event.old_mode == "i")
		and require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
		and not require("luasnip").session.jump_active
	then
		require("luasnip").unlink_current()
	end
end

-- stop snippets when you leave to normal mode
vim.api.nvim_command([[
    autocmd ModeChanged * lua leave_snippet()
]])

local function split_lines_to_list(str, delimiter)
	delimiter = delimiter or "\n"
	local result = {}
	local from = 1
	local delim_from, delim_to = string.find(str, delimiter, from)
	while delim_from do
		table.insert(result, string.sub(str, from, delim_from - 1))
		from = delim_to + 1
		delim_from, delim_to = string.find(str, delimiter, from)
	end
	table.insert(result, string.sub(str, from))
	return result
end

local function add(filetypes, snippet, arg_nodes)
	local title, rest = assert(string.match(snippet, "(.-)\n(.*)"))
	snippet = rest
	local idx = 1
	local tbl = {}
	for _ = 1, 1024 do
		local before, name
		before, name, rest = string.match(snippet, "([^%%]+)%%([^%%]*)%%(.*)$")
		before = before or snippet
		before = before:find("\n") and split_lines_to_list(before) or before
		table.insert(tbl, t(before))
		if not name then
			break
		end
		if name == "0" then
			table.insert(tbl, i(0))
		else
			if name ~= "" then
				if name:sub(1, #"rep") == "rep" then
					-- horrible solution lol
					table.insert(tbl, rep(idx - 1))
					idx = idx - 1
				else
					table.insert(tbl, i(idx, name))
				end
			else
				table.insert(tbl, i(idx))
			end
			idx = idx + 1
		end
		snippet = rest
	end
	ls.add_snippets(filetypes, { s(title, tbl) }, arg_nodes)
end

vim.keymap.set({ "i", "s" }, "<cr>", function()
	if ls.locally_jumpable(1) then
		ls.expand_or_jump()
	else
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<cr>", true, true, true), "n", true)
	end
end, { silent = true })

add(
	"cpp",
	[[log
LOGV2(123042, "mydebug", "%name%"_attr = %1%);
]]
)

-- for loop
add(
	"cpp",
	[[fo
for (%%; %%; %%) {
	%0%
}
]]
)

-- for auto
add(
	"cpp",
	[[fa
for (auto %itr% : %ctnr%) {
	%0%
}
]]
)

-- for auto ref
add(
	"cpp",
	[[far
for (auto &%itr% : %ctnr%) {
	%0%
}
]]
)

-- for const auto
add(
	"cpp",
	[[fca
for (const auto %itr% : %ctnr%) {
	%0%
}
]]
)

-- for const auto ref
add(
	"cpp",
	[[fcar
for (const auto &%itr% : %ctnr%) {
	%0%
}
]]
)

-- lambda
add(
	"cpp",
	[[lm
[](%%) -> %auto% {
	%0%
};
]]
)

-- reference-all capture-group lambda
add(
	"cpp",
	[[alm
[&](%%) -> %auto% {
	%0%
};
]]
)

-- capture-group lambda
add(
	"cpp",
	[[clm
[%%](%%) -> %auto% {
	%0%
};
]]
)

-- vector
add(
	"cpp",
	[[vec
std::vector<%int%> %vec%%0%
]]
)

-- cout
add(
	"cpp",
	[[co
std::cout << %% << std::endl;]]
)

-- cerr
add(
	"cpp",
	[[ce
std::cerr << %% << std::endl;]]
)

-- endl
add(
	"cpp",
	[[el
std::endl%0%]]
)

-- cout endl
add(
	"cpp",
	[[coel
std::cout << std::endl;
]]
)

-- print vector with spaces
add(
	"cpp",
	[[pv
for (const auto &elem : %cntnr%) {
	std::cout << elem << " ";
}
]]
)

-- print vector with newline
add(
	"cpp",
	[[pvn
for (const auto &elem : %cntnr%) {
	std::cout << elem << std::endl;
}
]]
)

-- grind
for _, tag in ipairs({ "gls", "ref", "imp", "nte", "def" }) do
	add("markdown", ("%s\n> [!%s] %%0%%\n> [!%send]\n"):format(tag, tag, tag:sub(1, 1), tag:sub(1, 1)))
end

add("markdown", "qst\n> [!imp] qst: %%\n> +#$qst\n> [!iend]\n")
add("markdown", "qsts\n> [!mqsts] \n> [!qsts-mend]\n")
add("markdown", "tsk\n> [!imp] task: %%\n> +#$task\n> [!iend]\n")
add("markdown", "meet\n> [!ref] meet: %%\n> +#$meet\n> [!rend]\n")
add("markdown", "tsks\n> [!mtsks] \n> [!tsks-mend]\n")
add("markdown", "comm\n> [!comments] %%\n> [!cend]\n")
add("markdown", "cnv\n> [!convert] to %%\n> [!cnvend]\n")
add("markdown", [[backport
> [!imp] task: BACKPORT-%%

> [!ref] tick: BACKPORT-%rep%
> +#$ticket
> [Source]( https://jira.mongodb.org/browse/BACKPORT-%% )
> [Branch]( ]] .. require("private").github_ticket_format_str:gsub("SERVER", "BACKPORT") .. [[ )

> %0%
> [!rend]

> [!iend]
]])

add("markdown", [[sref
> [!ref] %%%%
> [Source]( %%%% )

> %0%

> [!rend]] .. "]")

add("markdown", [[retro
> [!ref] meet: Replication Team Retro
> %0%

> [!rend]] .. "]")

add("markdown", "src\n[Source]( %% )\n")

ls.add_snippets("cpp", {
	s("ps", {
		t('std::cout << " \\033[90m( '),
		fn(function()
			local filename = vim.fn.expand("%:t")
			local basename = vim.fn.fnamemodify(filename, ":t")
			local line_no = vim.fn.line(".")
			return basename .. ":" .. line_no .. " )\\033[0m"
		end, { 1 }),
		t(" "),
		rep(1),
		t(' = \\"" << '),
		i(1),
		t(' << "\\"" << std::endl;'),
	}),
})

ls.add_snippets("cpp", {
	s("px", {
		t('std::cout << " \\033[90m( '),
		fn(function()
			local filename = vim.fn.expand("%:t")
			local basename = vim.fn.fnamemodify(filename, ":t")
			local line_no = vim.fn.line(".")
			return basename .. ":" .. line_no .. " )\\033[0m"
		end, { 1 }),
		t(" "),
		rep(1),
		t(' = " << '),
		i(1),
		t(" << std::endl;"),
	}),
})

ls.add_snippets("cpp", {
	s("px-", {
		t('std::cout << " \\033[90m( '),
		fn(function()
			local filename = vim.fn.expand("%:t")
			local basename = vim.fn.fnamemodify(filename, ":t")
			local line_no = vim.fn.line(".")
			return basename .. ":" .. line_no .. " )\\033[0m"
		end, { 1 }),
		t(" "),
		rep(1),
		t(' = " << '),
		i(1),
		t(" << "),
	}),
})

ls.add_snippets("cpp", {
	s("px+", {
		t(' ", " << "'),
		rep(1),
		t(' = " << '),
		i(1),
		t(" << "),
	}),
})

ls.add_snippets("cpp", {
	s("nl", {
		t("std::endl;"),
	}),
})

ls.add_snippets("all", {
	s("hw", {
		t("Hello, World!"),
	}),
})

ls.add_snippets("cpp", {
	s("ae", {
		t("ASSERT_EQ("),
		i(0),
		t(");"),
	}),
})

local newline = function()
	t({ "" })
end

require("luasnip").filetype_extend("javascriptreact", { "typescriptreact" })
ls.add_snippets("typescriptreact", {
	s("tsx", {
		t("import styles from './"),
		i(1),
		t(".module.css';"),
		t({ "", "" }),
		t({ "", "" }),
		t("export default function "),
		rep(1),
		t("(props?: "),
		i(2),
		t(") {"),
		t({ "", "" }),
		t("\treturn <>"),
		t({ "", "" }),
		t("\t\t"),
		i(3),
		t({ "", "" }),
		t("\t</>"),
		t({ "", "" }),
		t("}"),
	}),
}, { override_priority = 1001 })

ls.add_snippets("cpp", {
	s("/*", {
		t("/*"),
		newline(),
		t(" * "),
		i(1),
		newline(),
		t(" */"),
		i(0),
	}),
})

ls.add_snippets("all", {
	s("day-", {
		t("day-"),
		fn(require("get_today")),
	}),
})

ls.add_snippets("all", {
	s("today", {
		fn(require("get_today")),
	}),
})

ls.add_snippets("markdown", {
	s("com", {
		t("  - $complete"),
		t({ "", "" }),
		t("  - day-"),
		fn(require("get_today")),
	}),
})

ls.add_snippets("markdown", {
	s("ans", {
		t("  - $answered"),
		t({ "", "" }),
		t("  - day-"),
		fn(require("get_today")),
	}),
})

ls.add_snippets("cpp", {
	s("mod", {
		t('#include "mongo/util/modules.h"'),
	}),
})

ls.add_snippets("javascript", {
	s("pj", {
		t("printjson({ mydebug: "),
		i(0),
		t(" });"),
	}),
})

---@param ticket_id string
local function query_jira_ticket(ticket_id)
	local text = util.exec(
		("curl https://jira.mongodb.org/rest/api/2/issue/%s  -H \"Authorization: Bearer $(cat ~/.jira-token.txt)\" 2>/dev/null | jq -r '.fields.summary, .fields.description'"):format(
			ticket_id
		)
	)
		:gsub("%s*$", "")
		:gsub("\r\n", "\n")
	local newline_idx = text:find("\n")
	local summary = text:sub(0, newline_idx)
	summary = summary == "null" and "" or summary
	summary = summary:gsub("[%[%]]", "")
	local description = text:sub(newline_idx + 1)
	description = require("jira_md_translator").jira_to_md(description)
	return summary, description
end

ls.add_snippets("markdown", {
	s("tick", {
		t("> [!imp] task: "),
		i(1),
		fn(function(args)
			if args[1][1] == "" then
				return " <- enter ticket ID"
			end
			local id = args[1][1]
			id = id:find("-") ~= nil and id or "SERVER-" .. id
			local summary, description = query_jira_ticket(id)
			local text = " " .. summary
			text = text .. ("\n\n> [!ref] tick: %s %s\n> +#$pin\n> +#$ticket"):format(id, summary)
			text = text .. ("\n> [Source]( https://jira.mongodb.org/browse/%s )"):format(id)
			text = text
				.. ("\n> [Branch]( %s%s )"):format(
					require("private").github_ticket_format_str:sub(
						0,
						require("private").github_ticket_format_str:find("SERVER") - 1
					),
					id
				)
			text = text .. ("\n\n> %s"):format(description:gsub("\n\n\n", "\n\n"):gsub("\n", "\n> "))
			text = text .. "\n> [!rend]\n\n> [!iend]\n"
			return vim.fn.split(text, "\n")
		end, { 1 }),
	}),
})

ls.add_snippets("markdown", {
	s("jira", {
		t("> [!ref] tick: "),
		i(1),
		fn(function(args)
			if args[1][1] == "" then
				return " <- enter ticket ID"
			end
			local id = args[1][1]
			id = id:find("-") ~= nil and id or "SERVER-" .. id
			local summary, description = query_jira_ticket(id)
			local text = " " .. summary
			text = text .. ("\n> +#$ticket\n> [Source]( https://jira.mongodb.org/browse/%s )"):format(id)
			text = text
				.. ("\n> [Branch]( %s%s )"):format(
					require("private").github_ticket_format_str:sub(
						0,
						require("private").github_ticket_format_str:find("SERVER") - 1
					),
					id
				)
			text = text .. ("\n\n> %s"):format(description:gsub("\n\n\n", "\n\n"):gsub("\n", "\n> "))
			text = text .. "\n> [!rend]"
			return vim.fn.split(text, "\n")
		end, { 1 }),
	}),
})
