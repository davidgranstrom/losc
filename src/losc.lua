--- High level API.
-- @module losc

local Message = require'losc.message'
local Bundle = require'losc.bundle'

local losc = {}

--- Create a new (empty) Message.
--
-- @param[opt] ... arguments.
-- @return message object.
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
-- @return An OSC message object.
-- @see losc.message
function losc.message_new_from_tbl(tbl)
  return Message.new_from_tbl(tbl)
end

--- Create a new Message from binary OSC data.
--
-- @param data Binary OSC data string.
-- @return message object.
-- @see losc.message
function losc.message_new_from_bytes(data)
  return Message.new_from_bytes(data)
end

function losc.bundle_new(timetag, ...)
end

function losc.client_new(...)
end

function losc.server_new(...)
end

return losc
