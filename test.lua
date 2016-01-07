-- function X(...)
--     print(...)
--     local p = {...}
--     print(p)
--     print(unpack(p))
-- end
-- X(1, 2, 3)

print(math.floor(3/2))

-- local tb1 = { 'a', 'b', 'c', 'd', 'c', 'c', 'e' }
-- local tb2 = { 5, 1, 15, 27, 6 }

-- function rmEntry(tbl, pred)
--     local x, len = 0, #tbl

--     for i = 1, len do
--         local trusy, idx = false, (i - x)
--         if (type(pred) == 'function') then trusy = pred(tbl[idx])
--         else trusy = tbl[idx] == pred
--         end

--         if (tbl[idx] ~= nil and trusy) then
--             table.remove(tbl, idx)
--             x = x + 1
--         end
--     end
--     return tbl
-- end

-- local tbx = rmEntry(tb1, 'c')

-- print(tbx)
-- print(tb1)

-- tbx = rmEntry(tb2, function(v) return v > 10 end)

-- print(tbx)
-- print(tb2)
-- -- local x = 0
-- -- local len2 = #tb2

-- -- for i=1, len2 do
-- --  local index = i - x
-- --  if (tb2[index] ~= nil and tb2[index] <= 6) then
-- --      table.remove(tb2, index)
-- --      x = x + 1
-- --  end
-- -- end
-- -- for i, v in ipairs(tb1) do
-- --  print('i: ' .. i .. ', v: ' .. v)
-- --  table.remove(tb1, i - x)
-- --  x = x + 1
-- -- end
-- print('---------')
-- print(#tb2)
-- for i, v in ipairs(tb1) do
--     print('i: ' .. i .. ', v: ' .. v)
-- end

