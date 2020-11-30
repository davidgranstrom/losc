local inspect = require'inspect'
local AtomicFloat32 = require'../src/atomic/float32'
local AtomicString = require'../src/atomic/string'
local AtomicBlob = require'../src/atomic/blob'

-- string: (string.length(s) / 4 + 1) * 4
-- blob:   (string.length(s) + 3) / 4 * 4

describe('Atomic', function()
  -- local atomic


  -- setup(function()
  --   atomic = Atomic.new(1)
  -- end)

  -- it('creates a new object with offset', function()
  --   assert.are.equal(atomic.value, 1)
  --   assert.are.equal(atomic.offset, 1)
  -- end)

  -- local o = Atomic:new(123456789)
  -- local bytes = o:pack('i4')
  -- local offset = o:unpack(bytes, 'i4')
  -- print('i32', o.value)

  -- local o = Atomic:new(1.234)
  -- local bytes = o:pack('f')
  -- local offset = o:unpack(bytes, 'f')
  -- print('f', o.value)

  -- local o = Atomic:new(1.23456789)
  -- local bytes = o:pack('d')
  -- local offset = o:unpack(bytes, 'd')
  -- print('d', o.value)

  -- local o = Atomic:new('hello world')
  -- local bytes = o:pack('s')
  -- local offset = o:unpack(bytes, 's')
  -- print('s', o.value)

  -- local o = Atomic:new('hello')
  -- local bytes = o:pack('B')
  -- local offset = o:unpack(bytes, 'B')
  -- print('b', o.value)

end)
