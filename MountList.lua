--[[----------------------------------------------------------------------------

  LiteMount/MountList.lua

  Information on all your mounts.

----------------------------------------------------------------------------]]--

LM_MountList = { }

function LM_MountList:Initialize()
    self.byname = { }
end

function LM_MountList:AddCompanionMounts()
    for i = 1,GetNumCompanions("MOUNT") do
        local m = LM_Mount:GetMountByIndex(i)
        if m then
            self.byname[m.name] = m
        end
    end
end

function LM_MountList:AddRacialMounts()
    for _,spellid in ipairs(LM_RACIAL_MOUNT_SPELLS) do
        if LM_MountSpell:IsKnown(spellid) then
            local m = LM_Mount:GetMountBySpell(spellid)
            if m then
                self.byname[m.name] = m
            end
        end
    end
end

function LM_MountList:AddClassMounts()
    for _,spellid in ipairs(LM_CLASS_MOUNT_SPELLS) do
        if LM_MountSpell:IsKnown(spellid) then
            local m = LM_Mount:GetMountBySpell(spellid)
            if m then
                self.byname[m.name] = m
            end
        end
    end
end

function LM_MountList:AddItemMounts()
    for _,itemid in ipairs(LM_ITEM_MOUNT_ITEMS) do
        if LM_MountItem:HasItem(itemid) then
            local m = LM_Mount:GetMountByItem(itemid)
            if m then
                self.byname[m.name] = m
            end
        end
    end
end

function LM_MountList:ScanMounts()

    table.wipe(self.byname)

    self:AddCompanionMounts()
    self:AddRacialMounts()
    self:AddClassMounts()
    self:AddItemMounts()

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
    for i = #match, 1, -1 do
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

    for i = #poss, 1, -1 do
        if LM_Options:IsExcludedSpell(poss[i]:SpellId()) then
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
