local losc = require'losc'
local Timetag = require'losc.timetag'
local Packet = require'losc.packet'

describe('losc', function()
  it('can create a message', function()
    local message = losc.new_message('/test')
    assert.is_true(pcall(Packet.validate, message))
    message = losc.new_message({address = '/test/123', types = 'if', 1, 2.3})
    assert.is_true(pcall(Packet.validate, message))
    assert.has_errors(function()
      losc.new_message({'/test/123'})
    end)
  end)

  it('prepends / to message address if missing', function()
    local message = losc.new_message('addr')
    assert.are.equal('/addr', message:address())
  end)

  it('can create a bundle', function()
    local tt = losc:now()
    local message = losc.new_message({address = '/test/123', types = 'if', 1, 2.3})
    local bundle = losc.new_bundle(tt, message)
    assert.is_true(pcall(Packet.validate, bundle))
    assert.has_errors(function()
      losc.new_bundle(nil, message)
    end)
  end)

  it('can add and remove OSC handlers', function()
    local pattern = '/foo/123'
    losc:add_handler(pattern, function(data) end)
    local pattern2 = '/foo/{bar,baz}/123'
    losc:add_handler(pattern2, function(data) end)
    assert.not_nil(losc.handlers[pattern])
    assert.not_nil(losc.handlers[pattern2])
    losc:remove_handler(pattern2, function(data) end)
    assert.is_nil(losc.handlers[pattern2])
    losc:remove_all()
    assert.is_nil(losc.handlers[pattern])
  end)

  it('can use', function()
    assert.has_errors(function()
      losc:use()
    end) 
  end)

  it('can open', function()
    assert.has_errors(function()
      losc:open()
    end) 
  end)

  it('can close', function()
    assert.has_errors(function()
      losc:close()
    end) 
  end)

  it('can send', function()
    assert.has_errors(function()
      losc:send()
    end) 
  end)

  describe('losc with plugin', function()
    local plugin
    setup(function()
      -- mock plugin
      plugin = {}
      -- timetag precision
      plugin.precision = 1000
      plugin.now = function()
        return Timetag.new(os.time())
      end
      plugin.schedule = function(self, timestamp, handler)
        handler()
      end
      plugin.open = function(self)
        return {}
      end
      plugin.close = function(self)
      end
      plugin.send = function(self, msg)
        assert.are.equal(msg.content.address, '/test')
      end
      losc:use(plugin)
    end)

    it('return current time as Timetag', function()
      local now = losc:now()
      assert.not_nil(now)
      assert.not_nil(now.seconds)
      assert.not_nil(now.fractions)
    end)

    it('can open', function()
      local ok, handle = losc:open()
      assert.is_true(ok)
      assert.not_nil(handle)
    end)

    it('can close', function()
      local ok, err = losc:close()
      assert.is_true(ok)
    end)

    it('can send', function()
      local message = losc.new_message('/test')
      local ok, err = losc:send(message)
      assert.is_true(ok)
    end)
  end)
end)
