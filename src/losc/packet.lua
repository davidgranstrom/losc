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

-------------------------
-- OSC packet.
--
-- The unit of transmission of OSC is an OSC Packet.
-- An OSC packet is either a messages or a bundle.
--
-- @module losc.packet
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2021

local relpath = (...):gsub('%.[^%.]+$', '')
local Message = require(relpath .. '.message')
local Bundle = require(relpath .. '.bundle')
local Types = require(relpath .. '.types')

local Packet = {}

--- Check if a packet is a bundle or a message.
-- @tparam string|table packet The packet to check.
-- @return True if packet is a bundle otherwise false.
function Packet.is_bundle(packet)
  if type(packet) == 'string' then
    local value = Types.unpack.s(packet)
    return value == '#bundle'
  elseif type(packet) == 'table' then
    packet = packet.content or packet
    return type(packet.timetag) == 'table'
  end
end

--- Validate a packet. Can be a message or a bundle.
-- @tparam string|table packet The packet to validate.
function Packet.validate(packet)
  if Packet.is_bundle(packet) then
    Bundle.validate(packet)
  else
    Message.validate(packet)
  end
end

--- Pack a Bundle or Message.
-- @param tbl The table to pack.
-- @return OSC data packet (byte string).
function Packet.pack(tbl)
  if Packet.is_bundle(tbl) then
    Bundle.validate(tbl)
    return Bundle.pack(tbl.content or tbl)
  else
    Message.validate(tbl)
    return Message.pack(tbl.content or tbl)
  end
end

--- Unpack an OSC packet.
-- @tparam string data The data to unpack.
-- @return table with the content of the OSC message (bundle or message).
function Packet.unpack(data)
  if Packet.is_bundle(data) then
    Bundle.validate(data)
    return Bundle.unpack(data)
  else
    Message.validate(data)
    return Message.unpack(data)
  end
end

return Packet
