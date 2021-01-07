-------------------------
-- OSC method dispatcher.
--
-- @module losc.pattern
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2021

local inspect = require'inspect'
local Packet = require'losc.packet'
local Timetag = require'losc.timetag'

local Pattern = {}

local ts = Timetag.get_timestamp

function Pattern.escape(pattern)
  -- escape lua magic chars (order matters)
  pattern = pattern:gsub('%%', '%%%%')
  pattern = pattern:gsub('%.', '%%.')
  pattern = pattern:gsub('%(', '%%(')
  pattern = pattern:gsub('%)', '%%)')
  pattern = pattern:gsub('%+', '%%+')
  pattern = pattern:gsub('%$', '%%$')
  -- convert osc wildcards to lua patterns
  pattern = pattern:gsub('%*', '.*')
  pattern = pattern:gsub('%?', '.')
  pattern = pattern:gsub('%[!', '[^')
  pattern = pattern:gsub('%]', ']+')
  return pattern
end

local function invoke(message, timestamp, plugin)
  local address = message.address
  local now = plugin:now()
  if plugin.handlers then
    for _, handler in pairs(plugin.handlers) do
      local match = address:match(handler.pattern) == address
      if match then
        plugin.schedule(timestamp - now:timestamp(plugin.precision), function()
          handler.callback({
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
        if ts(item.timetag, plugin.precision) < ts(packet.timetag, plugin.precision) then
          error('Bundle timestamp is older than timestamp of enclosing bundle')
        end
        return dispatch(item, plugin)
      else
        invoke(item, ts(packet.timetag, plugin.precision), plugin)
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
