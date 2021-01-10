-- TODO: Remove later
package.path = package.path .. ';./src/?.lua'
package.path = package.path .. ';./src/?/?.lua'

local losc = require'losc'
local Types = require'losc.types'
local ok, udp = pcall(require, 'losc.plugins.udp-socket')
if not ok then
  local msg = 'loscsend requires `luasocket`. Try: `luarocks install luasocket`'
  io.stderr:write(msg)
  return
end

losc:use(udp)

local unpack = unpack or table.unpack

local function usage()
  local str = ''
  str = str .. 'loscsend - Send an OSC message via UDP.\n'
  str = str .. '\nusage: loscsend ip port address [types [args]]'
  str = str .. '\nsupported types: '
  local types = {}
  for key, _ in pairs(Types.pack) do
    types[#types + 1] = key
  end
  table.sort(types)
  str = str .. table.concat(types, ', ')
  str = str .. '\n\nexample: loscsend localhost 57120 ifs 1 2.3 "hi"\n'
  io.write(str)
end

local function opt_parse(options)
  local ip, port, address, types = unpack(options)
  if ip == '-h' or ip == '--help' then
    usage()
    os.exit(0)
  end
  return ip, tonumber(port), address, types
end

return function(args)
  if not args then
    usage()
    os.exit(0)
  end
  local ip, port, address, types = opt_parse(args)
  local ok, message = losc.new_message(address) -- TODO: address validation
  if not ok then
    print(message)
    os.exit(1)
  end
  if types then
    local index = 5
    for type in types:gmatch('.') do
      local item = arg[index]
      if string.match(type, '[ifdht]') then
        item = tonumber(item)
      end
      message:append(type, item)
      index = index + 1
    end
  end
  if ip and port then
    losc:send(message, ip, port)
  else
    print('Must specify ip and port. See loscsend -h for usage.')
    os.exit(1)
  end
  losc:close()
end