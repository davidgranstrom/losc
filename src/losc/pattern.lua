--------------------------------------
-- OSC pattern matcher and dispatcher.
--
-- @module losc.pattern
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2021

local Packet = require'losc.packet'
local Timetag = require'losc.timetag'

local Pattern = {}

local ts = Timetag.get_timestamp

--- Escape magic lua characters from a pattern.
-- @tparam string pattern The pattern to escape.
-- @return A string with all magic lua characters escaped and OSC wildcards
-- converted to lua pattern matching wildcards.
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

local function match(key, address)
  local result = address:match(key) == address
  -- try and match group instead
  if not result and key:find('{') then
    local index = 1
    local tmps = ''
    for c in key:gmatch('.') do
      local a = address:sub(index, index)
      if a == c then
        tmps = tmps .. c
        index = index + 1
      end
    end
    result = tmps == address
  end
  return result
end

local function invoke(message, timestamp, plugin)
  local address = message.address
  local now = plugin:now():timestamp(plugin.precision)
  if plugin.handlers then
    for _, handler in pairs(plugin.handlers) do
      if match(handler.pattern, address) then
        plugin:schedule(timestamp - now, function()
          handler.callback({
            timestamp = now,
            message = message,
            plugin = plugin,
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
-- @tparam string data Packed OSC data byte string.
-- @tparam table plugin The plugin to dispatch the message through.
function Pattern.dispatch(data, plugin)
  local packet = Packet.unpack(data)
  dispatch(packet, plugin)
end

return Pattern
