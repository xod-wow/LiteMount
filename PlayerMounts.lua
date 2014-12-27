--[[----------------------------------------------------------------------------

  LiteMount/PlayerMounts.lua

  Information on all your mounts.

  Copyright 2011-2014 Mike Battersby

----------------------------------------------------------------------------]]--

-- We sub-tables so we can wipe() them without losing the methods.
LM_PlayerMounts = {
    ["byName"] = { },
    ["list"] = LM_MountList:New(),
}

function LM_PlayerMounts:Initialize()
    table.wipe(self.byName)
    table.wipe(self.list)
end

function LM_PlayerMounts:AddMount(m)
    if m and not self.byName[m.name] then
        self.byName[m.name] = m
        table.insert(self.list, m)
    end
end

function LM_PlayerMounts:AddCompanionMounts()
    for i = 1,C_MountJournal.GetNumMounts() do
        local m = LM_MountJournal:Get(i)
        self:AddMount(m)
    end
end

function LM_PlayerMounts:AddSpellMountsTable(t)
    for _,spellId in ipairs(t) do
        local m
        if spellId == LM_SPELL_TRAVEL_FORM then
            m = LM_TravelForm:Get()
        else
            m = LM_Spell:Get(spellId)
        end
        self:AddMount(m)
    end
end

function LM_PlayerMounts:AddSpellMounts()
    self:AddSpellMountsTable(LM_CLASS_MOUNT_SPELLS)
    self:AddSpellMountsTable(LM_RACIAL_MOUNT_SPELLS)
    self:AddSpellMountsTable(LM_ZONE_MOUNT_SPELLS)
end

function LM_PlayerMounts:AddItemMounts()
    for itemid,spellid in pairs(LM_ITEM_MOUNT_ITEMS) do
        local m = LM_ItemSummoned:Get(itemid, spellid)
        self:AddMount(m)
    end
end

function LM_PlayerMounts:ScanMounts()

    table.wipe(self.byName)
    table.wipe(self.list)

    self:AddCompanionMounts()
    self:AddSpellMounts()
    self:AddItemMounts()

    self.list:Sort()
end

function LM_PlayerMounts:Search(matchfunc)
    return self.list:Search(matchfunc)
end

function LM_PlayerMounts:GetAllMounts()
    local function match() return true end
    return self:Search(match)
end

function LM_PlayerMounts:GetAvailableMounts(flags)
    local function match(m)
        if not m:FlagsSet(flags) then return end
        if not m:IsUsable(flags) then return end
        if m:IsExcluded() then return end
        return true
    end

    return self:Search(match)
end

function LM_PlayerMounts:GetMountFromUnitAura(unitid, flags)
    -- Note that UnitIsPlayer tests if the unit is player-controlled
    if not UnitIsPlayer(unitid) or UnitIsUnit(unitid, "player") then
        return
    end

    for i = 1,BUFF_MAX_DISPLAY do
        local m = self:GetMountByName(UnitAura(unitid, i))
        if m and m:IsUsable(flags) then return m end
    end
end

function LM_PlayerMounts:GetMountByName(name)
    return self.byName[name]
end

function LM_PlayerMounts:GetMountBySpell(id)
    local name = GetSpellInfo(id)
    if name then return self:GetMountByName(name) end
end

function LM_PlayerMounts:GetMountByShapeshiftForm(i)
    if not i then return end
    local name = select(2, GetShapeshiftFormInfo(i))
    if name then return self:GetMountByName(name) end
end

function LM_PlayerMounts:GetRandomMount(flags)
    local poss = self:GetAvailableMounts(flags)
    return poss:Random()
end

function LM_PlayerMounts:GetFlyingMount()
    return self:GetRandomMount(LM_FLAG_BIT_FLY)
end

function LM_PlayerMounts:GetWalkingMount()
    return self:GetRandomMount(LM_FLAG_BIT_WALK)
end

function LM_PlayerMounts:GetRunningMount()
    return self:GetRandomMount(LM_FLAG_BIT_RUN)
end

function LM_PlayerMounts:GetAQMount()
    return self:GetRandomMount(LM_FLAG_BIT_AQ)
end

function LM_PlayerMounts:GetVashjirMount()
    return self:GetRandomMount(LM_FLAG_BIT_VASHJIR)
end

function LM_PlayerMounts:GetNagrandMount()
    return self:GetRandomMount(LM_FLAG_BIT_NAGRAND)
end

function LM_PlayerMounts:GetSwimmingMount()
    return self:GetRandomMount(LM_FLAG_BIT_SWIM)
end

function LM_PlayerMounts:Dump()
    for m in self.list:Iterate() do
        m:Dump()
    end
end
