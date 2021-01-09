-- TODO: Remove later
package.path = package.path .. ';./src/?.lua'
package.path = package.path .. ';./src/?/?.lua'

local losc = require'losc'
local Timetag = require'losc.timetag'
local ok, udp = pcall(require, 'losc.plugins.udp-socket')
if not ok then
  local msg = 'loscsend requires `luasocket`. Try: `luarocks install luasocket`'
  io.stderr:write(msg)
  return
end

local function usage()
  local str = ''
  str = str .. 'loscrecv - Dump incoming OSC message.\n'
  str = str .. '\nusage: loscsend port'
  str = str .. '\nexample: loscrecv 9000\n'
  io.write(str)
end

return function(args)
  if args and args[1] == '-h' or args[1] == '--help' then
    usage()
    os.exit(0)
  end

  local port = args[1]
  if not port then
    usage()
    os.exit(0)
  end

  losc:use(udp)
  losc:add_handler('*', function(data)
    local tt = Timetag.new_from_timestamp(data.timestamp)
    local time = string.format('%04x.%04x', tt:seconds(), tt:fractions())
    io.write(time .. ' ')
    io.write(data.message.address .. ' ')
    io.write(data.message.types .. ' ')
    for _, a in ipairs(data.message) do
      io.write(tostring(a) .. ' ')
    end
    io.write('\n')
  end)
  losc:open("127.0.0.1", arg[1] or 0)
end
