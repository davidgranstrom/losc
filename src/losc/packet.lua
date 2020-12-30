-------------------------
-- OSC packet.
--
-- @module losc.packet
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2020

local Message = require'losc.message'
local Bundle = require'losc.bundle'

local Packet = {}

function Packet.is_bundle(item)
  if type(item) == 'string' then
    return pcall(Bundle.bytes_validate, item)
  elseif type(item) == 'table' then
    return pcall(Bundle.tbl_validate, item)
  end
end

function Packet.pack(tbl)
  if Packet.is_bundle(tbl) then
    return Bundle.pack(tbl)
  else
    return Message.pack(tbl)
  end
end

function Packet.unpack(data, offset)
  if Packet.is_bundle(data) then
    return Bundle.unpack(data, offset)
  else
    return Message.unpack(data, offset)
  end
end

return Packet
