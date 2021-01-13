# losc

[![lint](https://github.com/davidgranstrom/losc/workflows/lint/badge.svg)](https://github.com/davidgranstrom/losc/actions?query=workflow%3Alint)
[![unit-tests](https://github.com/davidgranstrom/losc/workflows/unit-tests/badge.svg)](https://github.com/davidgranstrom/losc/actions?query=workflow%3Aunit-tests)
[![documentation](https://github.com/davidgranstrom/losc/workflows/docs/badge.svg)][docs]

[OSC][osc] 1.0 implementation for `lua` and `luajit`.

Compatible with lua 5.1 >= 5.4 luajit 2.0 and luajit 2.1.0-beta3

## Features

* Implements the complete OSC 1.0 specification.
* Pure lua implementation, no platform dependent libraries.
* Support for extended OSC types.
* Plugin system for transport layers.
* Address pattern matching.
* Scheduled bundle evaluation (plugin dependent).

## Basic usage

```lua
local losc = require'losc'
local udp = require'losc.plugins.udp-socket'

-- Register to use the `lua-socket` UDP plugin
losc:use(udp)

-- Create a message
local message = losc.new_message {
  address = '/foo/bar',
  types = 'ifsb',
  123, 1.234, 'hi', 'blobdata'
}

-- Send it over UDP
losc:send(message, 'localhost', 9000)
```

## API

The API is divided into two parts:

1. Opaque high level API exposed through the `losc.lua` module.
2. Low level API exposing serialization/deserialization functions and types based on plain lua tables.

The two API:s are decoupled from each other which makes it possible to
implement new high level API:s on top of the low level API functions if needed.

Read more about it in the [documentation][docs].

## Benchmarks

Generated with lua 5.1.5 running on a 2.3 GHz Intel i5 processor.

```plain
Message pack:
 -> Iterations:  1000
 -> Time:  26.456378 ms
 -> Avg:  0.026456378 ms
 -> Bytes:  48000
Message unpack:
 -> Iterations:  1000
 -> Time:  32.237467 ms
 -> Avg:  0.032237467 ms
 -> Bytes:  48000
Bundle pack:
 -> Iterations:  1000
 -> Time:  71.503527 ms
 -> Avg:  0.071503527 ms
 -> Bytes:  120000
Bundle unpack:
 -> Iterations:  1000
 -> Time:  80.274404 ms
 -> Avg:  0.080274404 ms
 -> Bytes:  120000
```

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
[docs]: https://davidgranstrom.github.io/losc/
