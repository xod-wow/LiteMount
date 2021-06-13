--[[----------------------------------------------------------------------------

  LiteMount/TableUtil.lua

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

function LM.tMap(t, f)
    local out = {}
    for k, v in pairs(t) do
        out[k] = f(v)
    end
    return out
end

function LM.tSlice(t, from, to)
    return { unpack(t, from, to) }
end
