--[[
MIT License

Copyright (c) 2021 David Granström

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

------------------
-- High level API.
--
-- Main module of losc.
--
-- @module losc
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2021

local relpath = (...):gsub('%.init$', '')
local Message = require(relpath ..'.message')
local Bundle = require(relpath .. '.bundle')
local Timetag = require(relpath .. '.timetag')
local Pattern = require(relpath .. '.pattern')

local losc = {
  _VERSION = 'losc v1.0.1',
  _URL = 'https://github.com/davidgranstrom/losc',
  _DESCRIPTION = 'Open Sound Control (OSC) library for lua/luajit.',
  _LICENSE = [[
    MIT License

    Copyright (c) 2021 David Granström

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
  ]]
}
losc.__index = losc

--- Create a new instance.
-- @tparam[options] table options Options.
-- @usage local osc = losc.new()
-- @usage local osc = losc.new {plugin = plugin.new()}
function losc.new(options)
  local self = setmetatable({}, losc)
  self.handlers = {}
  if options then
    if options.plugin then
      self:use(options.plugin)
    end
  end
  return self
end

--- Create a new Message.
-- @tparam[opt] string|table args OSC address or table constructor.
-- @return message object
-- @see losc.message
-- @usage local message = losc.new_message()
-- @usage local message = losc.new_message('/address')
-- @usage local message = losc.new_message{address = '/test', types = 'iif', 1, 2, 3}
function losc.new_message(args)
  local ok, message = pcall(Message.new, args)
  if not ok then
    error(message)
  end
  return message
end

--- Create a new OSC bundle.
-- @param[opt] ... arguments.
-- @return bundle object
-- @see losc.bundle
-- @usage
-- local tt = losc:now()
-- local bundle = losc.new_bundle()
-- bundle:timetag(tt)
-- -- packet can be a message or another bundle
-- bundle:add(packet)
-- @usage
-- local tt = losc:now()
-- local bundle = losc.new_bundle(tt)
-- bundle:add(packet)
-- @usage
-- local tt = losc:now()
-- local bundle = losc.new_bundle(tt, packet, packet2)
function losc.new_bundle(...)
  local ok, bundle = pcall(Bundle.new, ...)
  if not ok then
    error(bundle)
  end
  return bundle
end

--- Specify a plugin to use as transport layer.
-- @param plugin The plugin to use, pass nil to disable current plugin.
function losc:use(plugin)
  self.plugin = plugin
  if plugin then
    self.plugin.handlers = self.handlers
  end
end

--- Get an OSC timetag with the current timestamp.
-- Will fall back to `os.time()` if `now()` is not implemented by the plugin
-- in use.
-- @usage local tt = losc:now()
-- @usage
-- -- 0.25 seconds into the future.
-- local tt = losc:now() + 0.25
function losc:now()
  if self.plugin and self.plugin.now then
    return self.plugin:now()
  end
  return Timetag.new(os.time(), 0)
end

--- Opens an OSC server.
-- This function might be blocking depending on the plugin in use.
-- @param[opt] ... Plugin specific arguments.
-- @return status, plugin handle or error
-- @usage losc:open()
function losc:open(...)
  if not self.plugin then
    error('"open" must be implemented using a plugin.')
  end
  return pcall(self.plugin.open, self.plugin, ...)
end

--- Closes an OSC server.
-- @param[opt] ... Plugin specific arguments.
-- @return status, nil or error
-- @usage losc:close()
function losc:close(...)
  if not self.plugin then
    error('"close" must be implemented using a plugin.')
  end
  return pcall(self.plugin.close, self.plugin, ...)
end

--- Send an OSC packet.
-- @param[opt] ... Plugin specific arguments.
-- @return status, nil or error
-- @usage
-- -- can be message or bundle.
-- local packet = losc.new_message{address = '/x', types = 'i', 1}
-- losc:send(packet)
-- -- additional plugin arguments (can vary between plugins)
-- losc:send(packet, 'localhost', 9000)
function losc:send(...)
  if not self.plugin then
    error('"send" must be implemented using a plugin.')
  end
  return pcall(self.plugin.send, self.plugin, ...)
end

--- Add an OSC handler.
-- @param pattern The pattern to match on.
-- @param func The callback to run if a message is received.
-- The callback will get a single argument `data` from where the messsage can be retrived.
-- @usage
-- osc:add_handler('/pattern', function(data)
--   -- message table, can be converted to Message if needed.
--   local message = data.message
--   -- timestamp when message was received, can be converted to Timetag if needed.
--   local timestamp = data.timestamp
--   -- table with remote (sender) info, can be empty depending on plugin.
--   local remote_info = data.remote_info
-- end)
-- @usage
-- osc:add_handler('/pattern', function(data)
--   -- arguments can be accessed by index from the message table
--   local arg1 = data.message[1]
--   local arg2 = data.message[2]
--   -- iterate over incoming OSC arguments
--   for _, argument in ipairs(data.message) do
--     print(argument)
--   end
-- end)
-- @usage
-- -- Pattern matching (groups)
-- osc:add_handler('/param/{x,y}/123', function(data) end)
-- -- Pattern matching (sequence)
-- osc:add_handler('/param/[a-f]/123', function(data) end)
-- -- Pattern matching (sequence)
-- osc:add_handler('/param/[!a-f]/123', function(data) end)
-- -- Pattern matching (wildcard)
-- osc:add_handler('/param/*/123', function(data) end)
-- osc:add_handler('*', function(data) end)
function losc:add_handler(pattern, func)
  self.handlers[pattern] = {
    pattern = Pattern.escape(pattern),
    callback = func,
  }
  if self.plugin then
    self.plugin.handlers = self.handlers
  end
end

--- Remove an OSC handler.
-- @param pattern The pattern for the handler to remove.
-- @usage losc:remove_handler('/handler/to/remove')
function losc:remove_handler(pattern)
  self.handlers[pattern] = nil
  if self.plugin then
    self.plugin.handlers[pattern] = nil
  end
end

--- Remove all registered OSC handlers.
-- @usage losc:remove_all()
function losc:remove_all()
  self.handlers = {}
  if self.plugin then
    self.plugin.handlers = {}
  end
end

return losc
