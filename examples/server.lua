local losc = require'losc'
local udp = require'losc.plugins.udp-socket'

-- Plugin specific options
udp.options = {
  sendAddr = 'localhost',
  sendPort = 57120,
  recvAddr = 'localhost',
  recvPort = 9000,
}

-- Register to use lua-socket UDP plugin
losc:use(udp)

losc:add_handler('/test/x', function(data)
  local msg = data.message
  print(msg.address, 'received:', data.timestamp)
  for index, argument in ipairs(msg) do
    print('arg' .. index, argument)
  end
end)

losc:add_handler('/test/y', function(data)
  local msg = data.message
  print(msg.address, 'received:', data.timestamp)
  for index, argument in ipairs(msg) do
    print('arg' .. index, argument)
  end
end)

losc:open() -- blocking call
