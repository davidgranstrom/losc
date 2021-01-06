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

local function address_to_regex(address)
  local pattern = address
  pattern = pattern:gsub('%[!', '%[^')
  pattern = pattern:gsub('%*', '.*')
  pattern = pattern:gsub('%.', '%%.')
  pattern = pattern:gsub('%?', '.')
  return pattern
end

local function invoke(message, timestamp, plugin)
  local address = message.address
  local pattern = address_to_regex(address)
  local now = plugin:now()
  if plugin.handlers then
    for key, handler in pairs(plugin.handlers) do
      local match = key:match(pattern) == key
      if match or key == '/*' then
        plugin.schedule(timestamp - now:timestamp(plugin.precision), function()
          handler({
            timestamp = now,
            plugin = plugin,
            message = message,
          })
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
        invoke(item, get_timestamp(packet.timetag, plugin.precision), plugin)
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
