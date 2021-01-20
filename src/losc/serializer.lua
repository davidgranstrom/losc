--[[
MIT License

Copyright (c) 2021 David Granström

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

------------------------
-- Serializer functions.
--
-- Lua >= 5.3 will use `string.pack`/`string.unpack`
--
-- Lua < 5.3 and luajit will use `struct` if available, otherwise `lua-struct` (which is bundled as a fallback).
--
-- @module losc.serializer
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2021

local relpath = (...):gsub('%.[^%.]+$', '')
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
    return require(relpath .. '.lib.struct').pack
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
    return require(relpath .. '.lib.struct').unpack
  end
end

return Serializer
