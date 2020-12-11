local Types = require'losc.types'

describe('blob', function()
  local value = 'helloworld'
  local expected_bytes = {0, 0, 0, 10, 104, 101, 108, 108, 111, 119, 111, 114, 108, 100, 0, 0}
  local data

  describe('pack', function()
    setup(function()
      data = Types.pack.b(value)
    end)

    it('returns the correct byte representation', function()
      local bytes = {string.byte(data, 1, -1)}
      assert.are.equal(#bytes, #expected_bytes)
      for i, byte in ipairs(bytes) do
        assert.are.equal(expected_bytes[i], byte)
      end
    end)

    it('returns a multiple of 32', function()
      assert.are.equal(#data * 8 % 32, 0)
    end)
  end)

  describe('unpack', function()
    local blob, offset

    setup(function()
      blob, offset = Types.unpack.b(data)
    end)

    it('returns the correct offset', function()
      assert.are.equal(offset, 17)
    end)

    it('returns the correct value', function()
      assert.are.equal(value, blob)
    end)
  end)
end)
