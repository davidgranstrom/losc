local inspect = require'inspect' -- debug only
local is_lua53 = _VERSION:find('3') ~= nil
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
  return _pack('>i4', value)
end

-- 32-bit big-endian IEEE 754 floating point number
-- @returns buffer
Types.pack.f = function(value)
  return _pack('>f', value)
end

-- string
-- @returns buffer
Types.pack.s = function(value)
  local len = strsize(value)
  local fmt = 'c' .. len
  value = value .. string.rep(string.char(0), len - #value)
  return _pack('>' .. fmt, value)
end

-- blob
-- @returns buffer
Types.pack.b = function(value)
  local size = #value
  local aligned = blobsize(value)
  local fmt = 'c' .. aligned
  value = value .. string.rep(string.char(0), aligned - size)
  return _pack('>I4' .. fmt, size, value)
end

-- Unpack an integer
-- @returns Value and byte offset
Types.unpack.i = function(data, offset)
  return _unpack('>i4', data, offset)
end

-- Unpack a float
-- @returns Value and byte offset
Types.unpack.f = function(data, offset)
  return _unpack('>f', data, offset)
end

-- Unpack a string
-- @returns Value and byte offset
Types.unpack.s = function(data, offset)
  local fmt = is_lua53 and 'z' or 's'
  local str = _unpack('>' .. fmt, data, offset)
  return str, strsize(str) + (offset or 1)
end

-- Unpack a blob
-- @returns value and byte offset
Types.unpack.b = function(data, offset)
  local size, blob
  size, offset = _unpack('>I4', data, offset)
  blob, offset = _unpack('>c' .. size, data, offset)
  return blob, offset + blobsize(blob) - size
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
