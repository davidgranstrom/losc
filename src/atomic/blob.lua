local struct = require'struct'
local Atomic = require'atomic'

local AtomicBlob = {};
AtomicBlob.__index = AtomicBlob

setmetatable(AtomicBlob, {__index = Atomic})

function AtomicBlob.new(value)
  local self = setmetatable({}, AtomicBlob)
  self.value = value
  self.data = nil
  return self
end

function AtomicBlob:pack()
  self.data = struct.pack('>!4Bc0', #self.value, self.value)
end

function AtomicBlob:unpack()
  self.value, self.offset = struct.unpack('>!4Bc0', self.data, self.offset)
  return self.offset
end

return AtomicBlob
