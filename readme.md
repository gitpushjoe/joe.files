# GRIND System

The GRIND system is a zettelkasten variation I created to organize my notes. There are two core tenets of the system:

1. There are only five folders (gls/, ref/, imp/, nte/, and def/) and no subfolders. All notes go into one of these five folders.
2. Every note's filename starts with the first letter of its folder followed by the day-id of the day it was created (explained below).
  a. Notes don't need a title (i.e. `gls/g03f.md`) but if they do, there should be space after the day-id: (`ref/r03f OpenSSL Documentation.md`)

## Day IDs

A day-id is a zero-padded hexadecimal number that uniquely identifies a day. 

There are several methods by which this value could be generated. My recommendation is as follows:

### Recommended Day ID Algorithm

Choose some preferred start date (perhaps the day this note collection was started). Let the "genesis date" be the first Monday before or on the start date.

The day-id of a day is the number of weekdays since the genesis date, except that an extra day is added every 15 days. 

Below is the March 2025 calendar if your genesis date was March 3, 2025:

```
 sun  mon  tue  wed  thr  fri  sat
+----+----+----+----+----+----+----+
|    |    |    |    |    |    |1   |
|    |    |    |    |    |    |    |
|    |    |    |    |    |    |    |
+----+----+----+----+----+----+----+
|2   |3   |4   |5   |6   |7   |8   |
|    |    |    |    |    |    |    |
|    | 000| 001| 002| 003| 004|    |
+----+----+----+----+----+----+----+
|9   |10  |11  |12  |13  |14  |15  |
|    |    |    |    |    |    |    |
|    | 005| 006| 007| 008| 009|    |
+----+----+----+----+----+----+----+
|16  |17  |18  |19  |20  |21  |22  |
|    |    |    |    |    |    |    |
|    | 00a| 00b| 00c| 00d| 00e|    |
+----+----+----+----+----+----+----+
|23  |24  |25  |26  |27  |28  |29  |
|    |    |    |    |    |    |    |
|    | 010| 011| 012| 013| 014|    |
+----+----+----+----+----+----+----+
|30  |31  |    |    |    |    |    |
|    |    |    |    |    |    |    |
|    | 015|    |    |    |    |    |
+----+----+----+----+----+----+----+
```

Notice how by skipping day `??f`:

1) The first 2 digits of the day id uniquely identifies a 3-week period.
2) The last digit identifies the day of the week (`??0` days are always Mondays, `??c` days are always Wednesdays, etc.)
3) Day `??f` can be used to store retrospectives of the last 3-week periods.

This algorithm is not suited for people who expect to keep the same notetaking strategy for more than 14.7 years.

Below is an implementation of this algorithm in Bash:

```sh
genesis="2025-03-03" # Set genesis here in this format

today=$(date +"%Y-%m-%d")
week_idx=$(( ($(date -d $today +%s) - $(date -d $genesis +%s)) / 604800 ))
day_idx=$(($(date -d $today +%u) - 1))
week_base=$(((week_idx / 3) * 16))
week_mod_3=$((week_idx % 3))
day=$((week_base + day_idx + week_mod_3 * 5))
printf "%03x\n" $day
```

and in Lua:

```lua
local function get_today()
	local week_idx =
		math.floor((tonumber(os.date("%s")) - tonumber(os.time({ year = 2025, month = 3, day = 3 }))) / 604800)
	local day_idx = tonumber(os.date("%u")) - 1
	local week_base = math.floor(week_idx / 3) * 16
	local week_mod3 = week_idx % 3
	local today = week_base + day_idx + week_mod3 * 5
	return ("%03x"):format(today)
end
```

## Folders

### gls/ (Glossary)

The `gls/` folder stores what are typically called "daily notes". All notes in `gls/` should have no title, i.e.:

```
gls/g000.md
gls/g001.md
gls/g002.md
```

Each `gls/` note should be a summary of the notes created that day in some way, containing references to notes of interest. It can also be used as a dashboard. For example, if you had a system that could list all currently pending tasks/questions, they can be stored in the `gls/` note of that day and updated frequently throughout the day. That way, each `gls/` note contains a historical record of the pending questions that occurred that day.

### ref/ (Reference)

The `ref/` folder primarily stores notes on "source". Examples of sources include:

 - a book
 - a chapter in a book
 - a website
 - a page in a website
 - a section in a page in a website
 - a README
 - a meeting
 - a collection of note references about a particular topic

Sources do not include:
 - an idea
 - a paragraph
 - a "todo" item
 - a reminder

Note that `ref`s can and should store references to other `ref`s.

Examples:

```md
ref/004 My Book.md

# My Book

[Source](https://my-book.com)

Written by [[r004 Some Author]]

[[r004 Prelude]]
[[r004 Chapter 1]]
[[r005 Chapter 2]]
[[r006 Chapter 3]]
```

```md
ref/r002 Tasks.md

# Tasks

[[i002 task: Clear out emails]]
[[i003 task: Start reading My Book]]
[[i003 task: Complete training]]
```

### imp/ (Impulse)

The `imp/` folder primarily stores ideas and connections, tasks, and questions. 
The idea notes in this folder should not simply be paraphrasings of some text; they should be "your own" ideas.
Oftentimes `imp/` notes don't even need to store any text; the title alone conveys enough information.

Examples:

```
i003 task: Organize my folders
i004 qst: How does Rust handle metaprogramming differently from C++?
i004 This chapter reminds me of My Other Book
```

### nte/ (Note)

The `nte/` folder stores ideas and topics from `ref` notes. Every `nte` should have a "parent" `ref` that refrences to it.
`nte/` notes can be nested.

Examples:

```md
ref/r004 Chapter 1.md

# Chapter 1

[[n004 A key concept from the first paragraph]]
[[n004 Another key concept from the first paragraph]]
[[n004 A third key concept from the first paragraph]]
[[n004 A key concept from the second paragraph]]
[[n004 Some key topic from the third and fourth paragraph]]

```

### def/ (Definition)

Each note in the `def/` folder stores the definition of the title of the note.
Definitions can, for example, be:

 - an expansion of an acronym/initialism
 - a short definintion
 - a short definintion followed by a link to a `ref/` or `nte/` note with the same name
 - the first paragraph of a Wikipedia page followed by the Wikipedia link

Examples:

```md
def/d004 CRTP

# CRTP

[Source](https://en.wikipedia.org/wiki/Curiously_recurring_template_pattern)
Curiously Recurring Template Pattern
```

```md
def/d005 Metaprogramming

# Metaprogramming

[Source](https://en.wikipedia.org/wiki/Metaprogramming)
**Metaprogramming** is a computer programming technique in which computer programs have the ability to treat other programs as their data. 
It means that a program can be designed to read, generate, analyse, or transform other programs, and even modify itself, while running.
In some cases, this allows programmers to minimize the number of lines of code to express a solution, in turn reducing development time.
It also allows programs more flexibility to efficiently handle new situations with no recompiling.
```

## How I use the GRIND system

I use the GRIND system when notetaking. I do all of my notetaking in Neovim.

### Conventions

I use three main naming conventions:

```md
i001 qst: This is a question
i002 task: This is a task
r003 meet: This is a meeting
```

### Plugins

#### obsidian-nvim/obsidian.nvim

I use Obsidian syntax in my notes so that with the [`obsidian.nvim` plugin](https://github.com/obsidian-nvim/obsidian.nvim), I can type `gf` with my cursor over a file reference (like [[r004 Something]]) to jump to that file. I can also use backlinks to [see which notes reference a particular note.](https://github.com/gitpushjoe/joe.files/blob/HEAD/lua/crazywall-setup/init.lua?plain=1#L279-L313). I also use [YAML frontmatter](https://notes.nicolevanderhoeven.com/obsidian-playbook/Using+Obsidian/03+Linking+and+organizing/YAML+Frontmatter) to assign tags to my notes, which I  can query with my vault server (TODO: add link).

#### gitpulljoe/crazywall.nvim

The [crazywall.nvim](https://github.com/gitpulljoe/crazywall.nvim) plugin allows you to create sections while writing in a file, such that when you run `:Crazywall` or `:CrazywallQuick`, these sections are automatically moved into separate files and replaced with references. With my [crazywall config](https://github.com/gitpushjoe/joe.files/blob/HEAD/lua/crazywall-setup/init.lua?plain=1#L127-L231), I almost never have to create a file manually; I simply write nested sections, and then press `<leader>cq` to automatically write these sections to separate files.

```md

> [!ref] Replication Readme

> [!ref] Rollback

> [!def] Rollback
_Rollback is the process whereby a node that diverges from its sync source gets back to a consistent point in time on the sync source's branch of history._
> [!dend]

> [!nte] Situations that require rollback can occur due to network partitions

> [!imp] task: Document example
> +#task
> [!iend]

> [!nend]

> [!def] RTT Algorithm
Recover To A Timestamp Algorithm
> [!dend]

> [!rend]

> [!rend]

```

becomes

```md
[[r042 Replication Readme]]
```

#### L3MON4D3/LuaSnip

I use [Luasnip](https://github.com/L3MON4D3/LuaSnip) to [create snippets](https://github.com/gitpushjoe/joe.files/blob/HEAD/lua/luasnips.lua?plain=1#L232-L257) for these section tags. For example,

```md
meet
```

after I press space and tab becomes

```md
> [!ref] meet: 
> [!rend]
```

#### MeanderingProgrammer/render-markdown.nvim

I use [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) to [colorize and "format" the appearance of these section tags](https://github.com/gitpushjoe/joe.files/blob/HEAD/lua/callouts.lua?plain=1#L3-L26), so the callout:

```md
> [!ref] meet: Standup
> [!rend]
```

shows up in my editor as

```md
| 📖 meet: Standup
| !rend
```

(The !rend should show up as a 🏳️ , due to what I believe is a bug in render-markdown)

### Vault Server

(TODO: create a branch for this and link to it)

Every day, I create a daily note for the day that contains the following text:

```md
---
id: g%s
aliases: []
tags:
  - team-repl
  - day-%s
created: "%s"
---

> [!mqsts]
> [!qstsmend]

> [!mtsks]
> [!tsksmend]

> [!mrefs]
> [!refsmend]
```

When I hit [`:<leader>cq`](https://github.com/gitpushjoe/joe.files/blob/HEAD/lua/personal/init.lua?plain=1#L572-L578) on this file, my [crazywall config](https://github.com/gitpushjoe/joe.files/blob/HEAD/lua/crazywall-setup/init.lua?plain=1#L127-L231) will:

(note that `day-TTT` will be replaced with the day ID [here](https://github.com/gitpushjoe/joe.files/blob/HEAD/lua/crazywall-setup/init.lua?plain=1#L55))

 - expand the `qsts` section to show all `imp/` files with names like `i??? qst...`, splitting them into two sections:
   - _(client query)_ `imp ; .....qst > ~answered > Unanswered: ; .....qst > answered,day-TTT > Answered:`
      - **Answered**
	    - Notes that do **not** have the `answered` tag, regardless of when created
      - **Unanswered**
	    - Notes that **do** have the `answered` tag, that also have the tag of the current day
 - expand the `tsks` section to show all the `imp/` files with names like `i??? task...`, splitting them into three sections:
    - _(client query)_ `imp ; .....task > ~complete > Incomplete: > 🎫 ,ticket > ⌛ ,stale > 🚨 ,urgent > 🔁 ,pr > 🔁 ,pull-request ; .....task > complete,day-TTT > Complete:`  
      - **Complete**
	    - Notes that do **not** have the `complete` tag, regardless of when created.
	    - Notes that have the `ticket` tag will have a 🎫 prefix, otherwise
	    - Notes that have the `stale` tag will have a ⌛ prefix, otherwise
	    - Notes that have the `urgent` tag will have a 🚨 prefix, otherwise
	    - Notes that have the `pr` or `pull-request` tag will have a 🔁 prefix
      - **Incomplete**
	    - Notes that **do** have the `complete` tag, that also have the tag of the current day
 - expand the `ref` section to show `ref` files, splitting them into three sections:
   - _(client query)_ `ref ; * > pin > Pinned: ; * > day-TTT > New: ; .....meet > day-TTT > Meetings:`
     - **Pinned**
       - Notes that have the `pin` tag
     - **New**
       - Notes that have the tag of the current day
     - **Meet**
       - Notes with names like `r??? meet...`

I treat this daily note as a sort of dashboard, and also a historical record of the work that was done or needed to be done that day.
Below is my actual `g0c4` note, with some data removed.

```md
---
id: g0c4
aliases: []
tags:
  - team-<...>
  - day-0c4
created: 2025-10-17
---

> [!mqsts]
> 
> Unanswered:
> [[i069 qst: How come <...>?]]
> [[i09a qst: What is a <...>?]]
> [[i09a qst: What is the other meaning of <...>?]]
> [[i0aa qst: What does <...> signify?]]
> [[i0ab qst: In what way does <...>?]]
> [[i0b1 qst: What is <...>]]
> [[i0b9 qst: What is <...>?]]
> 
> Answered:
> 
> 
> [!qstsmend]

> [!mtsks]
> 
> Incomplete:
>    [[i046 task: Create ticket to <...>]]
>    [[i065 task: Create <...> repo]]
> ⌛ [[i070 task: Submit <...> ticket]]
>    [[i0b6 task: Update <...> photo]]
>    [[i0b8 task: Create a document for <...>]]
> 🔁 [[i0c1 task: SERVER-110060 Add guardrail to detect new oplog entries being written by secondary]]
>    [[i0c2 task: Look into <...>]]
>    [[i0c4 task: Create <...> doc]]
>    [[i0c4 task: Add links to painpoints in <...>]]
>    [[i0c4 task: Set up some time with <...> to talk about <...>]]
> 
> Complete:
> [[i0c0 task: BACKPORT-<...> <...>]]
> [[i0c4 task: Prepare for <...>]]
> 
> 
> [!tsksmend]

> [!mrefs]
> 
> Pinned:
> [[r086 tick: SERVER-108347 Modularize all of src\mongo\db\repl]]
> [[r097 tick: SERVER-109562 Modularize the final uncategorized files under replication]]
> [[r0a1 tick: SERVER-109328 Documentation for GenericArguments]]
> [[r0c2 tick: SERVER-112534 Create a generic state machine class to standardize our state machines]]
> 
> New:
> [[r0c4 meet: OOO with <...>]]
> [[r0c4 meet: <...>]]
> 
> Meetings:
> [[r0c4 meet: OOO with <...>]]
> [[r0c4 meet: <...>]]
> 
> 
> [!refsmend]
```

I also reserve days `??f` to create a recap dashboard (see [here](https://github.com/gitpushjoe/joe.files/blob/HEAD/lua/crazywall-setup/init.lua?plain=1#L52-L54) and [here](https://github.com/gitpushjoe/joe.files/blob/HEAD/lua/crazywall-setup/get_stats.lua?plain=1)) of the last three weeks. Below is my dashboard `g0bf` for days `0b0`-`0be`:

```md
---
id: g0bf
aliases: []
tags:
  - team-repl
  - day-0bf
created: 2025-03-14
---

> [!mstat]
> | Day      | Unanswered | Answered | Σ        | . | Incomplete | Complete | Σ        | . | New Refs | Meetings |
> |----------|------------|----------|----------|---|------------|----------|----------|---|----------|----------|
> | [[g0b0]]   | 6          | 0        | .        | . | 15         | 1        | .        | . | 1        | 1        |
> | [[g0b1]]   | 6          | 1        | .        | . | 14         | 2        | .        | . | 0        | 0        |
> | [[g0b2]]   | 6          | 0        | .        | . | 10         | 6        | .        | . | 1        | 0        |
> | [[g0b3]]   | 6          | 0        | .        | . | 10         | 0        | .        | . | 0        | 0        |
> | [[g0b4]]   | 6          | 0        | .        | . | 11         | 4        | .        | . | 4        | 2        |
> | [[g0b5]]   | 6          | 0        | .        | . | 10         | 2        | .        | . | 1        | 1        |
> | [[g0b6]]   | 6          | 0        | .        | . | 11         | 3        | .        | . | 2        | 1        |
> | [[g0b7]]   | 6          | 0        | .        | . | 12         | 1        | .        | . | 0        | 0        |
> | [[g0b8]]   | 6          | 0        | .        | . | 10         | 2        | .        | . | 0        | 0        |
> | [[g0b9]]   | 7          | 0        | .        | . | 14         | 1        | .        | . | 5        | 2        |
> | [[g0ba]]   | 7          | 0        | .        | . | 13         | 3        | .        | . | 1        | 1        |
> | [[g0bb]]   | 7          | 0        | .        | . | 13         | 0        | .        | . | 0        | 0        |
> | [[g0bc]]   | 7          | 0        | .        | . | 12         | 2        | .        | . | 1        | 0        |
> | [[g0bd]]   | 7          | 0        | .        | . | 12         | 0        | .        | . | 2        | 1        |
> | [[g0be]]   | 7          | 0        | .        | . | 17         | 0        | .        | . | 1        | 1        |
> | .        | .          | .        | 2        | . | .          | .        | 33       | . | .        | .        |
> | *average*  | 6.40       | 0.07     | 0.13     | . | 12.27      | 1.80     | 2.20     | . | 1.27     | 0.67     |
> | *change*   | 📈 + 47%   | 📉 - 80% | 📉 - 66% | . | 📉 -  1%   | 📉 - 20% | 📈 + 26% | . | 📉 - 26% | 📉 - 23% |
> [!statmend]
```
