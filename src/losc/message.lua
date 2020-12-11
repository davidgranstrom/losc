local Types = require'losc.types'

local Message = {}

-- function Message.validate(tbl)
-- end

function Message.pack(tbl)
  assert(tbl.address, 'An OSC message must have an address.')
  assert(tbl.types, 'An OSC message must have at least one type.')
  local packet = {}
  local address = tbl.address
  local types = tbl.types
  -- address (prefix if missing)
  if address:sub(1,1) ~= '/' then
    address = '/' .. address
  end
  -- types
  packet[#packet + 1] = Types.pack.s(address)
  packet[#packet + 1] = Types.pack.s(',' .. types)
  local arg_index = 1
  -- remove types that doesn't require argument data
  local skip = string.format('[%s]', Types.pack.skip_types)
  types = types:gsub(skip, '')
  -- arguments
  for type in types:gmatch('.') do
    local item = tbl[arg_index]
    if item then
      local ok, buffer = pcall(Types.pack[type], item)
      if ok then
        packet[#packet + 1] = buffer
        arg_index = arg_index + 1
      end
    end
  end
  packet = table.concat(packet, '')
  return packet
end

function Message.unpack(data, offset)
  local message = {}
  local value, index
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
  local ok
  for type in types:gmatch('.') do
    ok, value, index = pcall(Types.unpack[type], data, index)
    if ok then
      message[#message + 1] = value
    end
  end
  return message, index
end

return Message
