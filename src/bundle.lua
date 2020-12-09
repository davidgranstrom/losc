local inspect = require'inspect'

local Types = require'types'
local Message = require'message'

local Bundle = {}

local function is_bundle(tbl)
  return tbl.timetag and true or false
end

-- TODO: Move to Type
local function safe_pack(type, value)
  return pcall(Types.pack[type], value)
end

local function pack(bndl, packet)
  packet[#packet + 1] = Types.pack.s('#bundle')
  packet[#packet + 1] = Types.pack.t(bndl.timetag)
  for _, item in ipairs(bndl) do
    if is_bundle(item) then
      if item.timetag >= bndl.timetag then
        return pack(item, packet)
      end
      error('nested bundle requires timetag greater than enclosing bundle.')
    end
    local message = Message.pack(item)
    packet[#packet + 1] = Types.pack.i(#message)
    packet[#packet + 1] = message
  end
  packet = table.concat(packet, '')
  return packet
end

function Bundle.pack(tbl)
  if not is_bundle(tbl) then
    error('bundle is missing time tag')
  end
  local packet = {}
  return pack(tbl, packet)
end

function Bundle.unpack(data)

end

local bndl = {
  timetag = 1,
  {address = '/foo', types = 'iii', 1, 2, 3},
  {address = '/bar', types = 'f', 1},
  {
    timetag = 2,
    {address = '/baz', types = 'i', 7},
    {
      timetag = 3,
      {address = '/abc', types = 'i', 74},
    }
  }
}
-- local data = Bundle.pack(bndl)
-- local bundle = Bundle.unpack(data)
-- print(inspect(bundle))

return Bundle
