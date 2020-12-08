local inspect = require'inspect' -- debug only
local _pack = string.pack or require'struct'.pack
local _unpack = string.unpack or require'struct'.unpack

local Types = {}

--- @brief Pack an OSC type
Types.pack = {}

--- @brief Unpack an OSC type
Types.unpack = {}

local function strsize(s)
  return 4 * (math.floor(#s / 4) + 1)
end

local function blobsize(b)
  return 4 * (math.floor((#b + 3) / 4))
end

-- 32-bit big-endian two's complement integer
-- @returns buffer
Types.pack.i = function(value)
  return _pack('>!4i4', value)
end

-- 32-bit big-endian IEEE 754 floating point number
-- @returns buffer
Types.pack.f = function(value)
  return _pack('>!4f', value)
end

-- string
-- @returns buffer
Types.pack.s = function(value)
  local len = strsize(value)
  local fmt = 'c' .. len
  value = value .. string.rep(string.char(0), len - #value)
  return _pack('>!4' .. fmt, value)
end

-- blob
-- @returns buffer
Types.pack.b = function(value)
  local len = blobsize(value)
  local fmt = 'c' .. len
  value = value .. string.rep(string.char(0), len - #value)
  return _pack('>!4I4' .. fmt, len, value)
end

-- Unpack an integer
-- @returns Value and byte offset
Types.unpack.i = function(data, offset)
  return _unpack('>!4i4', data, offset)
end

-- Unpack a float
-- @returns Value and byte offset
Types.unpack.f = function(data, offset)
  return _unpack('>!4f', data, offset)
end

-- Unpack a string
-- @returns Value and byte offset
Types.unpack.s = function(data, offset)
  local str = _unpack('>!4s', data, offset)
  return str, strsize(str) + (offset or 1)
end

-- Unpack a blob
-- @returns Size of blob, value and byte offset
Types.unpack.b = function(data, offset)
  local fmt = 'c' .. #data - 4
  return _unpack('>!4I4' .. fmt, data, offset)
end

-- Extended types

Types.unpack.T = function(_, offset)
  return true, offset
end

Types.unpack.F = function(_, offset)
  return false, offset
end

Types.unpack.N = function(_, offset)
  -- TODO: decide on what to return here..
  return false, offset
end

Types.unpack.I = function(_, offset)
  return math.huge, offset
end

return Types
