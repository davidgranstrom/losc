# losc

![lint](https://github.com/davidgranstrom/losc/workflows/lint/badge.svg)
![unit-tests](https://github.com/davidgranstrom/losc/workflows/unit-tests/badge.svg)
[![documentation](https://github.com/davidgranstrom/losc/workflows/docs/badge.svg)][docs]

[OSC][osc] 1.0 implementation for `lua` and `luajit`.

Compatible with lua 5.1 >= 5.4 luajit 2.0 and luajit 2.1.0-beta3

## Features

* Implements the complete OSC 1.0 specification.
* Pure lua implementation, portable.
* Support for extended OSC types
* Transport layers implemented as plugins.

## Basic usage

```lua
local losc = require'losc'
local udp = require'losc.plugins.udp-socket'

-- Configure
upd.options = {
  sendAddr = 'localhost',
  sendPort = 57120,
}

-- Register to use lua-socket UDP plugin
losc:use(udp)

-- Create a message
local message = losc.new_message({
  address = '/foo/bar',
  types = 'ifsb',
  123, 1.234, 'hi', 'blobdata'
})

-- Send it over UDP
losc:send(message)
```

## API

The API is divided into two parts - a high level (opaque) and a low level based on plain lua tables.

The two API:s are decoupled from each other which makes it possible to
implement new high level API:s on top of the serialization functions if needed.

Read more about it in the [documentation][docs].

## License

```
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
```

[osc]: http://opensoundcontrol.org/spec-1_0
[docs]: https://davidgranstrom.github.io/losc
