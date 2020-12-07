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

[osc]: http://opensoundcontrol.org/spec-1_0
