--[[----------------------------------------------------------------------------

  LiteMount/Util.lua

  Utility functions.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

function LM_tSlice(t, first, last)
    local out = { }
    for i = first or 1, last or #t do
        tinsert(out, t[i])
    end
    return out
end

function LM_tKeys(t)
    local out = { }
    for k in pairs(t) do tinsert(out, k) end
    return out
end
    
function LM_tPairsBySort(t, sortFunction)
    local index = LM_tKeys(t)
    sort(index, sortFunction)

    local i = 0
    return function ()
            i = i + 1
            if index[i] == nil then return nil end
            return index[i], t[index[i]]
        end
end

function LM_tPairsByKeys(t)
    return LM_tPairsBySort(t)
end

function LM_tPairsByValues(t)
    return LM_tPairsBySort(t, function (a, b) return t[a] < t[b] end)
end


