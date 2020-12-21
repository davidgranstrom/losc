local Serializer = {}

-- Require a function for packing.
-- Try different fallbacks if string.pack is unavailable.
function Serializer.pack()
  if string.pack then
    return string.pack
  end
  local ok, _ = pcall(require, 'struct')
  if ok then
    return require'struct'.pack
  else
    return require'lib.struct'.pack
  end
end

-- Require a function for unpacking.
-- Try different fallbacks if string.unpack is unavailable.
function Serializer.unpack()
  if string.unpack then
    return string.unpack
  end
  local ok, _ = pcall(require, 'struct')
  if ok then
    return require'struct'.unpack
  else
    return require'lib.struct'.unpack
  end
end

return Serializer
