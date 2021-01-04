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

local errors = {
  not_running = 'UDP server not running.'
}

local M = {}
M.__index = M
--- Precision for bundle scheduling.
M.precision = 1000

function M.now()
  local s, m = uv.gettimeofday()
  return Timetag.new(s, m / M.precision)
end

function M.schedule(timestamp, handler)
  local timer = uv.new_timer()
  timestamp = math.max(0, timestamp)
  timer:start(timestamp, 0, function()
    handler()
  end)
end

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

function M:close()
  assert(self.handle, errors.not_running)
  self.handle:recv_stop()
  if not self.handle:is_closing() then
    self.handle:close()
  end
  uv.walk(uv.close)
end

function M:send(packet, addr, port)
  assert(self.handle, errors.not_running)
  assert(packet, 'OSC packet is nil.')
  if self.options and not addr then
    addr = self.options.sendAddr
  end
  if self.options and not port then
    port = self.options.sendPort
  end
  self.handle:udp_try_send(packet:pack(), addr, port)
end

return M
