local Types = require'losc.types'

describe('float', function()
  local value = 1.2345678
  local expected_bytes = { 63, 158, 6, 81 }
  local data

  describe('pack', function()
    setup(function()
      data = Types.pack.f(value)
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
    local f, offset

    setup(function()
      f, offset = Types.unpack.f(data)
    end)

    it('returns the correct offset', function()
      assert.are.equal(offset, 5)
    end)

    it('returns the correct value', function()
      local res = math.abs(f - value) < 1e-7
      assert.are.is_true(res)
    end)
  end)
end)
