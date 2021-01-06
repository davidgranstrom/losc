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
--- Precision for bundle scheduling.
M.precision = 1000
M.client_handle = assert(socket.udp())

function M.now()
  local now = os.time()
  local millis = math.floor(((socket.gettime() - now) * 1000) + 0.5)
  return Timetag.new(now, millis)
end

function M.schedule(timestamp, handler)
  timestamp = math.max(0, timestamp) -- luacheck: ignore
  handler()
  -- local co = coroutine.create(function()
  --   socket.sleep(timestamp)
  --   coroutine.yield(handler())
  -- end)
  -- co.resume()
end

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

function M:close()
  if self.handle then
    self.handle:close()
  end
  self.client_handle:close()
end

function M:send(packet, addr, port)
  assert(packet, 'OSC packet is nil.')
  if self.options and not addr then
    addr = self.options.sendAddr
  end
  if self.options and not port then
    port = self.options.sendPort
  end
  if addr == 'localhost' then
    addr = socket.dns.toip(addr)
  end
  packet = assert(Packet.pack(packet))
  self.client_handle:sendto(packet, addr, port)
end

return M
