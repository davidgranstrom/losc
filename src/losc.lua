--- API
-- High level API.
--@module losc

local Message = require'losc.message'
local Bundle = require'losc.bundle'

local losc = {}

function losc.message_new(address, types, ...)
end

function losc.message_new_from_data(data)
end

function losc.bundle_new(timetag, ...)
end

function losc.client_new(...)
end

function losc.server_new(...)
end

return losc
