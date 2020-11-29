local inspect = require'inspect'
local struct = require'struct'

local Atomic = {}
Atomic.__index = Atomic

-- big endian, 4 byte alignment
local format = '>!4'

function Atomic:new(value)
  local obj = {}
  setmetatable(obj, self)
  self.value = value
  self.offset = 1
  return obj
end

function Atomic:pack(type)
  if not self.value or not type then
    error('Must have value and type.')
  end
  if type == 'B' then
    return struct.pack(format .. 'Bc0', #self.value, self.value)
  end
  return struct.pack(format .. type, self.value)
end

function Atomic:unpack(buffer, type, offset)
  local fmt = format .. (type == 'B' and 'Bc0' or type)
  self.value, self.offset = struct.unpack(fmt, buffer, self.offset)
  return self.offset
end

local o = Atomic:new(123456789)
local bytes = o:pack('i4')
local offset = o:unpack(bytes, 'i4')
print('i32', o.value)

local o = Atomic:new(1.234)
local bytes = o:pack('f')
local offset = o:unpack(bytes, 'f')
print('f', o.value)

local o = Atomic:new(1.23456789)
local bytes = o:pack('d')
local offset = o:unpack(bytes, 'd')
print('d', o.value)

local o = Atomic:new('hello world')
local bytes = o:pack('s')
local offset = o:unpack(bytes, 's')
print('s', o.value)

local o = Atomic:new('hello')
local bytes = o:pack('B')
local offset = o:unpack(bytes, 'B')
print('b', o.value)
