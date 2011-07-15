--[[----------------------------------------------------------------------------

  LiteMount/MountList.lua

  Information on all your mounts.

----------------------------------------------------------------------------]]--

LM_MountList = { }
LM_MountList.__index = LM_MountList

local function IterateCompanionMounts()
    local i = 0
    local max = GetNumCompanions("MOUNT")

    return function ()
            while i < max do
                i = i + 1
                return LM_Mount:GetMountByIndex(i)
            end
        end
end

local function IterateRacialMounts()
    local i = 0
    local max = table.getn(LM_RACIAL_MOUNT_SPELLS)

    return function ()
            while i < max do
                i = i + 1
                if LM_MountSpell:IsKnown(LM_RACIAL_MOUNT_SPELLS[i]) then
                    return LM_Mount:GetMountBySpell(LM_RACIAL_MOUNT_SPELLS[i])
                end
            end
        end
end

local function IterateClassMounts()
    local i = 0
    local max = table.getn(LM_CLASS_MOUNT_SPELLS)

    return function ()
            while i < max do
                i = i + 1
                if LM_MountSpell:IsKnown(LM_CLASS_MOUNT_SPELLS[i]) then
                    return LM_Mount:GetMountBySpell(LM_CLASS_MOUNT_SPELLS[i])
                end
            end
        end
    
end

function LM_MountList:new()
    local ml = setmetatable({ }, LM_MountList)
    ml.byname = { }
    ml.excludedSpellIds = { }
    return ml
end

function LM_MountList:ScanMounts()

    table.wipe(self.byname)

    for m in IterateCompanionMounts() do
        self.byname[m.name] = m
    end
        
    for m in IterateRacialMounts() do
        self.byname[m.name] = m
    end
        
    for m in IterateClassMounts() do
        self.byname[m.name] = m
    end

end

function LM_MountList:SetExcludedSpellIds(spelllist)
    table.wipe(self.excludedSpellIds)
    for _,s in ipairs(spelllist) do
        table.insert(self.excludedSpellIds, s)
    end
end

function LM_MountList:IsExcludedSpellId(id)
    for _,s in ipairs(self.excludedSpellIds) do
        if s == id then return true end
    end
end

function LM_MountList:GetMounts(flags)
    local match = { }

    if not flags then flags = 0 end

    for _, m in pairs(self.byname) do
        if bit.band(m:Flags(), flags) == flags then
            table.insert(match, m)
        end
    end

    return match
end

function LM_MountList:GetUsableMounts(flags)
    local match = self:GetMounts(flags)
    for i = 1, #match do
        if not match[i]:Usable() then
            table.remove(match, i)
        end
    end
    return match
end

function LM_MountList:GetRandomUsableMount(flags)

    if GetUnitSpeed("player") > 0 or IsFalling() then
        flags = bit.bor(flags, LM_FLAG_BIT_MOVING)
    end

    local poss = self:GetUsableMounts(flags)

    for i = 1, #poss do
        if self:IsExcludedSpellId(poss[i]:SpellId()) then
            table.remove(poss, i)
        end
    end

    -- Shuffle, http://forums.wowace.com/showthread.php?t=16628
    for i = #poss, 2, -1 do
        local r = math.random(i)
        poss[i], poss[r] = poss[r], poss[i]
    end

    return poss[1]
end


function LM_MountList:GetFlyingMounts()
    return self:GetMounts(LM_FLAG_BIT_FLY)
end

function LM_MountList:GetRandomFlyingMount()
    return self:GetRandomUsableMount(LM_FLAG_BIT_FLY)
end

function LM_MountList:GetSlowWalkingMounts()
    return self:GetMounts(LM_FLAG_BIT_SLOWWALK)
end

function LM_MountList:GetRandomSlowWalkingMount()
    return self:GetRandomUsableMount(LM_FLAG_BIT_SLOWWALK)
end

function LM_MountList:GetWalkingMounts()
    return self:GetMounts(LM_FLAG_BIT_WALK)
end

function LM_MountList:GetRandomWalkingMount()
    return self:GetRandomUsableMount(LM_FLAG_BIT_WALK)
end

function LM_MountList:GetAQMounts()
    return self:GetMounts(LM_FLAG_BIT_AQ)
end

function LM_MountList:GetRandomAQMount()
    return self:GetRandomUsableMount(LM_FLAG_BIT_AQ)
end

function LM_MountList:GetVashjirMounts()
    return self:GetMounts(LM_FLAG_BIT_VASHJIR)
end

function LM_MountList:GetRandomVashjirMount()
    return self:GetRandomUsableMount(LM_FLAG_BIT_VASHJIR)
end

function LM_MountList:GetSwimmingMounts()
    return self:GetMounts(LM_FLAG_BIT_SWIM)
end

function LM_MountList:GetRandomSwimmingMount()
    return self:GetRandomUsableMount(LM_FLAG_BIT_SWIM)
end

function LM_MountList:Dump()
    for _,m in pairs(self.byname) do
        m:Dump()
    end
end
