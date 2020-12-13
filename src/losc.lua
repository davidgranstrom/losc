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
-- @usage local message = losc.message_new('/address', 'i', 123)
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

function losc.bundle_new(timetag, ...)
end

return losc
