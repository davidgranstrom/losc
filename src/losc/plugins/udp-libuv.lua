--------------------------------------------
-- UDP client/server implemented with libuv.
--
-- @module losc.plugins.udp-libuv
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2021

local uv = require'luv'

local Timetag = require'losc.timetag'
local Pattern = require'losc.pattern'
local Packet = require'losc.packet'

local M = {}
M.__index = M
--- Fractional precision for bundle scheduling.
-- 1000 is milliseconds. 1000000 is microsends etc. Any precision is valid
-- that makes sense for the plugin's scheduling function.
M.precision = 1000

--- Create a Timetag with the current time.
-- Precision is in milliseconds.
-- @return Timetag object with current time.
function M:now() -- luacheck: ignore
  local s, m = uv.gettimeofday()
  return Timetag.new(s, m / M.precision)
end

--- Schedule a method for dispatch.
-- This function is used to dispatch  messages contained inside OSC bundles.
-- @tparam number timestamp When to schedule the bundle.
-- @tparam function handler The OSC handler to call.
function M:schedule(timestamp, handler) -- luacheck: ignore
  local timer = uv.new_timer()
  timestamp = math.max(0, timestamp)
  timer:start(timestamp, 0, function()
    handler()
  end)
end

--- Start UDP server.
-- This function is blocking.
-- @tparam string host IP address (e.g. 'localhost').
-- @tparam number port The port to listen on.
function M:open(host, port)
  if self.options and not host then
    host = self.options.recvAddr
  end
  if self.options and not port then
    port = self.options.recvPort
  end
  self.handle = uv.new_udp('inet')
  assert(self.handle, 'Could not create UDP handle')
  self.handle:bind(host, port, {reuseaddr=true})
  self.handle:recv_start(function(err, data)
    assert(not err, err)
    if data then
      Pattern.dispatch(data, self)
    end
  end)
  self.port = self.handle:getsockname().port
  uv.run()
end

--- Close UDP server.
function M:close()
  assert(self.handle, 'Server not running.')
  self.handle:recv_stop()
  if not self.handle:is_closing() then
    self.handle:close()
  end
  uv.walk(uv.close)
end

--- Send a OSC packet.
-- @tparam table packet The packet to send.
-- @tparam string address The IP address to send to.
-- @tparam number port The port to send to.
function M:send(packet, address, port)
  assert(self.handle, 'Server not running.')
  assert(packet, 'OSC packet is nil.')
  if self.options and not address then
    address = self.options.sendAddr
  end
  if self.options and not port then
    port = self.options.sendPort
  end
  packet = assert(Packet.pack(packet))
  self.handle:udp_try_send(packet, address, port)
end

return M
