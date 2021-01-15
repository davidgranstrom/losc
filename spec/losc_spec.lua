local losc = require'losc'
local Timetag = require'losc.timetag'
local Packet = require'losc.packet'

local osc = losc.new()

describe('osc', function()
  it('can create a message', function()
    local message = osc.new_message('/test')
    assert.is_true(pcall(Packet.validate, message))
    message = osc.new_message({address = '/test/123', types = 'if', 1, 2.3})
    assert.is_true(pcall(Packet.validate, message))
    assert.has_errors(function()
      osc.new_message({'/test/123'})
    end)
  end)

  it('prepends / to message address if missing', function()
    local message = osc.new_message('addr')
    assert.are.equal('/addr', message:address())
  end)

  it('can create a bundle', function()
    local tt = osc:now()
    local message = osc.new_message({address = '/test/123', types = 'if', 1, 2.3})
    local bundle = osc.new_bundle(tt, message)
    assert.is_true(pcall(Packet.validate, bundle))
    assert.has_errors(function()
      osc.new_bundle(nil, message)
    end)
  end)

  it('can add and remove OSC handlers', function()
    local pattern = '/foo/123'
    osc:add_handler(pattern, function(data) end)
    local pattern2 = '/foo/{bar,baz}/123'
    osc:add_handler(pattern2, function(data) end)
    assert.not_nil(osc.handlers[pattern])
    assert.not_nil(osc.handlers[pattern2])
    osc:remove_handler(pattern2, function(data) end)
    assert.is_nil(osc.handlers[pattern2])
    osc:remove_all()
    assert.is_nil(osc.handlers[pattern])
  end)

  it('can use', function()
    assert.has_errors(function()
      osc:use()
    end) 
  end)

  it('can open', function()
    assert.has_errors(function()
      osc:open()
    end) 
  end)

  it('can close', function()
    assert.has_errors(function()
      osc:close()
    end) 
  end)

  it('can send', function()
    assert.has_errors(function()
      osc:send()
    end) 
  end)

  describe('osc with plugin', function()
    setup(function()
      -- mock plugin
      local plugin = {}
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
      osc = losc.new {plugin = plugin}
    end)

    it('return current time as Timetag', function()
      local now = osc:now()
      assert.not_nil(now)
      assert.not_nil(now.seconds)
      assert.not_nil(now.fractions)
    end)

    it('can open', function()
      local ok, handle = osc:open()
      assert.is_true(ok)
      assert.not_nil(handle)
    end)

    it('can close', function()
      local ok, err = osc:close()
      assert.is_true(ok)
    end)

    it('can send', function()
      local message = osc.new_message('/test')
      local ok, err = osc:send(message)
      assert.is_true(ok)
    end)
  end)
end)
