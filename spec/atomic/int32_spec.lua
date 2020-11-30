local AtomicInt32 = require'../../src/atomic/int32'

describe('int32', function()
  local atomic
  local expected_bytes = {7, 91, 205, 21}

  setup(function()
    atomic = AtomicInt32.new(123456789)
  end)

  describe('pack', function()
    local data

    setup(function()
      data = atomic:pack()
    end)

    it('returns the correct byte representation', function()
      local bytes = {string.byte(data, 1, -1)}
      for i, byte in ipairs(bytes) do
        assert.are.equal(expected_bytes[i], byte)
      end
    end)
  end)

  describe('unpack', function()
    local offset

    setup(function()
      offset = atomic:unpack()
    end)

    it('returns the correct offset', function()
      assert.are.equal(offset, 5)
      assert.are.equal(atomic.offset, 5)
    end)

    it('returns the correct value', function()
      assert.are.equal(atomic.value, 123456789)
    end)
  end)
end)
