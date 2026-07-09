# GRIND System

The GRIND system is a zettelkasten variation I created to organize my notes. There are two core tenets of the system:

1. There are only five folders (`gls/`, `ref/`, `imp/`, `nte/`, and `def/`) and no subfolders. All notes go into one of these five folders.
2. Every note's filename starts with the first letter of its folder followed by the day-id (explained below) of the day it was created.
  a. Notes don't need a title (i.e. `gls/g03f.md`) but if they do, there should be space after the day-id: (`ref/r03f OpenSSL Documentation.md`)


## Day IDs

A day-id is a string that uniquely identifies a day. In my system, it is a zero-padded hexadecimal number. 

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

Notice how by skipping days `00f`, `01f`, etc.:

1) The first 2 digits of the day id uniquely identify a 3-week period.
2) The last digit identifies the day of the week (`##0`, `##5`, `##a` days are always Mondays; `##1`, `##6`, `##c` days are always Wednesdays, etc.)
3) Day `##f` can be used to store retrospectives of the last 3-week periods.

The benefit of using hexadecimal numbers is that we now can uniquely identify every weekday using only 3 characters, without running out of strings for 14.7 years. 

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

The `gls/` folder stores what are typically called "daily notes". I recommend for all notes in `gls/` to have no title, i.e.:

```
gls/g000.md
gls/g001.md
gls/g002.md
```

Each `gls/` note should be a summary of the notes created that day in some way, containing references to notes of interest. It can also be used as a dashboard. For example, if you had a system that could list all currently pending tasks/questions, they can be stored in the `gls/` note of that day and updated frequently throughout the day. That way, each `gls/` note contains a historical record of the pending questions that occurred that day.

Example:

**gls/g005.md**
```md
g005: Started researching metaprogramming 

Defs:
[[d005 Metaprogramming]]
[[d005 Jai]]

Tasks:
[[i005 Look into the Jai programming language]]

Questions:
[[i005 qst: How does Rust handle metaprogramming differently from C++?]]
```

### ref/ (Reference)

The `ref/` folder primarily stores notes about "sources". Examples of sources include:

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

**ref/004 My Book.md**
```md
# My Book

[Source](https://my-book.com)

Written by [[r004 Some Author]]

[[r004 Prelude]]
[[r004 Chapter 1]]
[[r005 Chapter 2]]
[[r006 Chapter 3]]
```

**ref/r002 Tasks.md**
```md
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

**i003 task: Organize my folders**

**i004 This chapter reminds me of My Other Book**

**i005 qst: How does Rust handle metaprogramming differently from C++?**

### nte/ (Note)

The `nte/` folder stores ideas and topics from `ref` notes. Every `nte` should have a "parent" `ref` that refrences to it.
`nte/` notes can be nested. Like `imp/` notes, they sometimes don't need to store any text at all inside the note.

Examples:

**ref/r004 Chapter 1.md**
```md
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

**def/d004 CRTP**
```md
# CRTP

[Source](https://en.wikipedia.org/wiki/Curiously_recurring_template_pattern)
Curiously Recurring Template Pattern
```

**def/d005 Metaprogramming**
```md

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

**i001 qst: This is a question**
**i002 task: This is a task**
**r003 meet: This is a meeting**

### Plugins

#### obsidian-nvim/obsidian.nvim

I use [Obsidian syntax](https://obsidian.md/) in my notes so that with the [`obsidian.nvim` plugin](https://github.com/obsidian-nvim/obsidian.nvim), if I [hit `<Enter>` or type `gf`](https://github.com/gitpushjoe/joe.files/blob/8834b25/lua/lazy_plugins.lua?plain=1#L410-L415) with my cursor over a file reference (like [[r004 Something]]) Neovim will jump to that file. I can also use backlinks to [see which notes reference a particular note.](https://github.com/gitpushjoe/joe.files/blob/8834b25/lua/crazywall-setup/init.lua?plain=1#L279-L313). obsidian.nvim also has autocomplete that searches my vault when I begin to type a reference with `[[`, which makes linking to other notes very easy. I also use [YAML frontmatter](https://notes.nicolevanderhoeven.com/obsidian-playbook/Using+Obsidian/03+Linking+and+organizing/YAML+Frontmatter) to assign [tags](https://obsidian.md/help/tags) to my notes, which I can query with my [vault server](#vault-server). However, my primary way of navigating through the vault is to just either [search through all the text or search through all the filenames](https://github.com/gitpushjoe/joe.files/blob/b19b851073c0fb5e9def95226d3f76fd857643c6/lua/lazy_plugins.lua#L294-L295).

#### gitpulljoe/crazywall.nvim

The [crazywall.nvim](https://github.com/gitpulljoe/crazywall.nvim) plugin allows you to basically create a "tree" of sections while writing down notes (with sections nested within other sections), so that when you run the command `:Crazywall` or `:CrazywallQuick` in Neovim, each section gets recursively turned into _its own file_ and the section itself gets replaced with a reference to the file that was just created. Furthermore, you can write code to customize how exactly these files and filenames are generated. With my [crazywall config](https://github.com/gitpushjoe/joe.files/blob/8834b25/lua/crazywall-setup/init.lua?plain=1#L127-L231), I almost never have to create a file manually; I simply write nested sections, and then press `<leader>cq` to automatically write these sections to separate files.

For example, if I run crazywall on the following file:

**g042.md**
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

I get something like this:

**g042.md**
```md
[[r042 Replication Readme]]
```

**r042 Replication Readme.md**
```md
[[r042 Rollback]]
```

**r042 Rollback.md**
```md
[[d042 Rollback]]

[[n042 Situations that require rollback can occur due to network partitions]]

[[r042 RTT Algorithm]]
```

**d042 Rollback.md**
```
_Rollback is the process whereby a node that diverges from its sync source gets back to a consistent point in time on the sync source's branch of history._
```

**n042 Situations that require rollback can occur due to network partitions.md**
```

[[i042 task: Document example]]
```

**i042 task: Document example.md** 
```
#task
```

**d042 RTT Algorithm**
```
Recover To A Timestamp Algorithm
```

#### L3MON4D3/LuaSnip

However, typing out `> [!ref]` and `> [!rend]` manually each time would get exhausting.

I use the [Luasnip](https://github.com/L3MON4D3/LuaSnip) plugin to [create snippets](https://github.com/gitpushjoe/joe.files/blob/8834b25/lua/luasnips.lua?plain=1#L232-L257) for these section tags. For example, if I type `meet`, then press `<Tab>`, then type `Some Meeting` and hit `<Enter>`, it becomes:

```md
> [!ref] meet: Some Meeting
> [!rend]
```

#### MeanderingProgrammer/render-markdown.nvim

I use [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) to [colorize and "format" the appearance of these section tags](https://github.com/gitpushjoe/joe.files/blob/8834b25/lua/callouts.lua?plain=1#L3-L26), so the callout:

```md
> [!ref] meet: Standup
> [!rend]
```

shows up in my editor as

```md
| 📖 meet: Standup
| !rend
```

(The !rend should show up as a 🏳️ , but doesn't, due to what I believe is either a bug or missing feature in render-markdown, but I am not sure)

You can see an example of how this looks below (if I remembered to add it)

### Vault Server

I keep a [server](https://github.com/gitpushjoe/joe.files/blob/20a12ee61f368d99780b357b6acb528ca2c13191/main.lua) constantly running locally in the background, so that I can send it queries about the server and get responses. On startup, the server goes through all notes in the vault and [updates its internal data structures](https://github.com/gitpushjoe/joe.files/blob/20a12ee61f368d99780b357b6acb528ca2c13191/main.lua#L226-L262) to keep track of which notes there are, which notes are in which categories, what [tags](https://obsidian.md/help/tags) does each note have in its frontmatter, what are all the notes that have a certain tag, etc. It then git-commits the vault. Then, I can send a request to this server using [this `client.lua` script](https://github.com/gitpushjoe/joe.files/blob/20a12ee61f368d99780b357b6acb528ca2c13191/client.lua). For certain special sections, my crazywall config will [create and issue queries for me](https://github.com/gitpushjoe/joe.files/blob/8834b25/lua/crazywall-setup/init.lua?plain=1#L56). When the server receives a command, it uses git to [check which files have been modified since the last time it committed](https://github.com/gitpushjoe/joe.files/blob/20a12ee61f368d99780b357b6acb528ca2c13191/main.lua#L481-L487), and then executes the query and returns the result.

The syntax for the requests (well there are other kinds of requests, but this is the request type I use most commonly) is admittedly a bit bespoke:

 - So the format for a request is `[category] ; [queries...]`
  - where `[category]` is `gls`, `ref`, `imp`, `nte`, or `def`
  - and each `[queries...]` is at least 1 `query`. Multiple `queries` are separated by ` ; `.
    - The format for each `query` is `[regex-filter] > [tags-filter] > [heading](icon-pairs...)`
      - where `[regex-filter]` is a [Lua regex pattern](https://www.lua.org/pil/20.1.html) to use to filter the notes.
      - and `[tags-filter]` is a comma-separated (with no space) list of tags that each note in the response should have.
	- Furthermore, the _first_ tag in the list can start with `~` to signify that we should initially grab every note that does _not_ have that tag.
      - Heading is the heading that will be used for this section in the response
      - `(icon-pairs...)` is an optional argument that can be added to the `query`.
	- `(icon-pairs...)` is a list of `icon-pair`s. An `icon-pair` maps a certain icon (in my case, an emoji) to a tag so that if a note has that tag, it will appear with that icon.
	- The format for each `icon-pair` is ` > (icon-value),(tag)`.

You may understandably be wondering: "Why?" Well, I used to have some [disgusting Frankenstein'ed bash command](https://github.com/gitpushjoe/joe.files/blob/8834b250bea90f3a6f0968ffee4e414564af35aa/lua/crazywall-setup/old_execute_macro.lua) to do this work for me, but it eventually got so slow it took several seconds for my response to appear. Now, with all of the caching the server does, it can respond to each request in about 8ms-50ms, despite my >3900 files at the time of writing.

This may seem like an unecessary headache, but because of the caching, 

So how does this work in practice? Well, Every day, I [create a daily note](https://github.com/gitpushjoe/joe.files/blob/8834b250bea90f3a6f0968ffee4e414564af35aa/lua/crazywall-setup/init.lua?plain=1#L233-L270) for the day that contains the following text:

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

When I hit [`:<leader>cq`](https://github.com/gitpushjoe/joe.files/blob/8834b25/lua/personal/init.lua?plain=1#L572-L578) on this file, my [crazywall config](https://github.com/gitpushjoe/joe.files/blob/8834b25/lua/crazywall-setup/init.lua?plain=1#L127-L231) will do the following:

(note that the `TTT` in `day-TTT` will be replaced with the day ID [here](https://github.com/gitpushjoe/joe.files/blob/8834b25/lua/crazywall-setup/init.lua?plain=1#L55))

 - [expand the `[!mqsts]` section](https://github.com/gitpushjoe/joe.files/blob/b19b851073c0fb5e9def95226d3f76fd857643c6/lua/crazywall-setup/init.lua#L31) to the following request: `imp ; .....qst > ~answered > Unanswered: ; .....qst > answered,day-TTT > Answered:`
    - This will return two sections:
      - an `Unanswered` section containing all of the `imp` notes that match the pattern `.....qst` (note that the `.....` is to match against the note type and day-id in a filename like `i042 qst: yada yada yada`, so this effectively grabs all notes that start with `qst`) that do _not_ have the `answered` tag
      - an `Answered` section containing all of the `imp` notes that have the `answered` tag, and the `day-TTT` tag ([where the `TTT` in `day-TTT` will be replaced with the current day-id](https://github.com/gitpushjoe/joe.files/blob/8834b25/lua/crazywall-setup/init.lua?plain=1#L55))
 - [expand the `[!mtsks]` section](https://github.com/gitpushjoe/joe.files/blob/b19b851073c0fb5e9def95226d3f76fd857643c6/lua/crazywall-setup/init.lua#L32-L47) to the following request: `imp ; .....task > ~complete > Incomplete: > 🎫 ,ticket > ⌛ ,stale > 🚨 ,urgent > 🔁 ,pr > 🔁 ,pull-request ; .....task > complete,day-TTT > Complete:`  
  - The **Incomplete** section will contain all `imp` notes starting with `task` that do _not_ the `complete` tag. Also,
      - notes that have the `ticket` tag will have a 🎫 prefix, otherwise
      - notes that have the `stale` tag will have a ⌛ prefix, otherwise
      - notes that have the `urgent` tag will have a 🚨 prefix, and so on and so on
  - The **Complete** section will contain all `imp` notes with the `complete` tag and the `day-TTT` tag.
 - [expand the `ref` section](https://github.com/gitpushjoe/joe.files/blob/b19b851073c0fb5e9def95226d3f76fd857643c6/lua/crazywall-setup/init.lua#L48) to the following request: `ref ; * > pin > Pinned: ; * > day-TTT > New: ; .....meet > day-TTT > Meetings:`
   - The **Pinned:** section will contain all `ref` notes (note the `*` wildcard) with the `pin` tag
   - The **New:** section will contain all `ref` notes with the `day-TTT` tag
   - The **Meetings:** section will contain all `ref` notes starting with `meet` with the `day-TTT` flag.

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
> 🔁 [[i0c1 task: SERVER-<...> <...>]]
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

And here are [two](./screenshot1.png) [screenshots](./screenshot2.png) of how this actually appears in my editor.

### Recap dashboard

I also reserve days `##f` to create a recap dashboard (see [here](https://github.com/gitpushjoe/joe.files/blob/8834b25/lua/crazywall-setup/init.lua?plain=1#L52-L54) and [here](https://github.com/gitpushjoe/joe.files/blob/8834b25/lua/crazywall-setup/get_stats.lua?plain=1)) of the last three weeks. Below is my dashboard `g0bf` for days `0b0`-`0be`:

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
> | Day        | Unanswered | Answered | Σ        | . | Incomplete | Complete | Σ        | . | New Refs | Meetings |
> |------------|------------|----------|----------|---|------------|----------|----------|---|----------|----------|
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
> | .          | .          | .        | 2        | . | .          | .        | 33       | . | .        | .        |
> | *average*  | 6.40       | 0.07     | 0.13     | . | 12.27      | 1.80     | 2.20     | . | 1.27     | 0.67     |
> | *change*   | 📈 + 47%   | 📉 - 80% | 📉 - 66% | . | 📉 -  1%   | 📉 - 20% | 📈 + 26% | . | 📉 - 26% | 📉 - 23% |
> [!statmend]
```
