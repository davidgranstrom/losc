------------------------
-- Serializer functions.
--
-- Lua >= 5.3 will use `string.pack`/`string.unpack`
--
-- Lua < 5.3 and luajit will use `struct` if available, otherwise `lua-struct` (which is bundled as fallback).
--
-- @module losc.serializer
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2021

local Serializer = {}

--- Require a function for packing.
-- @return A suitable packing function as explained in the header of this file.
function Serializer.pack()
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

--- Require a function for unpacking.
-- @return A suitable unpacking function as explained in the header of this file.
function Serializer.unpack()
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

return Serializer
