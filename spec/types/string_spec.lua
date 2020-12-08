local inspect = require'inspect'
local Types = require'../../src/types'

describe('string', function()
  local value = 'hello'
  local expected_bytes = {104, 101, 108, 108, 111, 0, 0, 0}
  local data

  describe('pack', function()
    setup(function()
      data = Types.pack.s(value)
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
    local s, offset

    setup(function()
      s, offset = Types.unpack.s(data)
    end)

    it('returns the correct offset', function()
      assert.are.equal(offset, 9)
    end)

    it('returns the correct value', function()
      assert.are.equal(value, s)
    end)
  end)
end)
