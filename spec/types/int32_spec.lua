local Types = require'losc.types'

describe('int32', function()
  local value = 123456789
  local expected_bytes = {7, 91, 205, 21}
  local data

  describe('pack', function()
    setup(function()
      data = Types.pack.i(value)
    end)

    it('returns the correct byte representation', function()
      local bytes = {string.byte(data, 1, -1)}
      for i, byte in ipairs(bytes) do
        assert.are.equal(expected_bytes[i], byte)
      end
    end)

    it('returns a multiple of 32', function()
      assert.are.equal(#data * 8 % 32, 0)
    end)
  end)

  describe('unpack', function()
    local i, offset

    setup(function()
      i, offset = Types.unpack.i(data)
    end)

    it('returns the correct offset', function()
      assert.are.equal(offset, 5)
    end)

    it('returns the correct value', function()
      assert.are.equal(i, value)
    end)
  end)
end)
