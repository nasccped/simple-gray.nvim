local M = {}
local plugin = require("simple-gray")
local utils = require("test-aux.utils")

--- Set the new bg as vim background, then, loads the plugin with the background value as variant
--- parameter. Note that bg can only be either 'light' or 'dark'. Any other value can leads neovim
--- to crash.
--- @param bg "dark" | "light"
local function load_plugin_with_vim_bg(bg)
  vim.cmd("set background=" .. bg)
  plugin.load(vim.o.background)
end

--- Check vim runtime values AFTER plugin init.
--- @return boolean
function M.original_bg_persists()
  local result = true

  local target_bg = "dark"
  load_plugin_with_vim_bg(target_bg)
  result = utils.assert_eq(vim.o.background, target_bg) and result

  target_bg = "light"
  load_plugin_with_vim_bg(target_bg)
  result = utils.assert_eq(vim.o.background, target_bg) and result

  return result
end

return M
