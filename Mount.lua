--[[----------------------------------------------------------------------------

  LiteMount/Mount.lua

  Information about one mount.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

LM_Mount = {
    ["cacheByItemID"] = { },
    ["cacheByName"]   = { },
    ["cacheBySpellID"] = { },
}
LM_Mount.__index = LM_Mount

function LM_Mount:new()
    return setmetatable({ tags = { } }, LM_Mount)
end

function LM_Mount:Get(className, ...)
    local class = _G["LM_"..className]

    local m = class:Get(...)
    if not m then return end

    return m
end

function LM_Mount:CurrentFlags()
    return LM_Options:ApplyMountFlags(self)
end

-- This is a bit of a convenience since bit.isset doesn't exist
function LM_Mount:CurrentFlagsSet(f)
    return bit.band(self:CurrentFlags(), f) == f
end

local function PlayerIsMovingOrFalling()
    return (GetUnitSpeed("player") > 0 or IsFalling())
end

function LM_Mount:IsUsable()
    if PlayerIsMovingOrFalling() and self.castTime > 0 then return false end
    return true
end

function LM_Mount:SetupActionButton(button)
    button:SetAttribute("type", "spell")
    button:SetAttribute("spell", self.spellName)
end

function LM_Mount:Dump(prefix)
    if prefix == nil then
        prefix = ""
    end

    local function yesno(t) if t then return "yes" else return "no" end end

    LM_Print(prefix .. self.name)
    LM_Print(prefix .. " spell: " .. format("%s (id %d)", self.spellName, self.spellID))
    LM_Print(prefix .. " casttime: " .. self.castTime)
    LM_Print(prefix .. " flags: " .. format("%02x (default %02x)", self:CurrentFlags(), self.flags))
    LM_Print(prefix .. " excluded: " .. yesno(LM_Options:IsExcludedMount(self)))
    LM_Print(prefix .. " usable: " .. yesno(self:IsUsable()) .. " (spell " .. yesno(IsUsableSpell(self.spellID)) .. ")")
end
