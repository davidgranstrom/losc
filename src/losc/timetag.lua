--------------
-- OSC Timetag.
--
-- Time tags are represented by a 64 bit fixed point number. The first 32 bits
-- specify the number of seconds since midnight on January 1, 1900, and the
-- last 32 bits specify fractional parts of a second to a precision of about
-- 200 picoseconds. This is the representation used by Internet NTP timestamps.
--
-- @module losc.timetag
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2020

local Serializer = require'losc.serializer'
local _pack = Serializer.pack()
local _unpack = Serializer.unpack()

local Timetag = {}

-- 70 years in seconds (1970 - 1900)
local NTP_SEC_OFFSET = 2208988800
-- 2^32
local TWO_POW_32 = 4294967296
-- 2^32 / 1000000
local USEC_TWO_POW_32 = 4294.967296

local function tt_add(timetag, seconds)
  local sec = math.floor(seconds)
  local frac = math.floor(TWO_POW_32 * (seconds - sec) + 0.5)
  sec = sec + timetag.content.seconds
  frac = frac + timetag.content.fractions
  return Timetag.new(sec, frac)
end

Timetag.__index = Timetag
Timetag.__add = function(a, b)
  if type(a) == 'number' then
    return tt_add(b, a)
  end
  if type(b) == 'number' then
    return tt_add(a, b)
  end
end

--- Low level API
-- @section low-level-api

--- Create a new Timetag.
--
-- @param[opt] tbl Table with timetag content.
-- @param[opt] seconds Seconds since January 1st 1900 in the UTC timezone.
-- @param[opt] fractions Fractions expressed as 1/2^32 of a second.
--
-- If there are no arguments a timetag with special value of "immediate" will be returned.
function Timetag.new(...)
  local self = setmetatable({}, Timetag)
  local args = {...}
  -- 0x0000000000000001 equals "now", so this is the default.
  self.content = {seconds = 0, fractions = 1}
  if #args >= 1 then
    if type(args[1]) == 'table' then
      self.content = args[1]
    elseif type(args[1]) == 'number' and not args[2] then
      self.content.seconds = args[1]
    elseif type(args[1]) == 'number' and type(args[2]) == 'number' then
      self.content.seconds = args[1]
      self.content.fractions = args[2]
    end
  end
  return self
end

--- High level API
-- @section high-level-api

--- New using a seconds and microseconds.
--
-- Given nil arguments will return a timetag with special value "immediate".
--
-- @param[opt] seconds Timestamp seconds.
-- @param[opt] microseconds Timestamp fractions.
-- @usage local tt = Timetag.new_from_usec() -- immediate
-- @usage local tt = Timetag.new_from_usec(time.now())
-- @usage local tt = Timetag.new_from_usec(tv.sec, tv.usec)
-- @see Timetag.new
function Timetag.new_from_usec(seconds, microseconds)
  if not seconds and not microseconds then
    return Timetag.new()
  end
  local secs, frac
  secs = (seconds or 0) + NTP_SEC_OFFSET
  frac = math.floor((microseconds or 0) * USEC_TWO_POW_32 + 0.5)
  return Timetag.new(secs, frac)
end

--- Create a new OSC Timetag from binary data.
--
-- @param data Binary string of OSC data.
-- @return A Timetag object.
-- @usage local tt = Timetag.new_from_bytes(data)
function Timetag.new_from_bytes(data)
  if not data then
    error('Can not create Timetag from empty data.')
  end
  local tt = Timetag.unpack(data)
  return Timetag.new(tt)
end

--- Get the timetag value with microsecond precision.
-- @return Timetag value in microsecond.
function Timetag:timestamp()
  return Timetag.get_timestamp(self.content)
end

--- Low level API
-- @section low-level-api

--- Get the timetag value with microsecond precision.
-- @param tbl Table with seconds and fractions.
-- @return Timetag value in microseconds.
function Timetag.get_timestamp(tbl)
  local seconds = 1000000 * math.max(0, tbl.seconds - NTP_SEC_OFFSET)
  local fractions = math.floor((tbl.fractions / USEC_TWO_POW_32) + 0.5)
  return seconds + fractions
end

--- Validate a table to be used as a Timetag.
-- @param tbl The table with the Timetag content.
function Timetag.tbl_validate(tbl)
  assert(tbl.seconds, 'Missing field "seconds"')
  assert(tbl.fractions, 'Missing field "fractions"')
end

--- Pack an OSC Timetag.
--
-- The returned object is suitable for sending via a transport layer such as
-- UDP or TCP.
--
-- @param tbl The timetag to pack.
-- @return OSC data packet (byte string).
-- @usage
-- local tt = {seconds = os.time(), fractions = 0}
-- local data = Timetag.pack(tt)
function Timetag.pack(tbl)
  Timetag.tbl_validate(tbl)
  local data = {}
  data[#data + 1] = _pack('>I4', tbl.seconds)
  data[#data + 1] = _pack('>I4', tbl.fractions)
  return table.concat(data, '')
end

--- Unpack an OSC Timetag.
--
-- @param data The data to unpack.
-- @param offset The initial offset into data.
-- @return First is a table with seconds and fractions, second is index of the bytes read + 1.
function Timetag.unpack(data, offset)
  local seconds, fractions
  seconds, offset = _unpack('>I4', data, offset)
  fractions, offset = _unpack('>I4', data, offset)
  return {seconds = seconds, fractions = fractions}, offset
end

return Timetag
