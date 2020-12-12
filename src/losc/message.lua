--- Message
-- @module losc.message

local Types = require'losc.types'

local Message = {}
Message.__index = Message

--- Create a new OSC message.
--
-- An OSC message consists of an OSC Address Pattern followed by an
-- OSC Type Tag String followed by zero or more OSC Arguments.
--
-- @param address String beginning with '/' (forward slash).
-- @param[opt] types String of OSC types
-- @param[opt] ... Arguments (data) to attach to the message.
-- @return An OSC message object.
-- @see losc.types
function Message.new(address, types, ...)
  assert(address, 'Message must have an address.')
  local self = setmetatable({}, Message)
  local args = {...}
  self.kind = 'm'
  -- create message
  self.content = {}
  self.content.address = address
  self.content.types = types or ''
  for arg in ipairs(args) do
    table.insert(self.content, arg)
  end
  return self
end

--- Validate the message.
-- @return True if message is valid or false.
function Message:is_valid()
  return Message.__is_valid(self.content)
end

--- Validate a message.
-- @param msg The message to validate.
-- @return True if message is valid or false.
function Message.__is_valid(msg)
  if not msg.address or not msg.types then
    return false
  end
  local types = msg.types:gsub(string.format('[%s]', Types.pack.skip_types), '')
  return #types == #msg
end

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
