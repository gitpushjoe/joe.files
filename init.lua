require("boring.setup_backup")()
require("boring.setup_options")()

require("boring.replace_vim_keymap_set")()

require("boring.highlight_on_yank")()

require("boring.setup_lazy")()
require("lazy").setup(require("lazy_plugins"))

require("boring.setup_lspconfig")()

require("personal")

require("plugins")
require("boring.setup_luasnip")
