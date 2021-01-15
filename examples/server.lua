-----------------
-- Simple server.
-- Uses the udp-socket plugin.

local losc = require'losc'
local plugin = require'losc.plugins.udp-socket'

local udp = plugin.new { recvAddr = 'localhost', recvPort = 9000 }
local osc = losc.new { plugin = udp }

local function print(data)
  local msg = data.message
  print('address: ' .. msg.address, 'timestamp: ' .. data.timestamp)
  for index, argument in ipairs(msg) do
    print('index: ' .. index, 'arg: ' .. argument)
  end
end

losc:add_handler('/test', function(data)
  print(data)
end)

losc:add_handler('/param/{x,y,z}', function(data)
  print(data)
end)

losc:open() -- blocking call
