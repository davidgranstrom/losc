local inspect = require'inspect'
local Pattern = require'losc.pattern'
local Message = require'losc.message'
local Timetag = require'losc.timetag'
local losc = require'losc'

-- mock plugin
local plugin = {}
-- timetag precision
plugin.precision = 1000
plugin.now = function()
  return Timetag.new(os.time())
end
plugin.schedule = function(timestamp, handler)
  handler()
end

losc:use(plugin)

before_each(function()
  losc:remove_all()
end)

describe('Pattern', function()
  it('can dispatch incoming data', function()
    local data = Message.pack({address = '/foo/bar', types = 'i', 1})
    losc:add_handler('/foo/bar', function(data)
      assert.not_nil(data)
      assert.not_nil(data.message)
      assert.not_nil(data.timestamp)
      assert.not_nil(data.plugin)
      assert.are.equal('/foo/bar', data.message.address)
      assert.are.equal('i', data.message.types)
      assert.are.equal(1, data.message[1])
    end)
    Pattern.dispatch(data, plugin)
  end)

  describe('pattern matching', function()
    it('can match any single character (?)', function()
      local num_matches = 0
      losc:add_handler('/foo/ba?', function(data)
        assert.not_nil(data)
        assert.not_nil(data.message)
        assert.not_nil(data.timestamp)
        assert.not_nil(data.plugin)
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
      losc:add_handler('*', function(data)
        assert.not_nil(data)
        assert.not_nil(data.message)
        assert.not_nil(data.timestamp)
        assert.not_nil(data.plugin)
        num_matches = num_matches + 1
      end)
      Pattern.dispatch(data, plugin)
      assert.are.equal(1, num_matches)
    end)

    it('can match wildcard sequence (*)', function()
      local num_matches = 0
      losc:add_handler('/foo/*/baz', function(data)
        assert.not_nil(data)
        num_matches = num_matches + 1
      end)
      losc:add_handler('/foo/bar/*', function(data)
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
      losc:add_handler('/foo/[0-9]', function(data)
        assert.not_nil(data)
        num_matches = num_matches + 1
      end)

      local shouldmatch = Message.pack({address = '/foo/1', types = 'i', 1})
      Pattern.dispatch(shouldmatch, plugin)
      assert.are.equal(1, num_matches)
      shouldmatch = Message.pack({address = '/foo/123', types = 'i', 1})
      Pattern.dispatch(shouldmatch, plugin)
      assert.are.equal(2, num_matches)

      losc:remove_all()

      num_matches = 0
      losc:add_handler('/[!a-f]/foo', function(data)
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
      losc:add_handler('/foo/{bar,baz}/123', function(data)
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
      losc:remove_handler('/foo/{bar,baz}/123')
      losc:add_handler('/foo/{bar,baz}/{x,y,z}/123', function(data)
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
