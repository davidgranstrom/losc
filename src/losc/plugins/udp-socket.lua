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

-------------------------------------------------
-- UDP client/server implemented using luasocket.
--
-- These methods should be called from the main `losc` API.
--
-- @module losc.plugins.udp-socket
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2021

local socket = require'socket'

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
  self.handle = socket.udp()
  self.client_handle = socket.udp()
  assert(self.handle, 'Could not create UDP handle.')
  assert(self.client_handle, 'Could not create UDP handle.')
  return self
end

--- Create a Timetag with the current time.
-- Precision is in milliseconds.
-- @return Timetag object with current time.
function M:now() -- luacheck: ignore
  local now = os.time()
  local millis = math.floor(((socket.gettime() - now) * 1000) + 0.5)
  return Timetag.new(now, millis)
end

--- Schedule a OSC method for dispatch.
--
-- *This plugin does not support scheduled bundles - timestamps will be ignored.*
-- @tparam number timestamp When to schedule the bundle.
-- @tparam function handler The OSC handler to call.
function M:schedule(timestamp, handler) -- luacheck: ignore
  handler()
end

--- Start UDP server.
-- This function is blocking.
-- @tparam string host IP address (e.g. 'localhost').
-- @tparam number port The port to listen on.
function M:open(host, port)
  host = host or self.options.recvAddr
  host = socket.dns.toip(host)
  port = port or self.options.recvPort
  self.handle:setsockname(host, port)
  while true do
    local data = self.handle:receive()
    if data then
      local ok, err = pcall(Pattern.dispatch, data, self)
      if not ok then
        print(err)
      end
    end
  end
end

--- Close UDP server.
function M:close()
  if self.handle then
    self.handle:close()
  end
  self.client_handle:close()
end

--- Send a OSC packet.
-- @tparam table packet The packet to send.
-- @tparam[opt] string address The IP address to send to.
-- @tparam[opt] number port The port to send to.
function M:send(packet, address, port)
  address = address or self.options.sendAddr
  address = socket.dns.toip(address)
  port = port or self.options.sendPort
  packet = assert(Packet.pack(packet))
  self.client_handle:sendto(packet, address, port)
end

return M
