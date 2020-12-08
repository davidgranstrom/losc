local inspect = require'inspect'
local Types = require'types'

-- TODO:
-- validation
-- error handling
-- constructors

local Message = {}
-- Message.__index = {}

-- function Message.new(address, ...)
--   local self = setmetatable({}, Message)
--   local args = {...}
--   self.message = {
--     address = address,
--   }
-- end

local function add_to_packet(packet, type, value)
  local pack = Types.pack[type]
  if not pack then
    -- TODO: Or throw error?
    print('Could not pack type ' .. type)
    return
  end
  local buffer = pack(value)
  assert(buffer, 'Error packing type ' .. type)
  table.insert(packet, buffer)
end

function Message.pack(tbl)
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
  -- remove types that doesn't require argument data
  types = types:gsub('[TFNI]', '')
  for type in types:gmatch('.') do
    local item = tbl[index]
    if item then
      add_to_packet(packet, type, item)
      index = index + 1
    end
  end
  packet = table.concat(packet, '')
  return packet, #packet
end

function Message.unpack(data, offset)
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
  for type in types:gmatch('.') do
    value, index = Types.unpack[type](data, index)
    message[#message + 1] = value
  end
  return message
end

return Message
