local Types = require'losc.types'

describe('Types', function()
  local types = 'ifsb'
  local packed_data = {}
  local data = {
    i = 123456789,
    f = 1.2345678,
    s = 'hello',
    b = 'world123'
  }

  describe('pack', function()
    it('can handle the fundamental types', function()
      for type in types:gmatch('.') do
        assert.not_nil(Types.pack[type])
      end
    end)

    it('returns a multiple of 32', function()
      for k, v in pairs(data) do
        local buffer = Types.pack[k](v)
        assert.are.equal(#buffer * 8 % 32, 0)
        packed_data[k] = buffer
      end
    end)

    it('can be called as function', function()
      local ok, data = Types.pack('s', 'hello')
      assert.is_true(ok)
      assert.are.equal('hello\0\0\0', data)
      ok, data = Types.pack('s', 123)
      assert.is_false(ok)
    end)

    it('has types which will be skipped in packing', function()
      assert.is_nil(Types.pack['T'])
      assert.is_nil(Types.pack['F'])
      assert.is_nil(Types.pack['N'])
      assert.is_nil(Types.pack['I'])
    end)
  end)

  describe('unpack', function()
    it('can handle the fundamental types', function()
      for type in types:gmatch('.') do
        assert.not_nil(Types.unpack[type])
      end
    end)

    it('returns the correct value', function()
      for k, v in pairs(packed_data) do
        local value, offset, size
        if k == 'f' then
          value, offset = Types.unpack[k](v)
          assert.is_true(math.abs(data[k] - value) < 1e-6)
        else
          value, offset = Types.unpack[k](v)
          assert.are.equal(data[k], value)
        end
      end
    end)

    it('can be called as function', function()
      local data = 'hello\0\0\0'
      local ok, value = Types.unpack('s', data, 1)
      assert.is_true(ok)
      assert.are.equal('hello', value)
      ok, data = Types.unpack('s', nil, 1)
      assert.is_false(ok)
    end)
  end)
end)
