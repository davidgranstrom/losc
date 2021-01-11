package.path = package.path .. ';./src/?.lua'
package.path = package.path .. ';./src/?/?.lua'

local uv = require'luv'
local Message = require'losc.message'
local Bundle = require'losc.bundle'
local Timetag = require'losc.timetag'

local function bench(fn, iterations)
  -- warm up
  for i = 1, 10 do fn() end
  local start = uv.hrtime() -- nanoseconds
  local bytes = 0
  for i = 1, iterations do
    bytes = bytes + fn()
  end
  return (uv.hrtime() - start) / 1000000, bytes
end

local function report(str, iterations, time, bytes)
  print(str .. ':')
  print(' -> Iterations:  ' .. iterations)
  print(' -> Time:  ' .. time .. ' ms')
  print(' -> Avg:  ' .. time / iterations .. ' ms')
  print(' -> Bytes:  ' .. bytes)
end

local time, bytes
local iterations = 1000

-- 48 byte message
local msg = {
  address = '/foo/12', -- 8
  types = 'ifsb',      -- 8
  1, 2.5, 'hello world', 'blobdata' -- 4, 4, 12, 16
}

time, bytes = bench(function()
  return #Message.pack(msg)
end, iterations)
report('Message pack', iterations, time, bytes)

local data = Message.pack(msg)

time, bytes = bench(function()
  local message, offset = Message.unpack(data)
  return offset - 1
end, iterations)
report('Message unpack', iterations, time, bytes)

local sec, usec = uv.gettimeofday()
local tt = Timetag.new(sec, usec, 1e6)
local bndl = {
  timetag = tt.content,
  msg,
  msg,
}

time, bytes = bench(function()
  return #Bundle.pack(bndl)
end, iterations)
report('Bundle pack', iterations, time, bytes)

data = Bundle.pack(bndl)

time, bytes = bench(function()
  local bundle, offset = Bundle.unpack(data)
  return offset - 1
end, iterations)
report('Bundle unpack', iterations, time, bytes)
