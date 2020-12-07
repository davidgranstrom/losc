local inspect = require'inspect'
local Types = require'atomic'

local OSCMessage = {}
-- OSCMessage.__index = {}
-- function OSCMessage.new(address, ...)
--   local self = setmetatable({}, OSCMessage)
--   local args = {...}
--   self.message = {
--     address = address,
--   }
-- end

local msg = {
  address = "/foo/bar",
  types = 'iTsf',
  args = {
    123,
    'hello',
    123.456,
  }
}

local function add_to_packet(packet, type, value)
  local pack = Types.pack[type]
  if pack then
    local buffer = pack(value)
    assert(buffer, 'Error packing type ' .. type)
    table.insert(packet, buffer)
  else
    print('Warning: Unrecognized type ' .. type)
  end
end

function OSCMessage.pack(tbl)
  assert(tbl.address, 'An OSC message must have an address.')
  assert(tbl.types, 'An OSC message must have at least one type.')

  local packet = {}
  local address = tbl.address
  local types = tbl.types

  -- prefix if missing
  if address:sub(1,1) ~= '/' then
    address = '/' .. address
  end

  add_to_packet(packet, 's', address)
  add_to_packet(packet, 's', ',' .. types)

  local index = 1
  types = types:gsub('[TFNI]', '')
  for type in types:gmatch('.') do
    if tbl.args then
      local item = tbl.args[index]
      add_to_packet(packet, type, item)
      index = index + 1
    end
  end

  packet = table.concat(packet, '')
  return packet, #packet
end

function OSCMessage.unpack(data)
end
