package = "losc"
version = "dev-1"
source = {
   url = "git+ssh://git@github.com/davidgranstrom/losc.git"
}
description = {
   summary = "",
   detailed = "",
   homepage = "",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1, < 5.5"
}
build = {
   type = "builtin",
   modules = {
      ["lib.struct"] = "src/lib/struct.lua",
      losc = "src/losc.lua",
      ["losc.bundle"] = "src/losc/bundle.lua",
      ["losc.message"] = "src/losc/message.lua",
      ["losc.packet"] = "src/losc/packet.lua",
      ["losc.pattern"] = "src/losc/pattern.lua",
      ["losc.plugins.udp-libuv"] = "src/losc/plugins/udp-libuv.lua",
      ["losc.plugins.udp-socket"] = "src/losc/plugins/udp-socket.lua",
      ["losc.serializer"] = "src/losc/serializer.lua",
      ["losc.timetag"] = "src/losc/timetag.lua",
      ["losc.types"] = "src/losc/types.lua"
   },
   copy_directories = {
      "docs"
   },
   install = {
      bin = {
         "bin/loscrecv",
         "bin/loscsend"
      }
   }
}
