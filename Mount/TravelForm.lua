--[[----------------------------------------------------------------------------

  LiteMount/LM_TravelForm.lua

  Travel Form has to update its fly/don't fly status depending on whether
  you have Glyph of the Stag or not.

  It also updates whether it can run or not depending on Glyph of Travel.

  Also IsUsableSpell doesn't work right on it.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

LM_TravelForm = setmetatable({ }, LM_Spell)
LM_TravelForm.__index = LM_TravelForm

-- This is absolutely rubbish
local RIDING_SKILL_SPELLS = { 33388, 33391, 34090, 34091, 90265 }

local function PlayerKnowsRiding()
    for _,id in ipairs(RIDING_SKILL_SPELLS) do
        if IsSpellKnown(id) then return true end
    end
    return false
end

local travelFormFlags = bit.bor(LM_FLAG_BIT_FLY, LM_FLAG_BIT_SWIM)

function LM_TravelForm:Flags(v)
    if not PlayerKnowsRiding() then
        return bit.bor(travelFormFlags, LM_FLAG_BIT_WALK)
    else
        return travelFormFlags
    end
end

function LM_TravelForm:Get()
    local m = LM_Spell:Get(LM_SPELL_TRAVEL_FORM)
    if m then setmetatable(m, LM_TravelForm) end
    return m
end

-- IsUsableSpell doesn't return false for Travel Form indoors like it should,
-- because you can swim indoors with it (apparently).
function LM_TravelForm:IsUsable()
    if IsIndoors() and not IsSubmerged() then return false end
    return LM_Spell.IsUsable(self)
end
