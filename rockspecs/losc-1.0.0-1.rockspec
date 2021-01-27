package = "losc"
version = "1.0.0-1"
source = {
   url = "git+https://github.com/davidgranstrom/losc.git",
   tag = "v1.0.0",
}
description = {
   summary = "Open Sound Control (OSC) library.",
   detailed = [[
       Open Sound Control (OSC) for lua/luajit with no external dependencies.
   ]],
   homepage = "https://github.com/davidgranstrom/losc",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1",
}
build = {
   type = "builtin",
   modules = {
      ["losc.bundle"] = "src/losc/bundle.lua",
      ["losc.init"] = "src/losc/init.lua",
      ["losc.lib.struct"] = "src/losc/lib/struct.lua",
      ["losc.message"] = "src/losc/message.lua",
      ["losc.packet"] = "src/losc/packet.lua",
      ["losc.pattern"] = "src/losc/pattern.lua",
      ["losc.plugins.udp-libuv"] = "src/losc/plugins/udp-libuv.lua",
      ["losc.plugins.udp-socket"] = "src/losc/plugins/udp-socket.lua",
      ["losc.serializer"] = "src/losc/serializer.lua",
      ["losc.timetag"] = "src/losc/timetag.lua",
      ["losc.types"] = "src/losc/types.lua"
   },
   install = {
      bin = {
         "bin/loscrecv",
         "bin/loscsend"
      }
   }
}
