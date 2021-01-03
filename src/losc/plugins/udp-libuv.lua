--------------------------------------------
-- UDP client/server implemented with libuv.
--
-- @module losc.plugins.udp-libuv
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2021

local uv = require'luv'
local Timetag = require'losc.timetag'

local unpack = unpack or table.unpack
local errors = {
  not_running = 'UDP server not running.'
}

local M = {}
M.__index = M

function M:now()
  local tv = uv.gettimeofday()
  return Timetag.new_from_usec(unpack(tv))
end

function M:start(host, port)
  host = host or "127.0.0.1"
  port = port or 0
  self.handle = uv.new_udp('inet')
  assert(self.handle, 'Could not create UDP handle')
  self.handle:bind(host, port, {reuseaddr=true})
  self.handle:recv_start(function(err, data)
    assert(not err, err)
    if data then
      print(data)
      -- TODO: dispatch
    end
  end)
  self.port = self.handle:getsockname().port
  uv.run()
end

function M:stop()
  assert(self.handle, errors.not_running)
  self.handle:recv_stop()
  if not self.handle:is_closing() then
    self.handle:close()
  end
  uv.walk(uv.close)
end

function M:send(packet, options)
  assert(self.handle, errors.not_running)
  assert(packet, 'OSC packet is nil.')
  local data = packet:pack()
  local addr = options.address
  local port = options.port
  self.handle:udp_try_send(data, addr, port)
end

return M
