-- REMOVE NEXT LINE BEFORE MERGING
package.path = ';./src/?/init.lua;./src/?.lua;/usr/local/share/lua/5.1/?.lua'

local losc = require'losc'
local plugin = require'losc.plugins.udp-socket'

local udp = plugin.new {
  recvAddr = 'localhost',
  recvPort = 9000,
  non_blocking = true, -- do not block on :open(), :poll() handles processing
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

osc:open() -- non blocking call :)

local i = 0

while true do
    print("Loop iteration " .. i)
    require'socket'.select(nil, nil, 2) -- equivalent for sleep() to simulate other tasks
    osc:poll()
    i = i + 1
end
