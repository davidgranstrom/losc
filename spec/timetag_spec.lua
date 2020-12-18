local inspect = require'inspect'
local Timetag = require'losc.timetag'

describe('Timetag', function()
  describe('pack', function()
    it('packs correct byte representation', function()
      -- create a timetag with special value "now"
      local tt = Timetag.new_from_usec()
      local data = Timetag.pack(tt.content)
      assert.are.equal(0, #data % 4)
      assert.are.equal('\0\0\0\0\0\0\0\1', data)
    end)
  end)

  describe('unpack', function()
    it('unpacks the correct value', function()
      local now = os.time()
      local tt = Timetag.new_from_usec(now)
      local data = Timetag.pack(tt.content)
      local value = Timetag.unpack(data)
      assert.not_nil(value)
      assert.is_true(value.seconds > now)
      assert.are.equal(0, value.fractions)
      assert.are.equal(now, value.seconds - 2208988800)
    end)
  end)

  describe('methods', function()
    it('returns a timestamp with microsecond precision', function()
      local now = os.time()
      local tt = Timetag.new_from_usec(now)
      assert.are.equal(now, tt:timestamp() / 1e6)
    end)

    it('has overloaded add operator', function()
      local now = os.time()
      local tt = Timetag.new_from_usec(now)
      tt = tt + 1
      assert.are.equal(now + 1, tt:timestamp() / 1e6)
      tt = 1 + tt
      assert.are.equal(now + 2, tt:timestamp() / 1e6)
    end)
  end)
end)
