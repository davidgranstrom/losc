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

--------------
-- OSC Bundle.
--
-- An OSC Bundle consists of the OSC-string "#bundle" followed by an OSC Time
-- Tag, followed by zero or more OSC Bundle Elements.
--
-- @module losc.bundle
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2021

local relpath = (...):gsub('%.[^%.]+$', '')
local Types = require(relpath .. '.types')
local Message = require(relpath .. '.message')
local Timetag = require(relpath .. '.timetag')

local Bundle = {}
Bundle.__index = Bundle

local ts = Timetag.get_timestamp

--- Pack a Bundle recursively.
local function _pack(bundle, packet)
  packet[#packet + 1] = Types.pack.s('#bundle')
  packet[#packet + 1] = Types.pack.t(bundle.timetag)
  for _, item in ipairs(bundle) do
    if item.address and item.types then
      local message = Message.pack(item)
      packet[#packet + 1] = Types.pack.i(#message)
      packet[#packet + 1] = message
    elseif item.timetag then
      if ts(item.timetag) < ts(bundle.timetag) then
        error('Bundle timetag is less than enclosing bundle.')
      end
      local bndl = Bundle.pack(item)
      packet[#packet + 1] = Types.pack.i(#bndl)
      packet[#packet + 1] = bndl
    end
  end
  return table.concat(packet, '')
end

--- Unpack a Bundle recursively.
local function _unpack(data, bundle, offset, length)
  local value, _
  _, offset = Types.unpack.s(data, offset)
  value, offset = Types.unpack.t(data, offset)
  bundle.timetag = value
  length = length or #data
  while offset < length do
    -- content length
    value, offset = Types.unpack.i(data, offset)
    local head = data:sub(offset, offset)
    if head == '#' then
      value, offset = _unpack(data, {}, offset, offset + value - 1)
      bundle[#bundle + 1] = value
    elseif head == '/' then
      value, offset = Message.unpack(data, offset)
      bundle[#bundle + 1] = value
    end
  end
  return bundle, offset
end

--- High level API
-- @section high-level-api

--- Create a new OSC bundle.
--
-- Arguments can be one form of:
--
-- 1. nil (return empty bundle object).
-- 2. Timetag.
-- 3. Timetag, message/bundle objects.
--
-- @param[opt] ... arguments.
-- @return Bundle object.
function Bundle.new(...)
  local self = setmetatable({}, Bundle)
  local args = {...}
  self.content = {}
  if #args >= 1 then
    self.content.timetag = args[1].content
    for index = 2, #args do
      self:add(args[index])
    end
  end
  return self
end

--- Adds an item to the bundle.
-- @param item Can be a Message or another bundle.
function Bundle:add(item)
  self.content[#self.content + 1] = item.content
end

--- Get or set the bundle Timetag.
-- @param[opt] tt A Timetag object.
-- If no parameter is given it returns the current Timetag.
function Bundle:timetag(tt)
  if tt then
    self.content.timetag = tt.content
  else
    return Timetag.new_raw(self.content.timetag)
  end
end

--- Validate a bundle.
-- @tparam table|string bundle The bundle to validate. Can be in packed or unpacked form.
function Bundle.validate(bundle)
  assert(bundle)
  if type(bundle) == 'string' then
    Bundle.bytes_validate(bundle)
  elseif type(bundle) == 'table' then
    Bundle.tbl_validate(bundle.content or bundle)
  end
end

--- Low level API
-- @section low-level-api

--- Validate a table that can be used as an OSC bundle.
-- @param tbl The table to validate.
function Bundle.tbl_validate(tbl)
  assert(type(tbl.timetag) == 'table', 'Missing OSC Timetag.')
end

--- Validate a byte string that can be unpacked to an OSC bundle.
-- @param data The byte string to validate.
-- @param[opt] offset Byte offset.
function Bundle.bytes_validate(data, offset)
  local value
  assert(#data % 4 == 0, 'OSC bundle data must be a multiple of 4.')
  value, offset = Types.unpack.s(data, offset or 1)
  assert(value == '#bundle', 'Missing bundle marker')
  value = Types.unpack.t(data, offset)
  assert(type(value) == 'table', 'Missing bundle timetag')
end

--- Pack an OSC bundle.
--
-- The returned object is suitable for sending via a transport layer such as
-- UDP or TCP.
--
-- @param tbl The content to pack.
-- @return OSC data packet (byte string).
function Bundle.pack(tbl)
  local packet = {}
  return _pack(tbl, packet)
end

--- Unpack an OSC bundle byte string.
--
-- @param data The data to unpack.
-- @param offset The initial offset into data.
-- @return table with the content of the OSC bundle.
function Bundle.unpack(data, offset)
  local bundle = {}
  return _unpack(data, bundle, offset or 1)
end

return Bundle
