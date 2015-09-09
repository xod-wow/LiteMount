--[[----------------------------------------------------------------------------

  LiteMount/Mount.lua

  Information about one mount.

  Copyright 2011-2015 Mike Battersby

----------------------------------------------------------------------------]]--

LM_Mount = {
    ["cacheByItemId"] = { },
    ["cacheByName"]   = { },
    ["cacheBySpellId"] = { }
}
LM_Mount.__index = LM_Mount

function LM_Mount:new()
    return setmetatable({ }, LM_Mount)
end

function LM_Mount:SetRequirements()
    local spellId = self:SpellId()
    self:NeedsProfession(LM_PROFESSION_MOUNT_REQUIREMENTS[spellId])
end

function LM_Mount:Get(className, ...)
    local class = _G["LM_"..className]

    local m = class:Get(...)
    if not m then return end

    m:SetRequirements()
    return m
end

function LM_Mount:SpellId(v)
    if v then self.spellId = v end
    return self.spellId
end

function LM_Mount:ItemId(v)
    if v then self.itemId = v end
    return self.itemId
end

function LM_Mount:ModelId(v)
    if v then self.modelId = v end
    return self.modelId
end

function LM_Mount:SelfMount(v)
    if v then self.isSelfMount = v end
    return self.isSelfMount
end

function LM_Mount:Type(v)
    if v then self.mountType = v end
    return self.mountType
end

function LM_Mount:SpellName(v)
    if v then self.spellName = v end
    return self.spellName
end

function LM_Mount:Icon(v)
    if v then self.icon = v end
    return self.icon
end

function LM_Mount:Name(v)
    if v then self.name = v end
    return self.name
end

function LM_Mount:NeedsFaction(v)
    if v then self.needsFaction = v end
    return self.needsFaction
end

function LM_Mount:NeedsProfession(v)
    if v then self.needsProfession = v end
    return self.needsProfession
end

function LM_Mount:JournalIndex(v)
    if v then self.journalIndex = v end
    return self.journalIndex
end

function LM_Mount:DefaultFlags(v)
    if v then self.flags = v end
    return self.flags
end

function LM_Mount:Flags()
    return LM_Options:ApplyMountFlags(self)
end

function LM_Mount:CanFly()
    return self:FlagsSet(LM_FLAG_BIT_FLY)
end

function LM_Mount:CanRun()
    return self:FlagsSet(LM_FLAG_BIT_RUN)
end

function LM_Mount:CanWalk()
    return self:FlagsSet(LM_FLAG_BIT_WALK)
end

function LM_Mount:CanFloat()
    return self:FlagsSet(LM_FLAG_BIT_FLOAT)
end

function LM_Mount:CanSwim()
    return self:FlagsSet(LM_FLAG_BIT_SWIM)
end

function LM_Mount:CastTime()
    return self.castTime
end

-- This is a bit of a convenience since bit.isset doesn't exist
function LM_Mount:FlagsSet(f)
    return bit.band(self:Flags(), f) == f
end

function LM_Mount:DefaultFlagsSet(f)
    return bit.band(self:DefaultFlags(), f) == f
end

local IceFloesSpellName

local function PlayerHasIceFloes()
    if not IceFloesSpellName then
        IceFloesSpellName = GetSpellInfo(108839)
    end
    return UnitAura("player", IceFloesSpellName)
end

local function PlayerIsMovingOrFalling()
    return (GetUnitSpeed("player") > 0 or IsFalling())
end

local function KnowProfessionSkillLine(needSkillLine, needRank)
    for _,i in ipairs({ GetProfessions() }) do
        if i then
            local _, _, rank, _, _, _, sl = GetProfessionInfo(i)
            if sl == needSkillLine and rank >= needRank then
                return true
            end
        end
    end
    return false
end

function LM_Mount:IsUsable(flags)

    if PlayerIsMovingOrFalling() then
        if self:CastTime() > 0 then return end
    end

    local faction = self:NeedsFaction()
    local pFaction = UnitFactionGroup("player")
    if faction and faction ~= pFaction then
        return false
    end

    local prof = self:NeedsProfession()
    if prof and not KnowProfessionSkillLine(unpack(prof)) then
        return false
    end

    return true
end

function LM_Mount:IsExcluded()
    return LM_Options:IsExcludedMount(self)
end

function LM_Mount:SetupActionButton(button)
    LM_Debug("LM_Mount setting button to spell "..self.spellName)
    button:SetAttribute("type", "spell")
    button:SetAttribute("spell", self.spellName)
end

function LM_Mount:Dump(prefix)
    if prefix == nil then
        prefix = ""
    end

    local function yesno(t) if t then return "yes" else return "no" end end

    LM_Print(prefix .. self:Name())
    LM_Print(prefix .. " spell: " .. format("%s (id %d)", self:SpellName(), self:SpellId()))
    LM_Print(prefix .. " casttime: " .. self:CastTime())
    LM_Print(prefix .. " flags: " .. format("%02x (default %02x)", self:Flags(), self:DefaultFlags()))
    LM_Print(prefix .. " excluded: " .. yesno(self:IsExcluded()))
    LM_Print(prefix .. " usable: " .. yesno(self:IsUsable()) .. " (spell " .. yesno(IsUsableSpell(self:SpellId())) .. ")")
end
