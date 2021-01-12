local Message = require'losc.message'

describe('Message', function()
  describe('constructors', function()
    it('can create an empty message object', function()
      local message = Message.new()
      assert.not_nil(message)
      assert.is_true(type(message.content) == 'table')
    end)

    it('can create message object from table', function()
      local msg = {address = '/foo/bar', types = 's', 'hello'}
      local message = Message.new(msg)
      assert.not_nil(message)
    end)

    it('can create message object from binary data', function()
      local data = '/foo/bar\0\0\0\0,s\0\0hello\0\0\0'
      local message = Message.new_from_bytes(data)
      assert.not_nil(message)
    end)
  end)

  describe('methods', function()
    it('can get the address', function()
      local message = Message.new('/foo/bar')
      assert.are.equal(message:address(), '/foo/bar')
    end)

    it('can add arguments', function()
      local message = Message.new('/foo/bar')
      message:add('i', 123)
      message:add('f', 1.234)
      message:add('T')
      message:add('s', 'foo')
      assert.are.equal('ifTs', message:types())
      assert.are.equal(#message.content.types, #message.content)
    end)

    it('can iterate over types and arguments', function()
      local msg = {address = '/foo/bar', types = 'isFf', 1, 'hello', true, 1.234}
      local message = Message.new(msg)
      for i, type, arg in message:iter() do
        assert.are.equal(msg.types:sub(i, i), type)
        assert.are.equal(msg[i], arg)
      end
      message = Message.new()
      for i, type, arg in message:iter() do
        assert.is_nil(true) -- this should never be triggered
      end
    end)

    it('can validate an address', function()
      assert.is_false(pcall(Message.address_validate, '/foo/ /123'))
      assert.is_false(pcall(Message.address_validate, '/foo/#/123'))
      assert.is_false(pcall(Message.address_validate, '/foo/*/123'))
      assert.is_false(pcall(Message.address_validate, '/foo/,/123'))
      assert.is_false(pcall(Message.address_validate, '/foo/?/123'))
      assert.is_false(pcall(Message.address_validate, '/foo/[/123'))
      assert.is_false(pcall(Message.address_validate, '/foo/]/123'))
      assert.is_false(pcall(Message.address_validate, '/foo/{/123'))
      assert.is_false(pcall(Message.address_validate, '/foo/}/123'))
      assert.is_true(pcall(Message.address_validate, '/foo/bar/123'))
    end)
  end)

  describe('pack', function()
    it('requires an address', function()
      local m = {types = 'i', 1}
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
      local buffer = Message.pack(m)
      assert.not_nil(buffer)
      assert.are.equal(#buffer % 4, 0)
    end)

    it('skips types that should not be in argument data', function()
      local m = {
        address = '/fo',
        types = 'TiiFs',
        true,
        1,
        2,
        false,
        'hi'
      }
      local data = Message.pack(m)
      assert.not_nil(data)
      assert.are.equal('/fo\0,TiiFs\0\0\0\0\0\1\0\0\0\2', data)
    end)
  end)

  describe('unpack', function()
    local message
    local input = {
      address = '/fo',
      types = 'isTf',
      123,
      'hello',
      true,
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
      assert.are.equal(input[3], message[3])
      assert.is_true(math.abs(input[4] - message[4]) < 1e-4)
    end)
  end)
end)
