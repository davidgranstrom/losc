--- High level API.
-- @module losc

local Message = require'losc.message'
local Bundle = require'losc.bundle'

local losc = {}

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

return losc
