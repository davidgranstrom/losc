# losc

[OSC][osc] serialization and deserialization for `lua` and `luajit`.

Compatible with lua versions 5.1, 5.2, 5.3 and luajit 2.0

## Features

* Pure lua implementation, no external libraries (see note below).
* OSC 1.0 spec compliant
* Extended OSC types
* Additional types can be added by the user without modifying the source

## Performance notes for 5.1 and luajit

For optimal performance with lua 5.1 and luajit the `struct` package is needed.

Install the package using `luarocks`:

```
luarocks install struct
```

The library will fall back on a pure lua struct implementation in case `struct` is not found.

## Development

It is recommended to set up a local build environment using `hererocks` to test with different lua versions.

First install `hererocks` (requires python)

```shell
pip3 install git+https://github.com/luarocks/hererocks
```

Then install lua and rock dependencies (for development)

```shell
hererocks .env --lua 5.1 --luarocks latest
# activate the hererocks environment
source .env/bin/activate
luarocks install struct inspect busted luacov 
source .env/bin/activate
```

[osc]: http://opensoundcontrol.org/spec-1_0
