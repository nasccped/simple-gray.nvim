-- NOTE: this recipe is suggested my mini.test doc pages (at
--       https://github.com/nvim-mini/mini.nvim/blob/main/TESTING.md)
vim.cmd("let &rtp.=','.getcwd()")

if #vim.api.nvim_list_uis() == 0 then
  vim.cmd("set rtp+=test-deps/mini.nvim")
  require("mini.test").setup()
end

-- Plugin globally accessible
Plugin = require("simple-gray")
