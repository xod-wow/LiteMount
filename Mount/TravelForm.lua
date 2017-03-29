--[[----------------------------------------------------------------------------

  LiteMount/LM_TravelForm.lua

  It also updates whether it can run or not depending on Glyph of Travel.

  Also IsUsableSpell doesn't work right on it.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

LM_TravelForm = setmetatable({ }, LM_Spell)
LM_TravelForm.__index = LM_TravelForm

local travelFormFlags = { LM_FLAG.RUN, LM_FLAG.FLY, LM_FLAG.SWIM }

function LM_TravelForm:Get()
    local m = LM_Spell:Get(LM_SPELL.TRAVEL_FORM)
    if m then
        setmetatable(m, LM_TravelForm)
        wipe(m.flags)
        for _, f in ipairs(travelFormFlags) do m.flags[f] = true end
    end
    return m
end

-- IsUsableSpell doesn't return false for Travel Form indoors like it should,
-- because you can swim indoors with it (apparently).
function LM_TravelForm:IsUsable()
    if IsIndoors() and not IsSubmerged() then return false end
    return LM_Spell.IsUsable(self)
end
