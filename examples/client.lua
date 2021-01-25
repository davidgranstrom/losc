-----------------
-- Simple client.
-- Uses the udp-socket plugin.

local losc = require'losc'
local plugin = require'losc.plugins.udp-socket'

local udp = plugin.new {sendAddr = 'localhost', sendPort = 9000}
local osc = losc.new {plugin = udp}

local message = losc.new_message {
  address = '/foo/bar',
  types = 'ifsb',
  123, 1.234, 'hi', 'blobdata'
}

osc:send(message)
