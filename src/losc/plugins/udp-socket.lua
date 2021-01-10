-------------------------------------------------
-- UDP client/server implemented using luasocket.
--
-- @module losc.plugins.udp-socket
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2021

local socket = require'socket'

local Timetag = require'losc.timetag'
local Pattern = require'losc.pattern'
local Packet = require'losc.packet'

local M = {}
M.__index = M
--- Fractional precision for bundle scheduling.
-- 1000 is milliseconds. 1000000 is microsends etc. Any precision is valid
-- that makes sense for the plugin's scheduling function.
M.precision = 1000
M.client_handle = assert(socket.udp())

--- Create a Timetag with the current time.
-- Precision is in milliseconds.
-- @return Timetag object with current time.
function M:now() -- luacheck: ignore
  local now = os.time()
  local millis = math.floor(((socket.gettime() - now) * 1000) + 0.5)
  return Timetag.new(now, millis)
end

--- Schedule a method for dispatch.
-- This function is used to dispatch  messages contained inside OSC bundles.
-- @tparam number timestamp When to schedule the bundle.
-- @tparam function handler The OSC handler to call.
function M.schedule(timestamp, handler)
  timestamp = math.max(0, timestamp) -- luacheck: ignore
  handler()
  -- local co = coroutine.create(function()
  --   socket.sleep(timestamp)
  --   coroutine.yield(handler())
  -- end)
  -- co.resume()
end

--- Start UDP server.
-- This function is blocking.
-- @tparam string host IP address (e.g. 'localhost').
-- @tparam number port The port to listen on. 
function M:open(host, port)
  if self.options and not host then
    host = self.options.recvAddr
    if type(host) == 'string' then
      host = socket.dns.toip(host)
    end
  end
  if self.options and not port then
    port = self.options.recvPort
  end
  self.handle = assert(socket.udp(), 'Could not create UDP handle')
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
-- @tparam string address The IP address to send to.
-- @tparam number port The port to send to.
function M:send(packet, address, port)
  assert(packet, 'OSC packet is nil.')
  if self.options and not address then
    address = self.options.sendAddr
  end
  if self.options and not port then
    port = self.options.sendPort
  end
  if address == 'localhost' then
    address = socket.dns.toip(address)
  end
  packet = assert(Packet.pack(packet))
  self.client_handle:sendto(packet, address, port)
end

return M
