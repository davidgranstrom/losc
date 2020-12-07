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

-- local msg = {
--   address = "/foo/bar",
--   types = 'isf',
--   args = {
--     123,
--     'hello',
--     123.456,
--   }
-- }

-- local msg = {
--   address = "/",
--   types = 's',
--   args = {
--     'hej',
--   }
-- }

local msg = {
  address = "/2345678",
  types = 'isfss',
  args = {
    123,
    'hello',
    1.234,
    'world',
    'hi!',
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

local function add_message_arg(message, type, data, offset)
  local value, index = 0
  local unpack = Types.unpack[type]
  if unpack then
    value, index = unpack(data, offset)
    assert(value, 'Error unpacking type ' .. type)
    table.insert(message, value)
  else
    print('Warning: Unrecognized type ' .. type)
  end
  return index
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
      if item then
        add_to_packet(packet, type, item)
        index = index + 1
      end
    end
  end

  packet = table.concat(packet, '')
  return packet, #packet
end

function OSCMessage.unpack(data, offset)
  local message = {}
  local value, index
  -- initial offset into data
  offset = offset or 1
  -- address
  value, index = Types.unpack.s(data, offset)
  message.address = value
  -- type tag
  value, index = Types.unpack.s(data, index)
  assert(value:sub(1, 1) == ',', 'Error: malformed type tag.')
  local types = value:sub(2) -- remove prefix
  message.types = types
  -- arguments
  message.args = {}
  for type in types:gmatch('.') do
    index = add_message_arg(message.args, type, data, index)
  end
  return message
end

local data, size = OSCMessage.pack(msg)
-- print('pack', inspect(data), size)
local msg = OSCMessage.unpack(data)
print(inspect(msg))
