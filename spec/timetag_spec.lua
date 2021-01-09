local Timetag = require'losc.timetag'

describe('Timetag', function()
  describe('constructors', function()
    it('can create a raw timetag', function()
      local tt = Timetag.new_raw()
      assert.not_nil(tt)
      assert.are.equal(0, tt:timestamp())
    end)

    it('can create a timetag from seconds and fractions', function()
      local now = os.time()
      local tt = Timetag.new(now, 5000) -- default is microsecond precision
      assert.not_nil(tt)
      assert.are.equal((now + 5) * 1000, tt:timestamp())
    end)

    it('can create a timetag from OSC data', function()
      local data = '\0\0\1\0\0\0\1\0'
      local tt = Timetag.new_from_bytes(data)
      assert.not_nil(tt)
      assert.are.equal(256, tt.content.seconds)
      assert.are.equal(256, tt.content.fractions)
    end)

    it('can create a timetag from a timestamp', function()
      local now = os.time()
      local tt = Timetag.new(now, 1234)
      local tt2 = Timetag.new_from_timestamp(tt:timestamp())
      assert.are.equal(tt:timestamp(), tt2:timestamp())
    end)
  end)

  describe('pack', function()
    it('packs correct byte representation', function()
      -- create a timetag with special value "now"
      local tt = Timetag.new()
      local data = Timetag.pack(tt.content)
      assert.are.equal(0, #data % 4)
      assert.are.equal('\0\0\0\0\0\0\0\1', data)
    end)
  end)

  describe('unpack', function()
    it('unpacks the correct value', function()
      local now = os.time()
      local tt = Timetag.new(now)
      local data = Timetag.pack(tt.content)
      local value = Timetag.unpack(data)
      assert.not_nil(value)
      assert.is_true(value.seconds > now)
      assert.are.equal(0, value.fractions)
      assert.are.equal(now, value.seconds - 2208988800)
    end)
  end)

  describe('methods', function()
    it('returns a timestamp with arbitrary precision', function()
      local now = os.time()
      local tt = Timetag.new(now) -- default is milliseconds
      assert.are.equal(now * 1000, tt:timestamp(1000))
      tt = Timetag.new(now, 0, 1000000) -- microseconds
      assert.are.equal(now * 1e6, tt:timestamp(1e6))
      tt = Timetag.new(now, 0, 1) -- seconds
      assert.are.equal(now, tt:timestamp(1))
    end)

    it('has overloaded add operator', function()
      local now = os.time()
      local tt = Timetag.new(now, 0, 1)
      tt = tt + 1
      assert.are.equal(now + 1, tt:timestamp(1))
      tt = 1 + tt
      assert.are.equal(now + 2, tt:timestamp(1))
      local tt2 = tt + 10
      assert.are.not_equal(tt, tt2)
    end)
  end)
end)
