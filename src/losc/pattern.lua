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

--------------------------------------
-- OSC pattern matcher and dispatcher.
--
-- @module losc.pattern
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2021

local relpath = (...):gsub('%.[^%.]+$', '')
local Packet = require(relpath .. '.packet')
local Timetag = require(relpath .. '.timetag')

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
  local ignore_late = plugin.options.ignore_late or false
  if ignore_late and timestamp > 0 and timestamp < now then
    return
  end
  if plugin.handlers then
    for _, handler in pairs(plugin.handlers) do
      if match(handler.pattern, address) then
        plugin:schedule(timestamp - now, function()
          handler.callback({
            timestamp = now,
            message = message,
            remote_info = plugin.remote_info or {},
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
        if ts(item.timetag, plugin.precision) >= ts(packet.timetag, plugin.precision) then
          dispatch(item, plugin)
        else
          error('Bundle timestamp is older than timestamp of enclosing bundle')
        end
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
