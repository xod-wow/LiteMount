--[[----------------------------------------------------------------------------

  LiteMount/MountList.lua

  Class for a list of LM_Mount mounts.

----------------------------------------------------------------------------]]--

LM_MountList = { }
LM_MountList.__index = LM_MountList

function LM_MountList:New(ml)
    local ml = ml or { }
    setmetatable(ml, LM_MountList)
    return ml
end

function LM_MountList:Search(matchfunc)
    local result = LM_MountList:New()

    for m in self:Iterate() do
        if matchfunc(m) then
            table.insert(result, m)
        end
    end

    return result
end

function LM_MountList:Shuffle()
    -- Shuffle, http://forums.wowace.com/showthread.php?t=16628
    for i = #self, 2, -1 do
        local r = math.random(i)
        self[i], self[r] = self[r], self[i]
    end
end

function LM_MountList:Random()
    local i = math.random(#self)
    return self[i]
end

function LM_MountList:Iterate()
    local i = 0
    local iter = function ()
            i = i + 1
            return self[i]
        end
    return iter
end

function LM_MountList:Sort()
    table.sort(self, function(a,b) return a:Name() < b:Name() end)
end

function LM_MountList:Map(mapfunc)
    for m in self:Iterate() do
        mapfunc(m)
    end
end

