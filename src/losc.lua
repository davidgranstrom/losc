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
losc.handlers = {}

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

--- Create a new OSC bundle.
--
-- @param[opt] ... arguments.
-- @return Bundle object.
-- @see losc.bundle
-- @usage local bundle = losc.bundle_new()
-- @usage
-- local tt = Timetag.new()
-- local bundle = losc.bundle_new(tt)
-- @usage
-- local tt = Timetag.new_from_usec(os.time(), 0)
-- local bundle = losc.bundle_new(tt, osc_msg, osc_msg2)
-- @usage
-- local tt = Timetag.new_from_usec(os.time(), 0)
-- local bundle = losc.bundle_new(tt, osc_msg, other_bundle)
function losc.bundle_new(...)
  return Bundle.new(...)
end

--- Specify a plugin.
-- @param plugin The plugin to use.
function losc:use(plugin)
  self.plugin = plugin
  self.plugin.handlers = self.handlers
end

--- Get a OSC timetag with the current timestamp.
-- Will fall back to os.time() if now() is not implemented by a plugin.
function losc:now()
  if self.plugin.now then
    return self.plugin:now()
  end
  return Timetag.new_from_usec(os.time(), 0)
end

--- Opens an OSC server.
function losc:open(...)
  if not self.plugin then
    error('"open" must be implemented by a plugin.')
  end
  self.plugin:open(...)
end

--- Closes an OSC server.
function losc:close(...)
  if not self.plugin then
    error('"close" must be implemented by a plugin.')
  end
  self.plugin:close(...)
end

--- Send an OSC packet.
function losc:send(...)
  if not self.plugin then
    error('"send" must be implemented by a plugin.')
  end
  self.plugin:send(...)
end

--- Add an OSC method.
function losc:add_handler(pattern, cb)
  self.handlers[pattern] = cb
end

--- Remove an OSC method.
function losc:remove_handler(pattern)
  self.handlers[pattern] = nil
end

return losc
