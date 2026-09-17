-- Loads local utils module
local utils = require("test-aux.utils")

--- Exits the program with the provided code.
--- @param code integer
local function exit_with_code(code)
  vim.cmd("cquit " .. tostring(code))
end

--- Colorizes the string with the provided ansi escape code.
--- @param str string
--- @param code integer
local function colorize(str, code)
  return "\27[" .. tostring(code) .. "m" .. str .. "\27[0m"
end

--- Does the tagged printing by using a custom print function.
--- @param tag string
--- @param message string
--- @param print_func fun(message: string): nil
local function _print_tagged(tag, message, print_func)
  print_func(("    %s) %s"):format(tag, message))
end

--- Does message printing with fatal tag (using stderr).
--- @param message string
local function print_fatal(message)
  utils.eprintln(colorize("fatal", 91) .. ": " .. message)
end

--- Does message printing with fail tag (using stderr).
--- @param message string
local function print_fail(message)
  _print_tagged(colorize("fail", 91), message, utils.eprintln)
end

--- Does message printing with done tag (using stdout).
--- @param message string
local function print_done(message)
  _print_tagged(colorize("done", 92), message, utils.println)
end

--- Does message printing with warning tag (using stdout).
--- @param message string
local function print_warn(message)
  _print_tagged(colorize("warn", 93), message, utils.println)
end

--- Behavior to follow when 'handle' local variable refers to 'nil' value. Consider taking a look
--- at handle if/else checks comments. This function help to avoid duplicates instructions.
--- @param err? string
local function nil_handle_behavior(err)
  print_fatal("couldn't open directory: " .. (err and tostring(err) or "<nil error>"))
  exit_with_code(1)
end

--- Test files directory.
local TEST_DIR = "tests"

--- Refers to the 'UNREACHABLE' indicator tag.
local UNREACHABLE = colorize("[UNREACHABLE]", 1)

--- Refers to the 'SKIPPING' indicator tag.
local SKIPPING = colorize("[SKIPPING]", 1)

--- Refers to the 'TEST CASE' indicator tag.
local TEST_CASE = colorize("[TEST CASE]", 1)

--- Code used for neovim exit.
local exit_code = 0

-- add current plugin to runtime path
vim.opt.rtp:prepend(".")

-- scan for test files
local handle, err = vim.uv.fs_scandir(TEST_DIR)

-- this if check is cloned within 'while' loop. consider reading it right bellow.
if handle == nil then
  nil_handle_behavior(err)
end

-- test case counters
local passed_count, failed_count, warn_count = 0, 0, 0

-- load module values
local module_name, require_ok, module

-- load module field values
local field_type, return_value, return_type
local empty_module

utils.println("Running test files at '" .. TEST_DIR .. "' dir:\n")

while true do
  -- entry data
  local entry_name, entry_type

  -- handle as nil means scanning failure.
  --
  -- note: this was handled here (within 'while' loop) due to 'lua_ls' lsp arguing about passing
  -- possible nil value to 'fs_scandir_next' function (at else branch).
  if handle == nil then
    nil_handle_behavior(err)
  else
    entry_name, entry_type = vim.uv.fs_scandir_next(handle)
  end

  -- exit loop if entry is nil (means handle's iteration finish).
  if entry_name == nil then
    break
  end

  if entry_type ~= "file" or not entry_name:match("%.lua$") then
    utils.println(SKIPPING .. " not a lua file: " .. entry_name)
    goto continue_modules
  end

  -- module name + try require
  module_name = TEST_DIR .. "." .. entry_name:gsub("%.lua$", "")
  require_ok, module = pcall(require, module_name)

  -- require not succeeds
  if not require_ok then
    utils.eprintln(UNREACHABLE .. " pcall(require, '" .. module_name .. "') not succeeds")
    exit_code = 1
    goto continue_modules

  -- require succeeds but doesn't refers to a table.
  elseif type(module) ~= "table" then
    utils.eprintln(
      (
        "%s pcall(require, '%s') succeeds but module doesn't refers to a table: %s"
      ):format(UNREACHABLE, module_name, type(module))
    )
    exit_code = 1
    goto continue_modules
  end

  utils.println(TEST_CASE .. " running all tests for '" .. module_name .. "' module")

  -- local variables for field and test case returning
  empty_module = true

  for k, v in pairs(module) do

    field_type = type(v)

    -- current case isn't a function
    if field_type ~= "function" then
      print_warn("'" .. k .. "' field isn't a function: " .. field_type)
      utils.println("          you must use it as local value.")
      warn_count = warn_count + 1
      goto continue_test_cases
    end

    -- run case + take type
    return_value = v()
    return_type = type(return_value)

    -- when test case returns a non-boolean value
    if return_type ~= "boolean" then
      print_warn(("'%s' test case returned '%s' when 'boolean' was expected"):format(
        k, return_type
      ))
      warn_count = warn_count + 1

    -- when test case succeeds
    elseif return_value then
      print_done("'" .. k .. "' test case passed")
      passed_count = passed_count + 1

    -- when test case fails
    else
      print_fail("'" .. k .. "' test case failed")
      failed_count = failed_count + 1
      exit_code = 1
    end

    ::continue_test_cases::
    empty_module = false
  end

  if empty_module then
    print_warn("module doesn't have any accessible field")
    warn_count = warn_count + 1
  end

  ::continue_modules::
  utils.println("")
end

-- 1 line gap + print summary
utils.println("Summary:")
utils.println("  " .. tostring(passed_count) .. " test(s) " .. colorize("passed", 92))
utils.println("  " .. tostring(failed_count) .. " test(s) " .. colorize("failed", 91))
utils.println("  " .. tostring(warn_count) .. " warn(s) " .. colorize("emmited", 93))

-- exit with code
exit_with_code(exit_code)
