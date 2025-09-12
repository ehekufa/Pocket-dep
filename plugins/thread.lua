local m = {}
m.timers = {}

local timer = require('timer')
m.timer = timer
timer.allowInteratonsWithinFrame = true

m.cancelAll = function ()
    timer.cancelAll()
end

m.cancel = function (t)
    timer.cancel(t)
    t = nil
end

m.start = function (p, object)
    local t
    local listener
    listener = function ()
        if object and object.x then
            local s, e = coroutine.resume(p)
            if (not s) or e then
                timer.cancel(t)
            end
        else
            timer.cancel(t)
        end
    end
    t = timer.performWithDelay(0, listener, 0)
    table.insert(m.timers, t)
    return listener, t
end

return m