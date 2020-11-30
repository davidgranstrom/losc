local Atomic = require'atomic'

local AtomicInt32 = {};
AtomicInt32.__index = AtomicInt32

setmetatable(AtomicInt32, {__index = Atomic})

function AtomicInt32.new(value)
  local self = setmetatable({}, AtomicInt32)
  self.value = value
  self.offset = 1
  self.data = nil
  return self
end

function AtomicInt32:pack()
  self.data = self:__pack('i4')
  return self.data
end

function AtomicInt32:unpack()
  self.offset = self:__unpack(self.data, 'i4')
  return self.offset
end

return AtomicInt32
