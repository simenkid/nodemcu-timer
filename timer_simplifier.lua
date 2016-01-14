------------------------------------------------------------------------------
-- Timer Utility in Node.js Style
-- LICENSE: MIT
-- Simen Li <simenkid@gmail.com>
------------------------------------------------------------------------------
local tm, lock, ttbl, exec = { id = 6, enable = false, tick = 1000 }, false, {}, {}

local function rm(tbl, pred)
    if (pred == nil) then return tbl end
    local x, len = 0, #tbl
    for i = 1, len do
        local trusy, idx = false, (i - x)
        if (type(pred) == 'function') then trusy = pred(tbl[idx])
        else trusy = tbl[idx] == pred
        end

        if (trusy) then
            table.remove(tbl, idx)
            x = x + 1
        end
    end
    return tbl
end

local function chk()
    if (lock) then return else lock = true end
    if (#ttbl == 0) then tm.stop() return end

    for i, tob in ipairs(ttbl) do
        tob.delay = tob.delay - 1
        if (tob.delay == 0) then
            if (tob.rp > 0) then tob.delay = tob.rp end
            table.insert(exec, tob)
        end
    end

    for ii, tt in ipairs(exec) do
        rm(ttbl, tt)
        local status, err = pcall(tt.f, unpack(tt.argus))
        if not (status) then print("Task execution fails: " .. tostring(err)) end
        if (tt.delay > 0) then table.insert(ttbl, tt) end
        exec[ii] = nil
    end
    lock = false
end

function tm.start()
    tmr.alarm(tm.id, tm.tick, 1, chk)   -- tid = 6, intvl = 2ms, repeat = 1
    tm.enable = true
end

function tm.stop()
    tmr.stop(tm.id)
    tm.enable = false
    ttbl = rm(ttbl, function (v) return v ~= nil end)
    lock = false
end

function tm.set(tid)
    if (tid ~= tm.id) then
        tm.stop()
        tm.id = tid
        tm.start()
    end
end

function tm.setTimeout(fn, delay, ...)
    local tobj = { delay = delay, f = fn, rp = 0, argus = {...} }
    if (delay < 2) then tobj.delay = 1 end

    table.insert(ttbl, tobj)
    if (not tm.enable) then tm.start() end
    return tobj
end

function tm.setInterval(fn, delay, ...)
    local tobj = tm.setTimeout(fn, delay, ...)
    tobj.rp = tobj.delay
    return tobj
end

function tm.clear(tobj)
    tobj.rp = 0
    rm(exec, tobj)
    rm(ttbl, tobj)
end

return tm
