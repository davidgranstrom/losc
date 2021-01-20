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
-- @copyright David Granström 2020

local relpath = (...):gsub('%.init$', '')
local Message = require(relpath ..'.message')
local Bundle = require(relpath .. '.bundle')
local Timetag = require(relpath .. '.timetag')
local Pattern = require(relpath .. '.pattern')

local losc = {
  _VERSION = 'losc v1.0.0',
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
-- @usage local message = losc.new_message({ address = '/foo', types = 'iif', 1, 2, 3})
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
-- @usage local bundle = losc.new_bundle()
-- @usage
-- local tt = Timetag.new_raw()
-- local bundle = losc.new_bundle(tt)
-- @usage
-- local tt = Timetag.new(os.time(), 0)
-- local bundle = losc.new_bundle(tt, osc_msg, osc_msg2)
-- @usage
-- local tt = Timetag.new(os.time(), 0)
-- local bundle = losc.new_bundle(tt, osc_msg, other_bundle)
function losc.new_bundle(...)
  local ok, bundle = pcall(Bundle.new, ...)
  if not ok then
    error(bundle)
  end
  return bundle
end

--- Specify a plugin to use as transport layer.
-- @param plugin The plugin to use.
function losc:use(plugin)
  if not plugin then
    error('plugin can not be nil')
  end
  self.plugin = plugin
  self.plugin.handlers = self.handlers
end

--- Get an OSC timetag with the current timestamp.
-- Will fall back to `os.time()` if `now()` is not implemented by the plugin
-- in use.
function losc:now()
  if self.plugin and self.plugin.now then
    return self.plugin:now()
  end
  return Timetag.new(os.time(), 0)
end

--- Opens an OSC server.
-- @param[opt] ... Plugin specific arguments.
-- @return status, plugin handle or error
function losc:open(...)
  if not self.plugin then
    error('"open" must be implemented using a plugin.')
  end
  return pcall(self.plugin.open, self.plugin, ...)
end

--- Closes an OSC server.
-- @param[opt] ... Plugin specific arguments.
-- @return status, nil or error
function losc:close(...)
  if not self.plugin then
    error('"close" must be implemented using a plugin.')
  end
  return pcall(self.plugin.close, self.plugin, ...)
end

--- Send an OSC packet.
-- @param[opt] ... Plugin specific arguments.
-- @return status, nil or error
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
function losc:remove_handler(pattern)
  self.handlers[pattern] = nil
  if self.plugin then
    self.plugin.handlers[pattern] = nil
  end
end

--- Remove all registered OSC handlers.
function losc:remove_all()
  self.handlers = {}
  if self.plugin then
    self.plugin.handlers = {}
  end
end

return losc
