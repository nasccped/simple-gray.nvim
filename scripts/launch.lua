-- configs applied right after neovim init. This is used to checks plugin run without having to
-- directly ads it to user's config.
--
-- it's also used to load mini.test plugin lsp features since I'm using lua_ls.
vim.opt.rtp:prepend(".")
vim.opt.rtp:prepend("test-deps/mini.nvim")

require("mini.test").setup()

-- Plugin globally accessible
Plugin = require("simple-gray")
