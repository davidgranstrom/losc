-------------------------
-- OSC method dispatcher.
--
-- @module losc.pattern
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2021

local Packet = require'losc.packet'
local Timetag = require'losc.timetag'

local unpack = unpack or table.unpack

local Pattern = {}

local function get_timestamp(bundle)
  return Timetag.get_timestamp(bundle)
end

local function pattern_to_regex(address)
  local pattern = address
  pattern = pattern:gsub('%[!', '%[^')
  pattern = pattern:gsub('%*', '.*')
  return pattern
end

local function invoke(message, timestamp, plugin)
  local address = message.address
  local pattern = pattern_to_regex(address)
  local now = plugin:now():timestamp()
  if plugin.handlers then
    for key, handler in pairs(plugin.handlers) do
      local match = key:match(pattern)
      if match then
        plugin:schedule(timestamp - now, function()
          handler(unpack(message))
        end)
      end
    end
  end
end

local function dispatch(packet, plugin)
  if Packet.is_bundle(packet) then
    for _, item in ipairs(packet) do
      if Packet.is_bundle(item) then
        if get_timestamp(item.timetag) < get_timestamp(packet.timetag) then
          error('Bundle timestamp is older than timestamp of enclosing bundle')
        end
        return dispatch(item, plugin)
      else
        invoke(item, get_timestamp(packet.timetag), plugin)
      end
    end
  else
    invoke(packet, 0, plugin)
  end
end

--- Dispatch OSC packets.
-- @param data The packet to dispatch.
-- @param plugin A plugin.
function Pattern.dispatch(data, plugin)
  local packet = Packet.unpack(data)
  dispatch(packet, plugin)
end

return Pattern
