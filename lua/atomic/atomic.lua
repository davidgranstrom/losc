local inspect = require'inspect'
local struct = require'struct'

local Atomic = {}
Atomic.__index = Atomic

-- big endian, 4 byte alignment
local format = '>!4'

function Atomic.new(value)
  local self = setmetatable({}, Atomic)
  self.value = value
  self.offset = 1
  return self
end

function Atomic:__pack(type)
  if not self.value or not type then
    error('Must have value and type.')
  end
  return struct.pack(format .. type, self.value)
end

function Atomic:__unpack(buffer, type)
  self.value, self.offset = struct.unpack(format .. type, buffer, self.offset)
  return self.offset
end

return Atomic
