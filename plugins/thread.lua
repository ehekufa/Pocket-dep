local m = {}
m.timers = {}

local timer = require('timer')
m.timer = timer
timer.allowIterationsWithinFrame = true

local function removeTimerFromList(t)
    if not t then return end
    for i = #m.timers, 1, -1 do
        if m.timers[i] == t then
            table.remove(m.timers, i)
            break
        end
    end
end

m.cancelAll = function ()
    timer.cancelAll()
    m.timers = {}
end

m.cancel = function (t)
    if t then
        pcall(timer.cancel, t)
        removeTimerFromList(t)
    end
end

m.start = function (p, object)
    local t
    local listener
    listener = function ()
        if object and object.x then
            local s, e = coroutine.resume(p)
            if (not s) or e then
                m.cancel(t)
            end
        else
            m.cancel(t)
        end
    end
    t = timer.performWithDelay(0, listener, 0)
    table.insert(m.timers, t)
    return listener, t
end

return m