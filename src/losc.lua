--- High level API.
-- @module losc

local Message = require'losc.message'
local Bundle = require'losc.bundle'

local losc = {}

--- Create a new (empty) Message.
--
-- @param[opt] ... arguments.
-- @return Message object.
-- @see losc.message
-- @usage local message = losc.message_new()
-- @usage local message = losc.message_new('/address')
-- @usage local message = losc.message_new('/address', 123, 'hello', 1.234)
-- @usage local message = losc.message_new({ address = '/foo', types = 'iif', 1, 2, 3})
function losc.message_new(...)
  return Message.new(...)
end

--- Create a new OSC message from a table.
--
-- @param tbl The table to create the message from.
-- @return Message object.
-- @see losc.message
-- @usage local message = losc.message_new_from_tbl({address = '/foo', types = 'i', 123})
function losc.message_new_from_tbl(tbl)
  return Message.new_from_tbl(tbl)
end

--- Create a new Message from binary OSC data.
--
-- @param data Binary OSC data string.
-- @return Message object.
-- @see losc.message
-- @usage local message = losc.message_new_from_bytes(osc_data_str)
function losc.message_new_from_bytes(data)
  return Message.new_from_bytes(data)
end

--- Create a new OSC bundle.
--
-- @param[opt] ... arguments.
-- @return Bundle object.
-- @see losc.bundle
-- @usage local bundle = losc.bundle_new()
-- @usage local bundle = losc.bundle_new(tt)
-- @usage local bundle = losc.bundle_new(tt, osc_msg, osc_msg2)
-- @usage local bundle = losc.bundle_new(tt, osc_msg, other_bundle)
function losc.bundle_new(...)
  return Bundle.new(...)
end

return losc
