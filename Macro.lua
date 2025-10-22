--[[----------------------------------------------------------------------------

  Macro per class

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

LM.Macro = { }

-- This is all poorly thought through but at least it's in one place.

local M_CAST_S  = "/cast %s"
local M_CAST_KNOWN_S  = "/cast [known:%1] %1"
local M_COMBAT_S  = "/dismount [mounted]\n/stopmacro [mounted]\n%s\n/leavevehicle"

local function formatSpells(fmt, ...)
    local args = { }
    for i = 1, select('#', ...) do
        local arg = select(i, ...)
        if type(arg) == 'number' then
            arg = C_Spell.GetSpellName(arg)
        end
        if arg then
            table.insert(args, arg)
        else
            return nil
        end
    end
    return string.format(fmt, unpack(args))
end

local function formatSpellMulti(fmt, ...)
    local out = {}
    for i = 1, select('#', ...) do
        local arg = select(i, ...)
        local name = C_Spell.GetSpellName(arg)
        if name then
            local line = fmt:gsub('%%1', name)
            table.insert(out, line)
        end
    end
    if next(out) then
        return table.concat(out, "\n")
    end
end

local DefaultMacroByClass = {
    DEATHKNIGHT =               -- Wraith Walk
        formatSpells(M_CAST_S, 218999),
    DEMONHUNTER =               -- Fel Rush
        formatSpells(M_CAST_S, 192611),
    DRUID =                     -- Cat Form
        formatSpells(M_CAST_S, 768),
    EVOKER =                    -- Hover
        formatSpells(M_CAST_S, 358267),
    HUNTER =                    -- Aspect of the Cheetah
        formatSpells(M_CAST_S, 186257),
    MAGE =                      -- Blink
        formatSpells(M_CAST_S, 1953),
    MONK =                      -- Roll
        formatSpells(M_CAST_S, 109132),
    PALADIN =                   -- Divine Steed
        formatSpells(M_CAST_S, 190784),
    PRIEST =                    -- Angelic Feather
        formatSpells("/cast [@player] %s\n", 121536),
    ROGUE =                     -- Sprint
        formatSpells(M_CAST_S, 2983),
    SHAMAN =                    -- Gust of Wind, Spirit Walk
        formatSpellMulti(M_CAST_KNOWN_S, 192063, 58875),
    WARLOCK =                   -- Burning Rush
        formatSpells(M_CAST_S, 111400),
    WARRIOR =                   -- Charge, Heroic Leap
        formatSpells("/cast [harm] %s; [@cursor] %s\n", 100, 6544),
}

local function GetCombatMacroIndex(t, k)
    local text = DefaultMacroByClass[k]
    return text and string.format(M_COMBAT_S, text)
end

local DefaultCombatMacroByClass = {
    DRUID =                     -- Travel Form since it can't be selected from mounts
        string.format(M_COMBAT_S, formatSpells("/cast [indoors,noswimming] %s; %s", 768, 783)),
    SHAMAN =                    -- Ghost Wolf
        string.format(M_COMBAT_S, formatSpells(M_CAST_S, 2645)),
}

setmetatable(DefaultCombatMacroByClass, { __index = GetCombatMacroIndex })

local function GetSettingsTable(class)
    if class == 'PLAYER' then
        return LM.db.char
    elseif class == UnitClassBase('player') then
        return LM.db.class
    else
        LM.db.sv.class = LM.db.sv.class or {}
        LM.db.sv.class[class] = LM.db.sv.class[class] or {}
        return LM.db.sv.class[class]
    end
end

function LM.Macro:GetMacroOptionDefault(isCombat, class)
    if isCombat then
        return DefaultCombatMacroByClass[class]
    else
        return DefaultMacroByClass[class]
    end
end

function LM.Macro:GetEnabledOptionDefault(isCombat, class)
    return false
end

function LM.Macro:GetMacroOption(isCombat, class)
    local sv = GetSettingsTable(class)
    if isCombat then
        return sv.combatMacro
    else
        return sv.unavailableMacro
    end
end

function LM.Macro:GetEnabledOption(isCombat, class)
    local sv = GetSettingsTable(class)
    if isCombat then
        return ValueToBoolean(sv.useCombatMacro)
    else
        return ValueToBoolean(sv.useUnavailableMacro)
    end
end

function LM.Macro:SetMacroOption(isCombat, class, text)
    local sv = GetSettingsTable(class)
    if isCombat then
        sv.combatMacro = text
    else
        sv.unavailableMacro = text
    end
    LM.Options:NotifyChanged()
end

function LM.Macro:SetEnabledOption(isCombat, class, v)
    local sv = GetSettingsTable(class)
    if isCombat then
        sv.useCombatMacro = ValueToBoolean(v)
    else
        sv.useUnavailableMacro = ValueToBoolean(v)
    end
    LM.Options:NotifyChanged()
end

function LM.Macro:GetMacro(isCombat)
    local class = UnitClassBase('player')
    if isCombat then
        local default = DefaultCombatMacroByClass[class]
        if LM.db.char.useCombatMacro then
            return LM.db.char.combatMacro or default
        end
        if LM.db.class.useCombatMacro then
            return LM.db.class.combatMacro or default
        end
    else
        local default = DefaultMacroByClass[class]
        if LM.db.char.useUnavailableMacro then
            return LM.db.char.unavailableMacro or default
        end
        if LM.db.class.useUnavailableMacro then
            return LM.db.class.unavailableMacro or default
        end
    end
end

local function GetDruidMountForms()
    local forms = {}
    for i = 1, GetNumShapeshiftForms() do
        local spell = select(4, GetShapeshiftFormInfo(i))
        if LM.MountRegistry:GetMountBySpell(spell) then
            tinsert(forms, i)
        end
    end
    return table.concat(forms, "/")
end

function LM.Macro:DefaultCombatMacro()
    local mt = "/dismount [mounted]\n/stopmacro [mounted]\n"

    local playerClass = UnitClassBase("player")

    if playerClass ==  "DRUID" then
        local forms = GetDruidMountForms()
        local mount = LM.MountRegistry:GetMountBySpell(LM.SPELL.TRAVEL_FORM)
        if mount and mount:GetPriority() > 0 then
            mt = mt .. string.format("/cast [noform:%s] %s\n", forms, mount.name)
            mt = mt .. string.format("/cancelform [form:%s]\n", forms)
        end
    elseif playerClass == "SHAMAN" then
        local mount = LM.MountRegistry:GetMountBySpell(LM.SPELL.GHOST_WOLF)
        if mount and mount:GetPriority() > 0 then
            local s = C_Spell.GetSpellName(LM.SPELL.GHOST_WOLF)
            mt = mt .. "/cast [noform] " .. s .. "\n"
            mt = mt .. "/cancelform [form]\n"
        end
    end

    mt = mt .. "/leavevehicle\n"

    return mt
end
