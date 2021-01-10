local Types = require'losc.types'

describe('double', function()
  local value = 1.234567891234
  local expected_bytes = {63, 243, 192, 202, 66, 216, 170, 221}
  local data

  describe('pack', function()
    setup(function()
      data = Types.pack.d(value)
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
    local d, offset

    setup(function()
      d, offset = Types.unpack.d(data)
    end)

    it('returns the correct offset', function()
      assert.are.equal(offset, 9)
    end)

    it('returns the correct value', function()
      local res = math.abs(d - value) < 1e-7
      assert.are.is_true(res)
    end)
  end)
end)
