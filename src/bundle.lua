local inspect = require'inspect'

local Types = require'types'
local Message = require'message'

local Bundle = {}

local function is_bundle(tbl)
  return tbl.timetag and true or false
end

-- TODO: Move to Type
local function safe_pack(type, value)
  return pcall(Types.pack[type], value)
end

local function pack(bndl, packet)
  packet[#packet + 1] = Types.pack.s('#bundle')
  packet[#packet + 1] = Types.pack.t(bndl.timetag)
  for _, item in ipairs(bndl) do
    if is_bundle(item) then
      if item.timetag >= bndl.timetag then
        return pack(item, packet)
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
  return pack(tbl, packet)
end

local function unpack(data, ret_bundle, offset)
  local bundle = {}
  local value, index
  ret_bundle[#ret_bundle + 1] = bundle
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
      return unpack(data, bundle, index)
    end
    value, index = Types.unpack.i(data, index)
    value, index = Message.unpack(data, index)
    bundle[#bundle + 1] = value
  end
  return ret_bundle
end

function Bundle.unpack(data)
  local bundle = {}
  return unpack(data, bundle, 1)
end

local bndl = {
  timetag = 1,
  {address = '/foo', types = 'iii', 1, 2, 3},
  {
    timetag = 2,
    {address = '/baz', types = 'i', 7},
    -- {
    --   timetag = 3,
    --   {address = '/abc', types = 'i', 74},
    -- }
  }
}

local data = Bundle.pack(bndl)
print(inspect(data))
local bundle = Bundle.unpack(data)
print(inspect(bundle))

return Bundle
