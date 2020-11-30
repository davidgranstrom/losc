local Atomic = require'atomic'

local AtomicFloat32 = {};
AtomicFloat32.__index = AtomicFloat32

setmetatable(AtomicFloat32, {__index = Atomic})

function AtomicFloat32.new(value)
  local self = setmetatable({}, AtomicFloat32)
  self.value = value
  self.data = nil
  return self
end

function AtomicFloat32:pack()
  self.data = self:__pack('f')
end

function AtomicFloat32:unpack()
  return self:__unpack(self.data, 'f')
end

return AtomicFloat32
