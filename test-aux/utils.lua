local M = {}

--- Gap space used when priting assertion stuff.
local ASSERT_PRINT_GAP = (" "):rep(6)

--- Prints the provided message to stdout with a new line at the end.
--- @param message string
function M.println(message)
  io.stdout:write(message .. "\n")
end

--- Prints the provided message to stderr with a new line at the end.
--- @param message string
function M.eprintln(message)
  io.stderr:write(message .. "\n")
end

--- Prints that the assertion was failed by taking the assertion name, the line number of assertion
--- call and the message string. Since assertion fail always refer to an error, this function
--- always prints to stderr.
--- @param assertion_name string
--- @param assertion_line integer
--- @param message string
local function print_assertion_failed(assertion_name, assertion_line, message)
  M.eprintln(ASSERT_PRINT_GAP .. ("%s(%d) failed => %s"):format(
    assertion_name,
    assertion_line,
    message
  ))
end

--- Deeply compare values. This function is just a shorthand for assert_eq function but it can run
--- for nested tables without messing on printing stuff.
--- @param l any
--- @param r any
--- @return boolean
local function deep_equal(l, r)
  -- same identity means same value
  if l == r then return true
  -- not same type
  elseif type(l) ~= type(r) then return false
  -- not table (was supposed to already result in true at first if)
  elseif type(l) ~= "table" then return false end

  -- for each left key-value pair
  for k, v in pairs(l) do
    if not deep_equal(v, r[k]) then return false end
  end

  -- for each right key-value pair
  for k, v in pairs(r) do
    if not deep_equal(l[k], v) then return false end
  end

  return true
end

--- Asserts the provided val only if is boolean type. Basically, no truthy allowed. Just boolean
--- literal. This function can optionally accepts a string message which acts as string format when
--- more args provided.
--- @param val any
--- @param message? string
--- @return boolean
function M.assert_bool(val, message, ...)
  local result = true
  local assertion_name, assertion_line = "assert_bool", debug.getinfo(2, "Sl").currentline
  local val_type = type(val)

  if val_type ~= "boolean" then
    print_assertion_failed(
      assertion_name,
      assertion_line,
      "got '" ..  val_type .. "' when 'boolean' was expected!"
    )
    result = false

  elseif not val then
    print_assertion_failed(
      assertion_name,
      assertion_line,
      message and message:format(...) or "result is false!"
    )
    result = false
  end

  return result
end

--- Asserts if both left and right instances refers to same type and values. This function actually
--- calls the deep_equal to ensure multidimensional table comparing.
--- @param left any
--- @param right any
--- @param message? string
--- @return boolean
function M.assert_eq(left, right, message, ...)
  local result = true
  local assertion_name, assertion_line = "assert_eq", debug.getinfo(2, "Sl").currentline
  local lt, rt = type(left), type(right)

  if lt ~= rt then
    message = (
      -- message title
      "left and right refers to distinct types:\n" ..

      -- left row
      ASSERT_PRINT_GAP .. (" "):rep(assertion_name:len() + tostring(assertion_line):len() + 3) ..
      "left:  " .. lt .. "\n" ..

      -- right row
      ASSERT_PRINT_GAP .. (" "):rep(assertion_name:len() + tostring(assertion_line):len() + 3) ..
      "right: " .. rt
    )
    print_assertion_failed(assertion_name, assertion_line, message)
    result = false

  elseif not deep_equal(left, right) then
    message = (
      -- message title
      (message and message:format(...) or "left and right aren't equals") .. "\n" ..

      -- left row
      ASSERT_PRINT_GAP .. (" "):rep(assertion_name:len() + tostring(assertion_line):len() + 3) ..
      "left:  " .. vim.inspect(left) .. "\n" ..

      -- right row
      ASSERT_PRINT_GAP .. (" "):rep(assertion_name:len() + tostring(assertion_line):len() + 3) ..
      "right: " .. vim.inspect(right)
    )
    print_assertion_failed(assertion_name, assertion_line, message)
    result = false
  end

  return result
end

--- Does the negative value assertion (assert not equals). On two distinct objects. Note that lua
--- supports different types comparation, so calling 'assert_neq(int, string)' returns true. Just
--- keep in mind that conversions aren't made, so 'assert_neq(1, 1.0)' can returns true too due to
--- type mismatch, even when they refers (meaningly) to the same value.
--- @param left any
--- @param right any
--- @param message? string
--- @return boolean
function M.assert_neq(left, right, message, ...)
  local result = true
  local assertion_name, assertion_line = "assert_neq", debug.getinfo(2, "Sl").currentline

  if deep_equal(left, right) then
    message = (
      (message and message:format(...) or "both objects refers to same value:") .. "\n" ..
        ASSERT_PRINT_GAP .. (" "):rep(assertion_name:len() + tostring(assertion_line):len() + 3) ..
        "vim.inspect: " .. vim.inspect(left)
    )
    print_assertion_failed(
      assertion_name,
      assertion_line,
      message
    )
    result = false
  end

  return result
end

return M
