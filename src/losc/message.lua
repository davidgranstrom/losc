--- OSC Message
-- @module losc.message

local inspect = require'inspect'
local Types = require'losc.types'

local Message = {}
Message.__index = Message

--- High level API
-- @section high-level-api

--- Create a new OSC message.
--
-- An OSC message consists of an OSC Address Pattern followed by an
-- OSC Type Tag String followed by zero or more OSC Arguments.
--
-- @param[opt] ... arguments.
--
-- @return An OSC message object.
-- @see losc.types
function Message.new(...)
  local self = setmetatable({}, Message)
  local args = {...}
  self.kind = 'm'
  self.content = {}
  if #args > 1 then
    if type(args[1]) ~= 'string' then
      error('First argument must be an OSC address string.')
    end
    self.content.address = args[1]
    self.content.types = args[2] or ''
    for arg in ipairs(args) do
      self.content[#self.content + 1] = arg
    end
  end
  return self
end

--- Create a new OSC message from a table.
--
-- @param tbl The table to create the message from.
-- @return An OSC message object.
-- @usage local message = Message.new_from_tbl({address = 'foo', types = 'i', 123})
function Message.new_from_tbl(tbl)
  if not tbl then
    error('Can not create message from empty table.')
  end
  local ok, err = pcall(Message.tbl_validate, tbl)
  if not ok then
    print(err)
    return nil
  end
  local self = setmetatable({}, Message)
  self.kind = 'm'
  self.content = tbl
  return self
end

--- Create a new OSC message from binary data.
--
-- @param data Binary string of OSC data.
-- @return An OSC message object.
-- @usage local message = Message.new_from_bytes(data)
function Message.new_from_bytes(data)
  if not data then
    error('Can not create message from empty data.')
  end
  local ok, err = Message.bytes_validate(data)
  if not ok then
    print(err)
    return nil
  end
  local self = setmetatable({}, Message)
  self.kind = 'm'
  self.content = Message.unpack(data)
  return self
end

--- Append arguments to the message.
--
-- @param type OSC type string.
-- @param[opt] item Item to append.
-- @see losc.types
-- @usage message:append('i', 123)
-- @usage message:append('T')
function Message:append(type, item)
  self.types = self.types .. type
  if item then
    self.content[#self.content + 1] = item
  end
end

--- Check that the message is valid.
-- @return true or error if table is missing keys.
function Message:is_valid()
  return self.content and Message.tbl_validate(self.content)
end

--- Get the OSC address.
-- @return The OSC address or an empty string.
function Message:get_address()
  return self.content.address or ''
end

--- Set the OSC address.
-- @param str The address to set.
function Message:set_address(str)
  self.content.address = str
end

--- Low level API
-- @section low-level-api

--- Validate a table to be used as a message constructor.
-- @param tbl The table to create the message with.
-- @return true or error if table is missing keys.
function Message.tbl_validate(tbl)
  assert(tbl.address, 'table is missing "address" field.')
  assert(tbl.types, 'table is missing "types" field.')
  return true
end

--- Validate a binary string to see if it is a valid OSC message.
-- @param data The byte string to validate.
-- @return true or error.
function Message.bytes_validate(bytes)
  local ok, value = pcall(Types.unpack.s, bytes)
  if ok and value:sub(1, 1) == '/' then
    if #bytes % 4 == 0 then
      return true
    else
      error('OSC message data must be a multiple of 4.')
    end
  else
    error('Malformed or missing OSC address in data.')
  end
end

--- Pack an OSC message.
--
-- @param tbl The content to pack.
-- @return OSC data packet.
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

--- Unpack an OSC message.
--
-- @param data The content to unpack.
-- @param offset The initial offset into data.
-- @return table with the content of the OSC message.
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
