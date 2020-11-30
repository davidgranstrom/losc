local int32 = require'./int32'
local float32 = require'./float32'
local string = require'./string'
local blob = require'./blob'

return {
  AtomicInt32 = int32,
  AtomicFloat32 = float32,
  AtomicString = string,
  AtomicBlob = blob,
}
