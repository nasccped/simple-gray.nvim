local eq = MiniTest.expect.equality
local p_load = Plugin.load

--- Set's neovim background variant by using 'vim.cmd' function.
--- Note that valid variants are only 'light' and 'dark'.
--- @param variant "light" | "dark"
local function set_bg(variant)
  vim.cmd("set background=" .. variant)
end

describe("runtime background handling", function()

  -- ensures that loading the theme with current background doesn't change original stage.
  it("using default", function()

    local original = vim.o.background
    p_load(original)
    eq(vim.o.background, original)

  end)

  -- ensure theme loading changes background whenever necessary.
  it("bg remains same state", function()

    local variant = "dark"
    set_bg(variant)
    p_load(vim.o.background)
    eq(vim.o.background, variant)

    variant = "light"
    set_bg(variant)
    p_load(vim.o.background)
    eq(vim.o.background, variant)

  end)

end)
