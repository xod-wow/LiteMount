--[[----------------------------------------------------------------------------

  LiteMount/LM_TravelForm.lua

  Travel Form is the biggest pain in the butt ever invented.  Blizzard
  change how it works, how fast it is, how many spells it is, and almost
  every other aspect of it ALL THE DAMN TIME.

  LEAVE TRAVEL FORM ALONE!

  Also IsSpellUsable doesn't work right on it.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

LM.TravelForm = setmetatable({ }, LM.Spell)
LM.TravelForm.__index = LM.TravelForm

local TravelFormDisplayID = {
    40816,                          -- Night Elf/Worgen
    45339,                          -- Tauren/Troll
    81440,                          -- Hightmountain Tauren
    87427, 87428, 87429, 87430,     -- Kul Tiran
    82130,                          -- Zandalari Troll
}

local FlightFormDisplayID = {
    38022,                          -- Night Elf
    38251,                          -- Tauren/Troll
    81439,                          -- Hightmountain Tauren
    88351, 83352, 83353, 83354,     -- Kul Tiran
    91214,                          -- Zandalari Troll
    37729,                          -- Worgen
    74304, 74305, 74306, 74307,     -- The owl thing
}

local AquaticFormDisplayID = {
    2428,                           -- Base sea lion
    87879, 87880, 87881, 87882,     -- Kul Tiran
    88747, 88748, 88749, 88750,     -- Zandalari Troll
}

local AllFormDisplayID = {
    unpack(TravelFormDisplayID),
    unpack(FlightFormDisplayID),
    unpack(AquaticFormDisplayID)
}

function LM.TravelForm:Get(...)
    local m = LM.Spell.Get(self, ...)
    local _, race = UnitRace('player')
    if WOW_PROJECT_ID == 1 then
        if m.spellID == LM.SPELL.MOUNT_FORM then
            m.creatureDisplayID = TravelFormDisplayID
        else
            m.creatureDisplayID = AllFormDisplayID
        end
    else
        if m.spellID == LM.SPELL.FLIGHT_FORM_CLASSIC then
            m.creatureDisplayID = { FlightFormDisplayID[1], FlightFormDisplayID[2] }
        elseif m.spellID == LM.SPELL.SWIFT_FLIGHT_FORM_CLASSIC then
            m.creatureDisplayID = { FlightFormDisplayID[1], FlightFormDisplayID[2] }
        elseif m.spellID == LM.SPELL.AQUATIC_FORM_CLASSIC then
            m.creatureDisplayID = { AquaticFormDisplayID[1] }
        else
            m.creatureDisplayID = { TravelFormDisplayID[1], TravelFormDisplayID[2] }
        end
    end
    return m
end

-- Druid forms don't reliably have a corresponding player buff, so we need
-- to check the spell from GetShapeshiftFormInfo.
function LM.TravelForm:IsActive(buffTable)
    local id = GetShapeshiftForm()
    if id > 0 then
        return select(4, GetShapeshiftFormInfo(id)) == self.spellID
    end
end

-- In Wrath Classic, you can't fly in Dalaran except in Krasus Landing near
-- the flight master. Normal flying mounts detect this correctly but the
-- flight forms do not.
--
-- As far as I can tell there's no way to tell (that's locale-independent).
-- There's no visible buff, IsFlyablArea() is true and Flight Form is not
-- greyed out. Other flying mounts ARE flagged as unusable but only ones you
-- know ever become usable so it's not reliable.
--
-- So, here's a huge hack that figures out approxiately if you are in the
-- right area or not.

local KrasusLandingCenter = CreateVector2D(0.727, 0.456)
local DalaranDenySpells = { LM.SPELL.FLIGHT_FORM_CLASSIC, LM.SPELL.SWIFT_FLIGHT_FORM_CLASSIC }

function LM.TravelForm:IsAreaDenied()
    if LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_CATACLYSM then
        if not tContains(DalaranDenySpells, self.spellID) then return false end

        local map = C_Map.GetBestMapForUnit('player')
        if map ~= 125 then return false end

        local pos = C_Map.GetPlayerMapPosition(map, 'player')
        if not pos then return false end

        pos:Subtract(KrasusLandingCenter)
        if pos:GetLengthSquared() < 0.0064 then return false end

        return true
    end
    return false
end

local RetailMountLikeForms = {
    [LM.SPELL.TRAVEL_FORM] = true,
    [LM.SPELL.MOUNT_FORM] = true,
}

-- IsSpellUsable doesn't return false for Travel Form indoors like it should,
-- because you can swim indoors with it (apparently).
function LM.TravelForm:IsCastable()
    -- if self:IsAreaDenied() then return false end
    if IsIndoors() and not IsSubmerged() then return false end
    local formIndex = GetShapeshiftForm()
    if formIndex and formIndex > 0 then
        -- Casting a form when you are already in it acts as a cancel, which we
        -- consider to be "not castable" for this purpose.
        local formSpellID = select(4, GetShapeshiftFormInfo(formIndex))
        if formSpellID == self.spellID then
            return false
        end
        -- Additionally, in retail, casting mount form while in travel form and
        -- vice-versa cancels the form (does not switch to the other directly).
        if WOW_PROJECT_ID == 1 then
            -- Since there are only two forms, shortcut instead of cross-testing.
            if RetailMountLikeForms[formSpellID] then
                return false
            end
        end
    end
    return LM.Spell.IsCastable(self)
end

local ClassicFlightForms = {
    [LM.SPELL.FLIGHT_FORM_CLASSIC] = true,
    [LM.SPELL.SWIFT_FLIGHT_FORM_CLASSIC] = true,
}

function LM.TravelForm:IsCancelable()
    if WOW_PROJECT_ID ~= 1 then
        -- In classic where the forms differ, don't cancel the form you are in
        -- before going to a new one, just go straight to it.
        if IsSubmerged() and self.spellID ~= LM.SPELL.AQUATIC_FORM_CLASSIC then
            return false
        elseif IsFalling() and not ClassicFlightForms[self.spellID] then
            return false
        end
    end
    return LM.Spell.IsCancelable(self)
end

function LM.TravelForm:GetCancelAction()
    -- Is there any good reason to use /cancelform instead?
    return LM.SecureAction:CancelAura(self.name)
end

function LM.TravelForm:IsHidden()
    return not IsPlayerSpell(self.spellID)
end
