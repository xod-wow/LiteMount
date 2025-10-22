--[[----------------------------------------------------------------------------

  Macro per class

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

LM.Macro = { }

local M_CAST_S  = "/cast %s"
local M_COMBAT_S  = "/dismount [mounted]\n/stopmacro [mounted]\n/leavevehicle [unithasvehicleui]\n%s"

local function formatSpell(fmt, ...)
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

local DefaultMacroByClass = {
    DEATHKNIGHT = formatSpell(M_CAST_S, 218999),        -- Wraith Walk
    DEMONHUNTER = formatSpell(M_CAST_S, 192611),        -- Fel Rush
    DRUID       = formatSpell(M_CAST_S, 768),           -- Cat Form
    EVOKER      = formatSpell(M_CAST_S, 358267),        -- Hover
    HUNTER      = formatSpell(M_CAST_S, 186257),        -- Aspect of the Cheetah
    MAGE        = formatSpell(M_CAST_S, 1953),          -- Blink
    MONK        = formatSpell(M_CAST_S, 109132),        -- Roll
    PALADIN     = formatSpell(M_CAST_S, 190784),        -- Divine Steed
    PRIEST      = formatSpell("/cast [@player] %s\n", 121536),  -- Angelic Feather
    ROGUE       = formatSpell(M_CAST_S, 2983),          -- Sprint
    SHAMAN      = formatSpell(M_CAST_S, 2645),          -- Ghost Wolf
    WARLOCK     = formatSpell(M_CAST_S, 111400),        -- Burning Rush
    WARRIOR     = formatSpell("/cast [harm] %s; [@cursor] %s\n", 100, 6544), -- Charge, Heroic Leap
}

local function GetCombatMacroIndex(t, k)
    local text = DefaultMacroByClass[k]
    return text and string.format(M_COMBAT_S, text)
end

DefaultCombatMacroByClass = {
    DRUID       = string.format(M_COMBAT_S, formatSpell("/cast [indoors,noswimming] %s; %s\n", 768, 783)),
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
