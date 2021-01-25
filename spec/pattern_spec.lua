local Pattern = require'losc.pattern'
local Message = require'losc.message'
local Bundle = require'losc.bundle'
local Packet = require'losc.packet'
local Timetag = require'losc.timetag'
local losc = require'losc'

-- mock plugin
local plugin = {}
-- timetag precision
plugin.precision = 1000
plugin.options = {}
plugin.options.ignore_late = true
plugin.remote_info = {}
plugin.now = function()
  return Timetag.new(os.time())
end
plugin.schedule = function(self, timestamp, handler)
  handler()
end

local osc = losc.new {plugin = plugin}

before_each(function()
  osc:remove_all()
end)

describe('Pattern', function()
  it('can dispatch incoming data', function()
    local data = Message.pack({address = '/foo/bar', types = 'i', 1})
    osc:add_handler('/foo/bar', function(data)
      assert.not_nil(data)
      assert.not_nil(data.message)
      assert.not_nil(data.timestamp)
      assert.not_nil(data.remote_info)
      assert.are.equal('/foo/bar', data.message.address)
      assert.are.equal('i', data.message.types)
      assert.are.equal(1, data.message[1])
    end)
    Pattern.dispatch(data, plugin)
  end)

  it('ignores late messages', function()
    local num = 0
    local message = Message.new {address = '/foo/bar', types = 'i', 1}
    local bundle = Bundle.new(Timetag.new(1), message)
    osc:add_handler('/foo/bar', function(data)
      num = num + 1
    end)
    Pattern.dispatch(Packet.pack(bundle), plugin)
    assert.are.equal(0, num)
    plugin.options.ignore_late = false
    Pattern.dispatch(Packet.pack(bundle), plugin)
    assert.are.equal(1, num)
  end)

  it('can dispatch nested bundles', function()
    local message = Message.new {address = '/foo/123', types = 'i', 1}
    local message2 = Message.new {address = '/foo/abc', types = 'f', 1.234}
    local bundle = Bundle.new(Timetag.new(123), message)
    local bundle2 = Bundle.new(Timetag.new(), bundle, message2)
    local num = 0
    osc:add_handler('/foo/*', function(data)
      num = num + 1
    end)
    plugin.options.ignore_late = false
    Pattern.dispatch(Packet.pack(bundle2), plugin)
    assert.are.equal(2, num)
  end)

  it('throws an error if bundled timetag is older than enclosing bundle', function()
    local message = Message.new {address = '/foo/123', types = 'i', 1}
    local message2 = Message.new {address = '/foo/abc', types = 'f', 1.234}
    local tt = Timetag.new(os.time())
    local bundle = Bundle.new(tt, message)
    local bundle2 = Bundle.new(tt + 1, bundle, message2)
    assert.has_errors(function()
      Pattern.dispatch(Packet.pack(bundle2), plugin)
    end)
  end)

  describe('pattern matching', function()
    it('can match any single character (?)', function()
      local num_matches = 0
      osc:add_handler('/foo/ba?', function(data)
        assert.not_nil(data)
        assert.not_nil(data.message)
        assert.not_nil(data.timestamp)
        assert.not_nil(data.remote_info)
        num_matches = num_matches + 1
      end)
      local data = Message.pack({address = '/foo/bar', types = 'i', 1})
      Pattern.dispatch(data, plugin)
      data = Message.pack({address = '/foo/baz', types = 'i', 1})
      Pattern.dispatch(data, plugin)
      assert.are.equal(2, num_matches)
    end)

    it('can match any sequence (*)', function()
      local num_matches = 0
      local data = Message.pack({address = '/foo/bar/baz', types = 'i', 1})
      osc:add_handler('*', function(data)
        assert.not_nil(data)
        assert.not_nil(data.message)
        assert.not_nil(data.timestamp)
        assert.not_nil(data.remote_info)
        num_matches = num_matches + 1
      end)
      Pattern.dispatch(data, plugin)
      assert.are.equal(1, num_matches)
    end)

    it('can match wildcard sequence (*)', function()
      local num_matches = 0
      osc:add_handler('/foo/*/baz', function(data)
        assert.not_nil(data)
        num_matches = num_matches + 1
      end)
      osc:add_handler('/foo/bar/*', function(data)
        assert.not_nil(data)
        num_matches = num_matches + 1
      end)
      local shouldmatch = Message.pack({address = '/foo/bar/baz', types = 'i', 1})
      local nomatch = Message.pack({address = '/foo', types = 'i', 1})
      Pattern.dispatch(nomatch, plugin)
      assert.are.equal(0, num_matches)
      Pattern.dispatch(shouldmatch, plugin)
      assert.are.equal(2, num_matches)
    end)

    it('can match sequence of characters ([])', function()
      local num_matches = 0
      osc:add_handler('/foo/[0-9]', function(data)
        assert.not_nil(data)
        num_matches = num_matches + 1
      end)

      local shouldmatch = Message.pack({address = '/foo/1', types = 'i', 1})
      Pattern.dispatch(shouldmatch, plugin)
      assert.are.equal(1, num_matches)
      shouldmatch = Message.pack({address = '/foo/123', types = 'i', 1})
      Pattern.dispatch(shouldmatch, plugin)
      assert.are.equal(2, num_matches)

      osc:remove_all()

      num_matches = 0
      osc:add_handler('/[!a-f]/foo', function(data)
        assert.not_nil(data)
        num_matches = num_matches + 1
      end)
      local shouldmatch = Message.pack({address = '/ghi/foo', types = 'i', 1})
      local nomatch = Message.pack({address = '/abc/foo', types = 'i', 1})
      Pattern.dispatch(nomatch, plugin)
      assert.are.equal(0, num_matches)
      Pattern.dispatch(shouldmatch, plugin)
      assert.are.equal(1, num_matches)
    end)

    it('can match groups {}', function()
      local num_matches = 0
      osc:add_handler('/foo/{bar,baz}/123', function(data)
        assert.not_nil(data)
        num_matches = num_matches + 1
      end)
      local shouldmatch = Message.pack({address = '/foo/bar/123', types = 'i', 1})
      local nomatch = Message.pack({address = '/foo/zig/123', types = 'i', 1})
      Pattern.dispatch(nomatch, plugin)
      assert.are.equal(0, num_matches)
      Pattern.dispatch(shouldmatch, plugin)
      assert.are.equal(1, num_matches)

      num_matches = 0
      osc:remove_handler('/foo/{bar,baz}/123')
      osc:add_handler('/foo/{bar,baz}/{x,y,z}/123', function(data)
        assert.not_nil(data)
        num_matches = num_matches + 1
      end)

      shouldmatch = Message.pack({address = '/foo/baz/z/123', types = 'i', 1})
      nomatch = Message.pack({address = '/foo/baz/q/123', types = 'i', 1})
      Pattern.dispatch(nomatch, plugin)
      assert.are.equal(0, num_matches)
      Pattern.dispatch(shouldmatch, plugin)
      assert.are.equal(1, num_matches)
    end)
  end)
end)
