--- Bundle
-- @module losc.bundle

local Types = require'losc.types'
local Message = require'losc.message'

local Bundle = {}

local function _pack(bndl, packet)
  packet[#packet + 1] = Types.pack.s('#bundle')
  packet[#packet + 1] = Types.pack.t(bndl.timetag)
  for _, item in ipairs(bndl) do
    if item.timetag then
      if item.timetag >= bndl.timetag then
        return _pack(item, packet)
      end
      error('nested bundle requires timetag greater than enclosing bundle.')
    end
    local message = Message.pack(item)
    packet[#packet + 1] = Types.pack.i(#message)
    packet[#packet + 1] = message
  end
  packet = table.concat(packet, '')
  return packet
end

local function _unpack(data, bundle, offset, ret_bundle)
  local value, index
  -- marker
  value, index = Types.unpack.s(data, offset)
  assert(value == '#bundle', 'missing marker')
  -- timetag
  value, index = Types.unpack.t(data, index)
  assert(value, 'missing timetag')
  bundle.timetag = value
  -- contents
  while index < #data do
    -- check if value is a nested bundle
    local nested = data:sub(index, index + 7) == '#bundle\0'
    if nested then
      local bndl = {}
      bundle[#bundle + 1] = bndl
      return _unpack(data, bndl, index, ret_bundle or bundle)
    end
    index = select(2, Types.unpack.i(data, index))
    value, index = Message.unpack(data, index)
    bundle[#bundle + 1] = value
  end
  return ret_bundle or bundle, index
end

--- Validate a table can be used as an OSC bundle.
-- @param tbl The table to validate.
-- @return true or error.
function Bundle.tbl_validate(tbl)
  assert(tbl.timetag, 'missing timetag')
  return true
end

--- Validate a table can be used as an OSC bundle.
-- @param data The byte string to validate.
-- @return true or error.
function Bundle.bytes_validate(data)
  local ok, value, index = Types.unpack('s', data, 1)
  assert(s == '#bundle', 'missing bundle marker')
  ok, value, _ = Types.unpack('t', data, index)
  assert(ok, 'missing bundle timetag')
  return true
end

--- Pack an OSC bundle.
--
-- The returned object is suitable for sending via a transport layer such as
-- UDP or TCP.
--
-- @param tbl The content to pack.
-- @return OSC data packet (byte string).
function Bundle.pack(tbl)
  Bundle.tbl_validate(tbl)
  local packet = {}
  return _pack(tbl, packet)
end

--- Unpack an OSC bundle byte string.
--
-- @param data The data to unpack.
-- @param offset The initial offset into data.
-- @return table with the content of the OSC bundle.
function Bundle.unpack(data, offset)
  local bundle = {}
  return _unpack(data, bundle, offset or 1)
end

return Bundle
