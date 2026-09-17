--- @alias SimpleGray.ColorVariant "dark" | "light"

--- Available background name variants for vim runtime.
--- @alias SimpleGray.BgVariant "dark" | "light"

local M = {}

--- Colorscheme name indentifier for this plugin.
local colorscheme_name = "simple-gray"

--- Clear and reapplies vim's colorscheme values such as background variant, colorscheme name, etc.
--- @param variant SimpleGray.ColorVariant
local function color_clear(variant)

  if vim.g.colors_name then
    vim.cmd("hi clear")
  end

  vim.o.background = variant
  vim.g.colors_name = ("%s-%s"):format(colorscheme_name, variant)

end

--- Loads the colorscheme based on a given color variant.
--- @param variant SimpleGray.ColorVariant color variant being used.
function M.load(variant)
  color_clear(variant)
end

return M
