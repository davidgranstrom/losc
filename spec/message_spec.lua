local inspect = require'inspect'
local Message = require'../src/message'

describe('Message', function()
  describe('pack', function()
    it('requires an address and a type tag', function()
      local m = {types = 'i', 1}
      assert.has_errors(function()
        Message.pack(m)
      end)
      m = {address = '/foo', 1}
      assert.has_errors(function()
        Message.pack(m)
      end)
    end)

    it('has a size that is an multiple of 4', function()
      local m = {
        address = '/fo',
        types = 'is',
        123,
        'hello'
      }
      local buffer, size = Message.pack(m)
      assert.not_nil(buffer)
      assert.are.equal(size % 4, 0)
    end)
  end)

  describe('unpack', function()
    local message
    local input = {
      address = '/fo',
      types = 'isTf',
      123,
      'hello',
      1.234,
    }

    setup(function()
      local buffer = Message.pack(input)
      message = Message.unpack(buffer)
    end)

    it('returns a table', function()
      assert.are.equal(type(message), 'table')
    end)

    it('handles types not represented in OSC data', function()
      assert.is_true(message[3])
    end)

    it('unpacks correct values', function()
      assert.are.equal(input.address, message.address)
      assert.are.equal(input.types, message.types)
      assert.are.equal(input[1], message[1])
      assert.are.equal(input[2], message[2])
      assert.are.equal(true, message[3])
      assert.is_true(math.abs(input[3] - message[4]) < 1e-4)
    end)
  end)
end)
