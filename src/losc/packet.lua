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

local Packet = {}

--- Check if a packet is a bundle or a message.
-- @tparam string|table item The packet to check.
-- @return True if packet is a bundle otherwise false.
function Packet.is_bundle(item)
  return pcall(Bundle.validate, item)
end

--- Pack a bundle or message to a byte string.
-- @param tbl The table to pack.
-- @return OSC data packet (byte string).
function Packet.pack(tbl)
  if Packet.is_bundle(tbl) then
    return Bundle.pack(tbl.content or tbl)
  else
    return Message.pack(tbl.content or tbl)
  end
end

--- Unpack an OSC packet.
-- @param data The data to unpack.
-- @param offset The initial offset into data.
-- @return table with the content of the OSC message (bundle or message).
function Packet.unpack(data, offset)
  if Packet.is_bundle(data) then
    return Bundle.unpack(data, offset)
  else
    return Message.unpack(data, offset)
  end
end

return Packet
