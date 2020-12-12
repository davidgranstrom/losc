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
  assert(address, 'Message must have an address.')
  local self = setmetatable({}, Message)
  local args = {...}
  self.kind = 'm'
  -- create message
  self.content = {}
  self.content.address = address
  self.content.types = types or ''
  for arg in ipairs(args) do
    self.content[#self.content + 1] = arg
  end
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

--- Create a new OSC message from binary data.
--
-- @param data Binary string of packed OSC data.
-- @return An OSC message object.
function Message.new_from_data(data)
  local content = Message.unpack(data)
  if not Message.__is_valid(content) then
    error('Invalid OSC input data.')
  end
  return Message.new(content.address, content.types, content)
end

--- Validate the message.
--
-- @return True if message is valid or false.
function Message:is_valid()
  return Message.__is_valid(self.content)
end

--- Low level API
-- @section low-level-api

--- Validate a message.
--
-- @param tbl The message to validate.
-- @return True if message is valid or false.
function Message.__is_valid(tbl)
  return tbl.address and tbl.types
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
