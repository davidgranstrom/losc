------------------
-- API.
--
-- The following functions are called in protected mode internally.
--
-- @module losc
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2020

local Message = require'losc.message'
local Bundle = require'losc.bundle'
local Timetag = require'losc.timetag'
local Pattern = require'losc.pattern'

local losc = {}
losc.__index = losc
losc.handlers = {}

--- Create a new Message.
--
-- @param[opt] ... arguments.
-- @return status, message object or error.
-- @see losc.message
-- @usage local ok, message = losc.new_message()
-- @usage local ok, message = losc.new_message('/address')
-- @usage local ok, message = losc.new_message({ address = '/foo', types = 'iif', 1, 2, 3})
function losc.new_message(...)
  return pcall(Message.new, ...)
end

--- Create a new OSC bundle.
--
-- @param[opt] ... arguments.
-- @return status, bundle object or error.
-- @see losc.bundle
-- @usage local bundle = losc.new_bundle()
-- @usage
-- local tt = Timetag.new_raw()
-- local ok, bundle = losc.new_bundle(tt)
-- @usage
-- local tt = Timetag.new(os.time(), 0)
-- local ok, bundle = losc.new_bundle(tt, osc_msg, osc_msg2)
-- @usage
-- local tt = Timetag.new(os.time(), 0)
-- local ok, bundle = losc.new_bundle(tt, osc_msg, other_bundle)
function losc.new_bundle(...)
  return pcall(Bundle.new, ...)
end

--- Specify a plugin.
-- @param plugin The plugin to use.
function losc:use(plugin)
  self.plugin = plugin
  self.plugin.handlers = self.handlers
end

--- Get a OSC timetag with the current timestamp.
-- Will fall back to os.time() if now() is not implemented by a plugin.
function losc:now()
  if self.plugin.now then
    return self.plugin:now()
  end
  return Timetag.new(os.time(), 0)
end

--- Opens an OSC server.
-- @param[opt] ... Plugin specific arguments.
-- @return status, plugin handle or error
function losc:open(...)
  return pcall(self.plugin.open, self.plugin, ...)
end

--- Closes an OSC server.
-- @return status, nil or error
function losc:close(...)
  return pcall(self.plugin.close, self.plugin, ...)
end

--- Send an OSC packet.
-- @param[opt] ... Plugin specific arguments.
-- @return status, nil or error
function losc:send(...)
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
