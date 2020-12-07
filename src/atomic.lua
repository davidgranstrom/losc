local inspect = require'inspect' -- debug only
local _pack = string.pack or require'struct'.pack
local _unpack = string.unpack or require'struct'.unpack

local Atomic = {}

--- @brief Pack an OSC type
Atomic.pack = {}

--- @brief Unpack an OSC type
Atomic.unpack = {}

local function strsize(s)
  return 4 * (math.floor(#s / 4) + 1)
end

local function blobsize(b)
  return 4 * (math.floor((#b + 3) / 4))
end

-- 32-bit big-endian two's complement integer
-- @returns buffer
Atomic.pack.i = function(value)
  return _pack('>!4i4', value)
end

-- 32-bit big-endian IEEE 754 floating point number
-- @returns buffer
Atomic.pack.f = function(value)
  return _pack('>!4f', value)
end

-- string
-- @returns buffer
Atomic.pack.s = function(value)
  local len = strsize(value)
  local fmt = 'c' .. len
  value = value .. string.rep(string.char(0), len - #value)
  return _pack('>!4' .. fmt, value)
end

-- blob
-- @returns buffer
Atomic.pack.b = function(value)
  local len = blobsize(value)
  local fmt = 'c' .. len
  value = value .. string.rep(string.char(0), len)
  return _pack('>!4I4' .. fmt, len, value)
end

-- Unpack an integer
-- @returns Value and byte offset
Atomic.unpack.i = function(data, offset)
  return _unpack('>!4i4', data, offset)
end

-- Unpack a float
-- @returns Value and byte offset
Atomic.unpack.f = function(data, offset)
  return _unpack('>!4f', data, offset)
end

-- Unpack a string
-- @returns Value and byte offset
Atomic.unpack.s = function(data, offset)
  local str = _unpack('>!4s', data, offset)
  return str, offset + strsize(str)
end

-- Unpack a blob
-- @returns Size of blob, value and byte offset
Atomic.unpack.b = function(data, offset)
  local fmt = 'c' .. #data - 4
  return _unpack('>!4I4' .. fmt, data, offset)
end

-- Extended types

Atomic.unpack.T = function(_, _)
  return true, 0
end

Atomic.unpack.F = function(_, _)
  return false, 0
end

Atomic.unpack.N = function(_, _)
  return nil, 0
end

Atomic.unpack.I = function(_, _)
  return #INF, 0
end

return Atomic
