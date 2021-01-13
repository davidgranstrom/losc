-----------------
-- Simple client.
-- Uses the udp-socket plugin.

local losc = require'losc'
local udp = require'losc.plugins.udp-socket'

-- Register to use `lua-socket` UDP plugin
losc:use(udp)

local message = losc.new_message {
  address = '/foo/bar',
  types = 'ifsb',
  123, 1.234, 'hi', 'blobdata'
}

losc:send(message, 'localhost', 9000)
