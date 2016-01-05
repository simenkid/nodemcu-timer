local timer = {}
local exequeImmed = {}
local exeque = {}
local ttbl = {}

timer.enable = false
timer.id = 6

function checkloops()
    for i, tob in ttbl do
        tob.t = tob.t - 1
        if (tob.t == 1) then
            table.insert(exeque, tob)
            table.remove(ttbl, i)
        end
    end

    local tobj

    if (#exequeImmed > 0) then
        tobj = exequeImmed[1]
        table.remove(exequeImmed, 1)
    elseif (#exeque > 0) then
        tobj = exeque[1]
        table.remove(exeque, 1)
    elseif (#ttbl == 0) then
        tmr.stop(timer.id)
        timer.enable = false
    end

    if (tobj ~= nil) then
        -- Re-insert the repeatable tobj to table
        if (tobj.rp > 0) then
            tobj.delay = tobj.rp
            if (tobj.delay == 1) then
                table.insert(exeque, tobj)
            else
                table.insert(ttbl, tobj)
            end
        end
        -- Execute the target
        tobj.f(unpack(tobj.args))
    end
end

function timer.start()
    -- tid = 6, intvl = 1ms, repeat
    tmr.alarm(timer.id, 1, 1, checkloops)
    timer.enable = true
end

function timer.stop()
    tmr.stop(timer.id)
    timer.enable = false

    for i, _ in exequeImmed do table.remove(exequeImmed, i) end
    for i, _ in exeque do table.remove(exeque, i) end
    for i, _ in ttbl do table.remove(ttbl, i) end
end

function timer.set(tid)
    if (tid ~= timer.id) then
        timer.stop()
        timer.id = tid
        timer.start()
    end
end

function timer.setImmediate(fn, ...)
    if (timer.enable == false) then timer.start() end

    local tobj = { t = 0, f = fn, rp = 0, args = { ... } }
    table.insert(exequeImmed, tobj)
    return tobj
end

function timer.setTimeout(fn, delay, ...)
    if (timer.enable == false) then timer.start() end

    local tobj = { t = delay, f = fn, rp = 0, args = { ... } }

    if (delay < 2) then
        tobj.delay = 1
        table.insert(exeque, tobj)
    else
        table.insert(ttbl, tobj)
    end

    return tobj
end

function timer.setInterval(fn, delay, ...)
    if (timer.enable == false) then timer.start() end

    local tobj = { t = delay, f = fn, rp = delay, args = { ... } }
    if (delay < 2) then
        tobj.delay = 1
        table.insert(exeque, tobj)
    else
        table.insert(ttbl, tobj)
    end
    return tobj
end

function timer.clearImmediate(tobj)
    for i, v in exequeImmed do
        if (tobj == v) then table.remove(exequeImmed, i) end
    end
end

function timer.clearTimeout(tobj)
    for i, v in exeque do
        if (tobj == v) then table.remove(exeque, i) end
    end

    for i, v in ttbl do
        if (tobj == v) then table.remove(ttbl, i) end
    end
end

function timer.clearInterval(tobj)
    for i, v in exeque do
        if (tobj == v) then table.remove(exeque, i) end
    end

    for i, v in ttbl do
        if (tobj == v) then table.remove(ttbl, i) end
    end
end

return timer
