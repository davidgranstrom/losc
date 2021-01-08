local losc = require'losc'
local udp = require'losc.plugins.udp-socket'

-- Configure the plugin
upd.options = {
  sendAddr = 'localhost',
  sendPort = 57120,
}

-- Use this plugin for all networking operations
losc:use(udp)

local message = losc.message_new({
  address = '/foo/bar',
  types = 'ifsb',
  123, 1.234, 'hi', 'blobdata'
})

losc:send(message)
