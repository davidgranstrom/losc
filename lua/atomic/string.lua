local Atomic = require'atomic'

local AtomicString = {};
AtomicString.__index = AtomicString

setmetatable(AtomicString, {__index = Atomic})

function AtomicString.new(value)
  local self = setmetatable({}, AtomicString)
  self.value = value
  self.data = nil
  return self
end

function AtomicString:pack()
  self.data = self:__pack('s')
end

function AtomicString:unpack()
  return self:__unpack(self.data, 's')
end

return AtomicString
