-----------------
-- Simple server.
-- Uses the udp-socket plugin.

local losc = require'losc'
local plugin = require'losc.plugins.udp-socket'

local udp = plugin.new {
  recvAddr = 'localhost',
  recvPort = 9000,
  ignore_late = true, -- ignore late bundles
}
local osc = losc.new {plugin = udp}

local function print_data(data)
  local msg = data.message
  print('address: ' .. msg.address, 'timestamp: ' .. data.timestamp)
  for index, argument in ipairs(msg) do
    print('index: ' .. index, 'arg: ' .. argument)
  end
end

osc:add_handler('/test', function(data)
  print_data(data)
end)

osc:add_handler('/param/{x,y,z}', function(data)
  print_data(data)
end)

osc:open() -- blocking call (depending on plugin used)
