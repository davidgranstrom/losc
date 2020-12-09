local inspect = require'inspect'
local Message = require'../src/message'
local Bundle = require'../src/bundle'

describe('Bundle', function()
  describe('pack', function()
    it('requires a timetag', function()
      local bndl = {
        {address = '/foo', types = 'iii', 1, 2, 3}
      }
      assert.has_errors(function()
        Bundle.pack(bndl)
      end)
    end)

    it('can pack a messages correctly', function()
      local bndl = {
        timetag = 0,
        {address = 'hello', types = 'T'},
        {address = 'world', types = 'i', 1},
      }
      local data = Bundle.pack(bndl);
      assert.not_nil(data)
      -- (8 + 8) + (4 + 12) + (4 + 16)
      assert.are.equal(52, #data)
    end)

    it('handles bundle with no contents', function()
      local bndl = { timetag = 0 }
      local data = Bundle.pack(bndl);
      assert.not_nil(data)
      assert.are.equal(#data % 4, 0)
    end)

    it('has a size that is an multiple of 4', function()
      local bndl = {
        timetag = 0,
        {address = 'hello', types = 'T'},
        {address = 'world', types = 'is', 1, 'foo'},
      }
      local data = Bundle.pack(bndl);
      assert.not_nil(data)
      assert.are.equal(#data % 4, 0)
    end)

    it('can pack bundles within bundles', function()
      local bndl = {
        timetag = 1,
        {address = '/foo', types = 'iii', 1, 2, 3},
        {address = '/bar', types = 'f', 1},
        {
          timetag = 2,
          {address = '/baz', types = 'i', 7},
          {
            timetag = 3,
            {address = '/abc', types = 'i', 74},
          }
        }
      }
      local data = Bundle.pack(bndl);
      assert.not_nil(data)
      assert.are.equal(#data % 4, 0)
    end)
  end)

  -- describe('unpack', function()
  --   local message
  --   local input = {
  --     address = '/fo',
  --     types = 'isTf',
  --     123,
  --     'hello',
  --     1.234,
  --   }

  --   setup(function()
  --     local buffer = Message.pack(input)
  --     message = Message.unpack(buffer)
  --   end)

  --   it('returns a table', function()
  --     assert.are.equal(type(message), 'table')
  --   end)

  --   it('handles types not represented in OSC data', function()
  --     assert.is_true(message[3])
  --   end)

  --   it('unpacks correct values', function()
  --     assert.are.equal(input.address, message.address)
  --     assert.are.equal(input.types, message.types)
  --     assert.are.equal(input[1], message[1])
  --     assert.are.equal(input[2], message[2])
  --     assert.are.equal(true, message[3])
  --     assert.is_true(math.abs(input[3] - message[4]) < 1e-4)
  --   end)
  -- end)
end)

