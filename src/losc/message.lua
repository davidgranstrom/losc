---------------
-- OSC Message.
--
-- An OSC message consists of an OSC Address Pattern followed by an
-- OSC Type Tag String followed by zero or more OSC Arguments.
--
-- @module losc.message
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2020

local Types = require'losc.types'

local Message = {}
Message.__index = Message

--- High level API
-- @section high-level-api

--- Create a new OSC message.
--
-- @tparam[opt] string|table m OSC address or table constructor.
--
-- @return An OSC message object.
-- @see losc.types
-- @usage
-- local msg = Message.new()
-- @usage
-- local msg = Message.new('/some/addr')
-- @usage
-- local tbl = {address = '/some/addr', types = 'ifs', 1, 2.0, 'hi'}
-- local msg = Message.new(tbl)
function Message.new(m)
  local self = setmetatable({}, Message)
  self.content = {}
  self.content.address = ''
  self.content.types = ''
  if m then
    if type(m) == 'string' then
      self.content.address = m
    elseif type(m) == 'table' then
      local ok, err = Message.tbl_validate(m)
      assert(ok, err)
      self.content = m
    end
  end
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
  local ok, err, content
  ok, err = Message.bytes_validate(data)
  assert(ok, err)
  ok, err, content = Message.unpack(data)
  assert(ok, err)
  return Message.new(content)
end

--- Append arguments to the message.
--
-- @param type OSC type string.
-- @param[opt] item Item to append.
-- @see losc.types
-- @usage message:append('i', 123)
-- @usage message:append('T', true) -- value is required but will not packed in OSC message.
function Message:append(type, item)
  self.content.types = self.content.types .. type
  self.content[#self.content + 1] = item
end

--- Check that the message is valid.
-- @return true or error if table is missing keys.
function Message:is_valid()
  return self.content and Message.tbl_validate(self.content)
end

--- Get the OSC type string.
-- @return OSC type string or empty string.
function Message:get_types()
  return self.content.types
end

--- Message iterator.
--
-- Iterate over message types and arguments.
--
-- @return iterator using index, type, argument.
-- @usage for i, type, arg in message:iter() do
--   print(i, type, arg)
-- end
function Message:iter()
  if not self.content then
    return function() end, nil, nil
  end
  local tbl = {self.content.types, self.content}
  local function msg_it(t, i)
    i = i + 1
    local type = t[1]:sub(i, i)
    local arg = t[2][i]
    if type ~= nil and arg ~= nil then
      return i, type, arg
    end
    return nil
  end
  return msg_it, tbl, 0
end

--- Get the OSC address.
-- @return The OSC address.
function Message:get_address()
  return self.content.address
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
  assert(#tbl.types == #tbl, 'types and arguments mismatch')
  return true
end

--- Validate a binary string to see if it is a valid OSC message.
-- @param bytes The byte string to validate.
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

--- Pack a table to a byte string.
--
-- The returned object is suitable for sending via a transport layer such as
-- UDP or TCP.
--
-- @param tbl The content to pack.
-- @return OSC data packet (byte string).
function Message.pack(tbl)
  assert(tbl.address, 'An OSC message must have an address.')
  local packet = {}
  local address = tbl.address
  local types = tbl.types or ''
  -- address (prefix if missing)
  if address:sub(1,1) ~= '/' then
    address = '/' .. address
  end
  -- types
  packet[#packet + 1] = Types.pack.s(address)
  packet[#packet + 1] = Types.pack.s(',' .. types)
  -- arguments
  local index = 1
  for type in types:gmatch('.') do
    local item = tbl[index]
    if item then
      local ok, data = Types.pack(type, item)
      if ok then
        packet[#packet + 1] = data
      end
      index = index + 1
    end
  end
  return table.concat(packet, '')
end

--- Unpack OSC message byte string.
--
-- @param data The data to unpack.
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
    ok, value, index = Types.unpack(type, data, index)
    if ok then
      message[#message + 1] = value
    end
  end
  return message, index
end

return Message
