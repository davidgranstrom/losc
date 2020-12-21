local Message = require'losc.message'
local Bundle = require'losc.bundle'
local Timetag = require'losc.timetag'

describe('Bundle', function()
  describe('pack', function()
    it('requires a timetag', function()
      local bndl = {
        {address = '/foo', types = 'iii', 1, 2, 3}
      }
      assert.has_errors(function()
        Bundle.pack(bndl)
      end)
    end)

    it('can pack a messages correctly', function()
      local bndl = {
        timetag = {seconds = 0, fractions = 1},
        {address = 'hello', types = 'T'},
        {address = 'world', types = 'i', 1},
      }
      local data = Bundle.pack(bndl);
      assert.not_nil(data)
      -- (8 + 8) + (4 + 12) + (4 + 16)
      assert.are.equal(52, #data)
    end)

    it('handles bundle with no contents', function()
      local bndl = { timetag = {seconds = 0, fractions = 1} }
      local data = Bundle.pack(bndl);
      assert.not_nil(data)
      assert.are.equal(#data % 4, 0)
    end)

    it('has a size that is an multiple of 4', function()
      local bndl = {
        timetag = {seconds = 0, fractions = 1},
        {address = 'hello', types = 'T'},
        {address = 'world', types = 'is', 1, 'foo'},
      }
      local data = Bundle.pack(bndl);
      assert.not_nil(data)
      assert.are.equal(#data % 4, 0)
    end)

    it('can pack nested bundles', function()
      local bndl = {
        timetag = {seconds = 0, fractions = 0},
        {address = '/foo', types = 'iii', 1, 2, 3},
        {address = '/bar', types = 'f', 1},
        {
          timetag = {seconds = 1, fractions = 0},
          {address = '/baz', types = 'i', 7},
          {
            timetag = {seconds = 3, fractions = 0},
            {address = '/abc', types = 'i', 74},
          }
        }
      }
      local data = Bundle.pack(bndl);
      assert.not_nil(data)
      assert.are.equal(#data % 4, 0)
    end)

    it('nested bundle timetag must be >= parent timetag', function()
      local now = os.time()
      local tt = Timetag.new_from_usec(now)
      local tt2 = Timetag.new_from_usec(now + 1)
      local bndl = {
        timetag = tt2.content,
        {address = '/foo', types = 'iii', 1, 2, 3},
        {
          timetag = tt.content,
        }
      }
      assert.has_errors(function()
        Bundle.pack(bndl)
      end)
    end)
  end)

  describe('unpack', function()
    local now = os.time()
    local tt = Timetag.new_from_usec(now)
    local tt1 = Timetag.new_from_usec(now + 1)
    local tt2 = Timetag.new_from_usec(now + 2)
    local bundle
    local data = {
      timetag = tt.content,
      {address = '/xxx', types = 'iii', 1, 2, 3},
      {
        timetag = tt1.content,
        {address = '/baz', types = 'i', 7},
        {address = '/yyy', types = 'i', 7},
        {
          timetag = tt2.content,
          {address = '/abc', types = 'i', 1},
          {address = '/123', types = 'i', 456},
          {address = '/zzz', types = 'i', 999},
        },
      }
    }

    setup(function()
      bundle = Bundle.unpack(Bundle.pack(data))
    end)

    it('returns a table', function()
      assert.are.equal(type(bundle), 'table')
    end)

    it('unpacks empty bundle', function()
      local bndl = {timetag = {seconds = 0, fractions = 1}}
      local res = Bundle.unpack(Bundle.pack(bndl))
      assert.not_nil(res)
      assert.are.equal(0, res.timetag.seconds)
      assert.are.equal(1, res.timetag.fractions)
      assert.are.equal(0, #res)
    end)

    local function compare_msg(msg1, msg2)
      local equal = msg1.address == msg2.address
      equal = equal and msg1.types == msg2.types
      for i, v in ipairs(msg1) do
        equal = equal and v == msg2[i]
      end
      return equal
    end

    it('unpacks bundle with messages', function()
      local bndl = {
        timetag = {seconds = 0, fractions = 1},
        {address = '/foo/bar', types = 'iii', 1, 2, 3},
        {address = '/foo/baz', types = 'iss', 1, 'hello', '#bundle'},
        {address = '/foo/baz', types = 'i', 4},
      }
      local res = Bundle.unpack(Bundle.pack(bndl))
      assert.not_nil(res)
      assert.are.equal(bndl.timetag.seconds, res.timetag.seconds)
      assert.are.equal(bndl.timetag.fractions, res.timetag.fractions)
      assert.are.equal(#bndl, #res)
      for i, msg in ipairs(res) do
        assert.is_true(compare_msg(bndl[i], msg))
      end
    end)

    it('unpacks nested bundles', function()
      assert.are.equal(data.timetag.seconds, bundle.timetag.seconds)
      assert.are.equal(data.timetag.fractions, bundle.timetag.fractions)
      assert.are.equal(data[2].timetag.seconds, bundle[2].timetag.seconds)
      assert.are.equal(data[2].timetag.fractions, bundle[2].timetag.fractions)
      assert.are.equal(data[2][3].timetag.seconds, bundle[2][3].timetag.seconds)
      assert.are.equal(data[2][3].timetag.fractions, bundle[2][3].timetag.fractions)
      assert.is_true((compare_msg(data[1], bundle[1])))
      assert.is_true((compare_msg(data[2][1], bundle[2][1])))
      assert.is_true((compare_msg(data[2][2], bundle[2][2])))
      assert.is_true((compare_msg(data[2][3][1], bundle[2][3][1])))
      assert.is_true((compare_msg(data[2][3][2], bundle[2][3][2])))
      assert.is_true((compare_msg(data[2][3][3], bundle[2][3][3])))
    end)
  end)
end)
