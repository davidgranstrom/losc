local Types = require'losc.types'

describe('Extended types', function()
  describe('No payload types', function()
    local value = ''
    local index = 1

    it('can unpack T (boolean)', function()
      value, index = Types.unpack.T(value, index)
      assert.is.equal(true, value)
      assert.are.equal(1, index)
    end)

    it('can unpack F (boolean)', function()
      value, index = Types.unpack.F(value, index)
      assert.is.equal(false, value)
      assert.are.equal(1, index)
    end)

    it('can unpack N (nil)', function()
      value, index = Types.unpack.N(value, index)
      assert.is.equal(false, value)
      assert.are.equal(1, index)
    end)

    it('can unpack I (infinitum)', function()
      value, index = Types.unpack.I(value, index)
      assert.is.equal(math.huge, value)
      assert.are.equal(1, index)
    end)
  end)
end)
