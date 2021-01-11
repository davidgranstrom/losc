-------------------------
-- OSC packet.
--
-- The unit of transmission of OSC is an OSC Packet.
-- An OSC packet is either a messages or a bundle.
--
-- @module losc.packet
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2020

local Message = require'losc.message'
local Bundle = require'losc.bundle'
local Types = require'losc.types'

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

--- Pack a bundle or message to a byte string.
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
-- @param data The data to unpack.
-- @param offset The initial offset into data.
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
