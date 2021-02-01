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

--------------------------------------------
-- UDP client/server implemented with libuv.
--
-- These methods should be called from the main `losc` API.
--
-- @module losc.plugins.udp-libuv
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2021

local uv = require'luv'

local relpath = (...):gsub('%.[^%.]+$', '')
relpath = relpath:gsub('%.[^%.]+$', '')
local Timetag = require(relpath .. '.timetag')
local Pattern = require(relpath .. '.pattern')
local Packet = require(relpath .. '.packet')

local M = {}
M.__index = M
--- Fractional precision for bundle scheduling.
-- 1000 is milliseconds. 1000000 is microseconds etc. Any precision is valid
-- that makes sense for the plugin's scheduling function.
M.precision = 1000

--- Create a new instance.
-- @tparam[options] table options Options.
-- @usage local udp = plugin.new()
-- @usage
-- local udp = plugin.new {
--   sendAddr = '127.0.0.1',
--   sendPort = 9000,
--   recvAddr = '127.0.0.1',
--   recvPort = 8000,
--   ignore_late = true, -- ignore late bundles
-- }
function M.new(options)
  local self = setmetatable({}, M)
  self.options = options or {}
  self.handle = uv.new_udp('inet')
  assert(self.handle, 'Could not create UDP handle.')
  return self
end

--- Create a Timetag with the current time.
-- Precision is in milliseconds.
-- @return Timetag object with current time.
function M:now() -- luacheck: ignore
  local s, m = uv.gettimeofday()
  return Timetag.new(s, m / M.precision)
end

--- Schedule a OSC method for dispatch.
--
-- @tparam number timestamp When to schedule the bundle.
-- @tparam function handler The OSC handler to call.
function M:schedule(timestamp, handler) -- luacheck: ignore
  timestamp = math.max(0, timestamp)
  if timestamp > 0 then
    local timer = uv.new_timer()
    timer:start(timestamp, 0, handler)
  else
    handler()
  end
end

--- Start UDP server.
-- This function is blocking.
-- @tparam string host IP address (e.g. '127.0.0.1').
-- @tparam number port The port to listen on.
function M:open(host, port)
  host = host or self.options.recvAddr
  port = port or self.options.recvPort
  self.handle:bind(host, port, {reuseaddr=true})
  self.handle:recv_start(function(err, data, addr)
    assert(not err, err)
    if data then
      self.remote_info = addr
      local ok, errormsg = pcall(Pattern.dispatch, data, self)
      if not ok then
        print(errormsg)
      end
    end
  end)
  -- updated if port 0 is passed in as default (chooses a random port)
  self.options.recvPort = self.handle:getsockname().port
  uv.run()
end

--- Close UDP server.
function M:close()
  self.handle:recv_stop()
  if not self.handle:is_closing() then
    self.handle:close()
  end
  uv.walk(uv.close)
end

--- Send a OSC packet.
-- @tparam table packet The packet to send.
-- @tparam[opt] string address The IP address to send to.
-- @tparam[opt] number port The port to send to.
function M:send(packet, address, port)
  address = address or self.options.sendAddr
  port = port or self.options.sendPort
  packet = assert(Packet.pack(packet))
  self.handle:try_send(packet, address, port)
end

return M
