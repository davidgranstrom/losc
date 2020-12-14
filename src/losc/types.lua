--- Types
-- @module losc.types

-- Require a function for packing.
-- Try different fallbacks if string.pack is unavailable.
local function require_pack()
  if string.pack then
    return string.pack
  end
  local ok, _ = pcall(require, 'struct')
  if ok then
    return require'struct'.pack
  else
    return require'lib.struct'.pack
  end
end

-- Require a function for unpacking.
-- Try different fallbacks if string.unpack is unavailable.
local function require_unpack()
  if string.unpack then
    return string.unpack
  end
  local ok, _ = pcall(require, 'struct')
  if ok then
    return require'struct'.unpack
  else
    return require'lib.struct'.unpack
  end
end

local _pack = require_pack()
local _unpack = require_unpack()
local has_string_pack = string.pack and true or false

local Types = {}

--- Type pack functions.
--
-- Custom pack functions can be added to this table and standard functions can
-- be re-assigned if necessary.
--
-- This table can be called to pack a value in protected mode (pcall).
-- @usage local ok, data = Types.pack('s', 'hello')
-- if ok then
--   -- do something with data.
-- end
Types.pack = {}
setmetatable(Types.pack, {
  __call = function(self, type, value)
    return pcall(self[type], value)
  end
})

--- Type unpack functions.
--
-- Custom unpack functions can be added to this table and standard functions
-- can be re-assigned if necessary.
--
-- This table can be called to unpack a value in protected mode (pcall).
-- @usage local ok, value, index = Types.unpack('s', data, 1)
-- if ok then
--   -- do something with value/index.
-- end
Types.unpack = {}
setmetatable(Types.unpack, {
  __call = function(self, type, data, offset)
    return pcall(self[type], data, offset)
  end
})

--- Types that only exists as type tag data (should not be packed).
-- Custom types can be appended to this string.
-- Default value: `TFNI`
Types.pack.skip_types = 'TFNI'

local function strsize(s)
  return 4 * (math.floor(#s / 4) + 1)
end

local function blobsize(b)
  return 4 * (math.floor((#b + 3) / 4))
end

--- Atomic types.
-- @section atomic-types

--- 32-bit big-endian two's complement integer.
-- @param value The value to pack.
-- @return Binary string buffer.
Types.pack.i = function(value)
  return _pack('>i4', value)
end

--- 32-bit big-endian two's complement integer.
-- @param data The data to unpack.
-- @param[opt] offset Initial offset into data.
-- @return value, index of the bytes read + 1.
Types.unpack.i = function(data, offset)
  return _unpack('>i4', data, offset)
end

--- 32-bit big-endian IEEE 754 floating point number.
-- @param value The value to pack.
-- @return Binary string buffer.
Types.pack.f = function(value)
  return _pack('>f', value)
end

--- 32-bit big-endian IEEE 754 floating point number.
-- @param data The data to unpack.
-- @param[opt] offset Initial offset into data.
-- @return value, index of the bytes read + 1.
Types.unpack.f = function(data, offset)
  return _unpack('>f', data, offset)
end

--- String (null terminated)
-- @param value The value to pack.
-- @return Binary string buffer.
Types.pack.s = function(value)
  local len = strsize(value)
  local fmt = 'c' .. len
  value = value .. string.rep(string.char(0), len - #value)
  return _pack('>' .. fmt, value)
end

--- String (null terminated)
-- @param data The data to unpack.
-- @param[opt] offset Initial offset into data.
-- @return value, index of the bytes read + 1.
Types.unpack.s = function(data, offset)
  local fmt = has_string_pack and 'z' or 's'
  local str = _unpack('>' .. fmt, data, offset)
  return str, strsize(str) + (offset or 1)
end

--- Blob (arbitrary binary data)
-- @param value The value to pack.
-- @return Binary string buffer.
Types.pack.b = function(value)
  local size = #value
  local aligned = blobsize(value)
  local fmt = 'c' .. aligned
  value = value .. string.rep(string.char(0), aligned - size)
  return _pack('>I4' .. fmt, size, value)
end

--- Blob (arbitrary binary data)
-- @param data The data to unpack.
-- @param[opt] offset Initial offset into data.
-- @return value, index of the bytes read + 1.
Types.unpack.b = function(data, offset)
  local size, blob
  size, offset = _unpack('>I4', data, offset)
  blob, offset = _unpack('>c' .. size, data, offset)
  return blob, offset + blobsize(blob) - size
end

--- Extended types.
-- @section extended-types

--- 64 bit big-endian two's complement integer
-- @param value The value to pack.
-- @return Binary string buffer.
Types.pack.h = function(value)
  local fmt = has_string_pack and '>i8' or '>l'
  return _pack(fmt, value)
end

--- 64 bit big-endian two's complement integer
-- @param data The data to unpack.
-- @param[opt] offset Initial offset into data.
-- @return value, index of the bytes read + 1.
Types.unpack.h = function(data, offset)
  local fmt = has_string_pack and '>i8' or '>l'
  return _unpack(fmt, data, offset)
end

--- Timetag (64-bit integer)
-- @param value The value to pack.
-- @return Binary string buffer.
Types.pack.t = function(value)
  local fmt = has_string_pack and '>I8' or '>L'
  return _pack(fmt, value)
end

--- Timetag (64-bit integer)
-- @param data The data to unpack.
-- @param[opt] offset Initial offset into data.
-- @return value, index of the bytes read + 1.
Types.unpack.t = function(data, offset)
  local fmt = has_string_pack and '>I8' or '>L'
  return _unpack(fmt, data, offset)
end

--- Boolean true.
-- This type does not have a corresponding `pack` method.
-- @param _ Not used.
-- @param[opt] offset Initial offset into data.
-- @return true (boolean) and byte offset (not incremented).
Types.unpack.T = function(_, offset)
  return true, offset or 0
end

--- Boolean false.
-- This type does not have a corresponding `pack` method.
-- @param _ Not used.
-- @param[opt] offset Initial offset into data.
-- @return false (boolean) and byte offset (not incremented).
Types.unpack.F = function(_, offset)
  return false, offset or 0
end

--- Nil.
-- This type does not have a corresponding `pack` method.
-- @param _ Not used.
-- @param[opt] offset Initial offset into data.
-- @return false (since nil cannot be represented in a lua table) and byte offset (not incremented).
Types.unpack.N = function(_, offset)
  -- TODO: decide on what to return here..
  return false, offset or 0
end

--- Infinitum.
-- This type does not have a corresponding `pack` method.
-- @param _ Not used.
-- @param[opt] offset Initial offset into data.
-- @return math.huge and byte offset (not incremented).
Types.unpack.I = function(_, offset)
  return math.huge, offset or 0
end

return Types
