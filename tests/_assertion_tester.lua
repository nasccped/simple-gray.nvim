local M = {}
local utils = require("test-aux.utils")

--- Checks boolean assertions.
--- @return boolean
function M.bool_assertion()
  local result = true

  result = utils.assert_bool(true) and result
  result = utils.assert_bool(not false) and result
  result = utils.assert_bool(true, "with custom message") and result
  result = utils.assert_bool(not false, "with custom %s message", "formated") and result

  return result
end

--- Checks eq comparison assertions.
--- @return boolean
function M.eq_assertion()
  local result = true
  local i1, i2 = 2, 1 + 1
  local s1, s2 = "cool string", (("cool world"):gsub("(world)", "string"))
  local f1, f2 = 0.9, 0.9
  local t1, t2 = {1, 2, {"a", "b"}}, {1, 2, {"a", "b"}}
  local u1, u2 = {s = "some string", i = 32}, {s = "some string", i = 32}

  result = utils.assert_eq(i1, i2) and result
  result = utils.assert_eq(s1, s2, "custom message") and result
  result = utils.assert_eq(f1, f2, "custom %s message", "formated") and result
  result = utils.assert_eq(t1, t2, "tables are different:") and result
  result = utils.assert_eq(u1, u2) and result

  return result
end

--- Checks eq comparison assertions.
--- @return boolean
function M.neq_assertion()
  local result = true
  local i1, i2 = 3, 2
  local s1, s2 = "abc", "def"
  local f1, s3 = 0.9, "0.9"
  local t1, t2 = {1, 2, {"b"}}, {1, 2, {"a"}}

  result = utils.assert_neq(i1, i2) and result
  result = utils.assert_neq(s1, s2, "custom message") and result
  result = utils.assert_neq(f1, s3, "different types!") and result
  result = utils.assert_neq(t1, t2, "tables are different:") and result

  return result
end


return M
