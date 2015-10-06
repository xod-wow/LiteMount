--[[----------------------------------------------------------------------------

  LiteMount/PlayerMounts.lua

  Information on all your mounts.

  Copyright 2011-2015 Mike Battersby

----------------------------------------------------------------------------]]--

-- We sub-tables so we can wipe() them without losing the methods.
LM_PlayerMounts = {
    ["byName"] = { },
    ["list"] = LM_MountList:New(),
}

function LM_PlayerMounts:Initialize()
    wipe(self.byName)
    wipe(self.list)
end

function LM_PlayerMounts:AddMount(m)
    if m and not self.byName[m:Name()] then
        self.byName[m:Name()] = m
        tinsert(self.list, m)
    end
end

function LM_PlayerMounts:AddJournalMounts()
    for i = 1,C_MountJournal.GetNumMounts() do
        local m = LM_Mount:Get("Journal", i)
        self:AddMount(m)
    end
end

-- The unpack function turns a table into a list. I.e.,
--      unpack({ a, b, c }) == a, b, c
function LM_PlayerMounts:AddSpellMounts()
    for _,typeAndArgs in ipairs(LM_MOUNT_SPELLS) do
        local m = LM_Mount:Get(unpack(typeAndArgs))
        self:AddMount(m)
    end
end

function LM_PlayerMounts:ScanMounts()

    wipe(self.byName)
    wipe(self.list)

    self:AddJournalMounts()
    self:AddSpellMounts()

    for m in self.list:Iterate() do
        LM_Options:SeenMount(m, true)
    end

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
        if not m:CurrentFlagsSet(flags) then return end
        if not m:IsUsable() then return end
        if m:IsExcluded() then return end
        return true
    end

    return self:Search(match)
end

function LM_PlayerMounts:GetMountFromUnitAura(unitid)
    for i = 1,BUFF_MAX_DISPLAY do
        local m = self:GetMountByName(UnitAura(unitid, i))
        if m and m:IsUsable() then return m end
    end
end

function LM_PlayerMounts:GetMountByName(name)
    return self.byName[name]
end

function LM_PlayerMounts:GetMountBySpell(id)
    local name = GetSpellInfo(id)
    if name then return self:GetMountByName(name) end
end

-- For some reason GetShapeshiftFormInfo doesn't work on Ghost Wolf.
function LM_PlayerMounts:GetMountByShapeshiftForm(i)
    if not i then return end
    local class = select(2, UnitClass("player"))
    if class == "SHAMAN" and i == 1 then
         return self:GetMountBySpell(LM_SPELL_GHOST_WOLF)
    end
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
