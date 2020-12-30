-------------------------
-- OSC method dispatcher.
--
-- @module losc.pattern
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2020

local Packet = require'losc.packet'

local Pattern = {}

function Pattern.dispatch(data)
  local packet = Packet.unpack(data)
  if Packet.is_bundle(packet) then
  else
    local addr = packet.content.address
  end
end

return Pattern
