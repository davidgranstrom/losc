local losc = require'losc'
local Packet = require'losc.packet'

describe('Packet', function()
  local message, bundle
  local mdata, bdata
  setup(function()
    _, message = losc.new_message('/foo')
    _, bundle = losc.new_bundle(losc:now(), message)
  end)

  it('can pack messages', function()
    mdata = Packet.pack(message)
    assert.not_nil(mdata)
    assert.is.equal(0, #mdata % 4)
  end)

  it('can pack bundles', function()
    bdata = Packet.pack(bundle)
    assert.not_nil(bdata)
    assert.is.equal(0, #bdata % 4)
  end)

  it('can unpack messages', function()
    local m = Packet.unpack(mdata)
    assert.not_nil(m)
    assert.is.equal(type(m), 'table')
    assert.are.equal('/foo', m.address)
  end)

  it('can unpack bundles', function()
    local b = Packet.unpack(bdata)
    assert.not_nil(bdata)
    assert.is.equal(type(b), 'table')
    assert.are.equal('/foo', b[1].address)
  end)
end)
