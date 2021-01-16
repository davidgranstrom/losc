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

-- https://github.com/iryont/lua-struct/issues/3
-- lua < 5.3 will truncate the value to a signed 32-bit integer.
describe('int64', function()
  local data, expected_bytes
  local value = 9223372036854775807
  if string.pack then
    expected_bytes = {127, 255, 255, 255, 255, 255, 255, 255}
  else
    expected_bytes = {127, 255, 255, 255}
  end

  describe('pack', function()
    setup(function()
      data = Types.pack.h(value)
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
    local h, offset

    setup(function()
      h, offset = Types.unpack.h(data)
    end)

    it('returns the correct offset', function()
      if string.pack then
        assert.are.equal(offset, 9)
      else
        assert.are.equal(offset, 5)
      end
    end)

    it('returns the correct value', function()
      if string.pack then
        assert.are.equal(value, h)
      else
        assert.are.equal(2147483647, h)
      end
    end)
  end)
end)
