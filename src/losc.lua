------------------
-- API.
--
-- In most cases this will be the only module required to use losc.
--
-- @module losc
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2020

local Message = require'losc.message'
local Bundle = require'losc.bundle'
local Timetag = require'losc.timetag'

local losc = {}
losc.__index = losc

--- Create a new Message.
--
-- @param[opt] ... arguments.
-- @return Message object.
-- @see losc.message
-- @usage local message = losc.message_new()
-- @usage local message = losc.message_new('/address')
-- @usage local message = losc.message_new({ address = '/foo', types = 'iif', 1, 2, 3})
function losc.message_new(...)
  return Message.new(...)
end

--- Create a new Message from binary OSC data.
--
-- @param data Binary OSC data string.
-- @return Message object.
-- @see losc.message
-- @usage local message = losc.message_new_from_bytes(data)
function losc.message_new_from_bytes(data)
  return Message.new_from_bytes(data)
end

--- Create a new OSC bundle.
--
-- @param[opt] ... arguments.
-- @return Bundle object.
-- @see losc.bundle
-- @usage local bundle = losc.bundle_new()
-- @usage local bundle = losc.bundle_new(0)
-- @usage local bundle = losc.bundle_new(0.25, osc_msg, osc_msg2)
-- @usage local bundle = losc.bundle_new(0.25, osc_msg, other_bundle)
function losc.bundle_new(...)
  return Bundle.new(...)
end

--- Specify server/client plugin to use
-- @param plug Table with server and client entries.
function losc:use(plug)
  if not self.plugin then
    self.plugin = {}
  end
  if plug.now then
    self.plugin.now = plug.now
  end
  if plug.client then
    self.plugin.client = plug.client
  end
  if plug.server then
    self.plugin.server = plug.server
  end
end

--- Get a OSC timetag with the current timestamp.
-- Will fall back to os.time() if not implemented by a plugin.
function losc:now()
  if self.plugin.now then
    return self.plugin:now()
  end
  local now = os.time()
  return Timetag.new_from_usec(now)
end

function losc:start(...)
  if not self.plugin then
    error('"start" must be implemented by a plugin.')
  end
  self.plugin.server:start(...)
end

function losc:stop(...)
  if not self.plugin then
    error('"stop" must be implemented by a plugin.')
  end
  self.plugin.server:stop(...)
end

function losc:send(...)
  if not self.plugin then
    error('"send" must be implemented by a plugin.')
  end
  self.plugin.client:send(...)
end

function losc:listen(addr, cb)

end

return losc
