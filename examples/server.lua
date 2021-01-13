-----------------
-- Simple server.
-- Uses the udp-socket plugin.

local losc = require'losc'
local udp = require'losc.plugins.udp-socket'

-- Plugin specific options
udp.options = {
  recvAddr = 'localhost',
  recvPort = 9000,
}

-- Register to use `lua-socket` UDP plugin
losc:use(udp)

losc:add_handler('/test', function(data)
  local msg = data.message
  print('address: ' .. msg.address, 'timestamp: ' .. data.timestamp)
  io.write('args: ')
  for index, argument in ipairs(msg) do
    io.write(tostring(argument) .. ' ')
  end
  print('\n')
end)

losc:add_handler('/param/{x,y,z}', function(data)
  local msg = data.message
  print('address: ' .. msg.address, 'timestamp: ' .. data.timestamp)
  io.write('args: ')
  for index, argument in ipairs(msg) do
    io.write(tostring(argument) .. ' ')
  end
  print('\n')
end)

losc:open() -- blocking call
