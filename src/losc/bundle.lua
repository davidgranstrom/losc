--- Bundle
-- @module losc.bundle

local Types = require'losc.types'
local Message = require'losc.message'

local Bundle = {}

local function is_bundle(tbl)
  return tbl.timetag and true or false
end

local function _pack(bndl, packet)
  packet[#packet + 1] = Types.pack.s('#bundle')
  packet[#packet + 1] = Types.pack.t(bndl.timetag)
  for _, item in ipairs(bndl) do
    if is_bundle(item) then
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

function Bundle.pack(tbl)
  if not is_bundle(tbl) then
    error('bundle is missing time tag')
  end
  local packet = {}
  return _pack(tbl, packet)
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
  return ret_bundle or bundle
end

function Bundle.unpack(data)
  local bundle = {}
  return _unpack(data, bundle, 1)
end

return Bundle
