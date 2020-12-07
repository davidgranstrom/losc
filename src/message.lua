
-- function pack_values(types, ...)
--   local data = {''}
--   local values = {...}
--   for index, type in ipairs(types) do
--     local pack = pack_types[type]
--     if pack then
--       local value = values[index]
--       table.insert(data, pack(value))
--     end
--   end
--   return table.concat(data, '')
-- end

