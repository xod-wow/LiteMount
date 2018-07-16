--[[----------------------------------------------------------------------------

  LiteMount/Actions.lua

  Mounting actions.

  Copyright 2011-2018 Mike Battersby

----------------------------------------------------------------------------]]--

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local function ReplaceVars(list)
    local out = {}
    for _,l in ipairs(list) do
        l = LM_Vars:StrSubVars(l)
        tinsert(out, l)
    end
    return out
end

local ACTIONS = { }

ACTIONS['Spell'] =
    function (spellID)
        local name = GetSpellInfo(spellID)
        LM_Debug("Setting action to " .. name .. ".")
        return LM_SecureAction:Spell(name)
    end

-- In vehicle -> exit it
ACTIONS['LeaveVehicle'] =
    function ()
        --[[
        if UnitOnTaxi("player") then
            LM_Debug("Setting action to TaxiRequestEarlyLanding.")
            return LM_SecureAction:Click(MainMenuBarVehicleLeaveButton)
        elseif CanExitVehicle() then
        ]]
        if CanExitVehicle() then
            LM_Debug("Setting action to VehicleExit.")
            return LM_SecureAction:Macro(SLASH_LEAVEVEHICLE1)
        end
    end

-- Mounted -> dismount
ACTIONS['Dismount'] =
    function ()
        if not IsMounted() then return end

        LM_Debug("Setting action to Dismount.")
        return LM_SecureAction:Macro(SLASH_DISMOUNT1)
    end

-- Only cancel forms that we will activate (mount-style ones).
-- See: https://wow.gamepedia.com/API_GetShapeshiftFormID
-- Form IDs that you put here must be cancelled automatically on
-- mounting.

local savedFormName
local restoreFormIDs = {
    [1] = true,     -- Cat Form
    [5] = true,     -- Bear Form
    [31] = true,    -- Moonkin Form
}

-- This is really two actions in one but I didn't want people to have to
-- modify their custom action lists. It should really be CancelForm and
-- SaveForm separately, although then they need to be in that exact order so
-- maybe having them together is better after all.
--
-- Half of the reason this is so complicated is that you can mount up in
-- Moonkin form (but casting Moonkin form dismounts you).

ACTIONS['CancelForm'] =
    function ()
        LM_Debug("Trying CancelForm")

        local curFormIndex = GetShapeshiftForm()
        local curFormID = GetShapeshiftFormID()
        local inMountForm = curFormIndex > 0 and LM_PlayerMounts:GetMountByShapeshiftForm(curFormIndex)

        LM_Debug("Previous form is " .. tostring(savedFormName))

        -- The logic here is really ugly.

        if inMountForm then
            if savedFormName then
                LM_Debug("Setting action to cancelform + " .. savedFormName)
                return LM_SecureAction:Macro(format("%s\n/cast %s", SLASH_CANCELFORM1, savedFormName))
            end
        elseif IsMounted() and curFormIndex == 0 then
            if savedFormName then
                LM_Debug("Setting action to dismount + " .. savedFormName)
                return LM_SecureAction:Macro(format("%s\n/cast %s", SLASH_DISMOUNT1, savedFormName))
            end
        elseif curFormID and restoreFormIDs[curFormID] then
            local spellID
            if _G.C_Map then
                spellID = select(4, GetShapeshiftFormInfo(curFormIndex))
            else
                spellID = select(5, GetShapeshiftFormInfo(curFormIndex))
            end
            local name = GetSpellInfo(spellID)
            LM_Debug("Saving current form " .. tostring(name) .. ".")
            savedFormName = name
        else
            LM_Debug("Clearing saved form.")
            savedFormName = nil
        end

        if inMountForm and not LM_Options:IsExcludedMount(inMountForm) then
            LM_Debug("Setting action to CancelForm.")
            return LM_SecureAction:Macro(SLASH_CANCELFORM1)
        end
    end

-- Got a player target, try copying their mount
ACTIONS['CopyTargetsMount'] =
    function ()
        if LM_Options.db.profile.copyTargetsMount and UnitIsPlayer("target") then
            LM_Debug("Trying to clone target's mount")
            return LM_PlayerMounts:GetMountFromUnitAura("target")
        end
    end

ACTIONS['SmartMount'] =
    function (usableMounts, filters)

        filters = ReplaceVars(filters)
        local filteredList = usableMounts:FilterSearch(unpack(filters))

        LM_Debug("Mount filtered list contains " .. #filteredList .. " mounts.")

        if next(filteredList) == nil then return end

        filteredList:Shuffle()

        local m

        if IsSubmerged() and not LM_Location:IsFloating() then
            LM_Debug("  Trying Swimming Mount")
            m = filteredList:FilterFind('SWIM')
            if m then return m end
        end

        if LM_Location:CanFly() then
            LM_Debug("  Trying Flying Mount")
            m = filteredList:FilterFind('FLY')
            if m then return m end
        end

        if LM_Location:IsFloating() then
            LM_Debug("  Trying Floating mount")
            m = filteredList:FilterFind('FLOAT')
            if m then return m end
        end

        LM_Debug("  Trying Running Mount")
        m = filteredList:FilterFind('RUN')
        if m then return m end

        LM_Debug("  Trying Walking Mount")
        m = filteredList:FilterFind('WALK')
        if m then return m end
    end

ACTIONS['Mount'] =
    function (usableMounts, filters)
        filters = ReplaceVars(filters)
        local filteredList = usableMounts:FilterSearch(unpack(filters))
        LM_Debug("Mount filtered list contains " .. #filteredList .. " mounts.")
        return filteredList:Random()
    end

ACTIONS['Macro'] =
    function ()
        if LM_Options.db.char.useUnavailableMacro then
            LM_Debug("Using custom macro.")
            return LM_SecureAction:Macro(LM_Options.db.char.unavailableMacro)
        end
    end

ACTIONS['CantMount'] =
    function ()
        -- This isn't a great message, but there isn't a better one that
        -- Blizzard have already localized. See FrameXML/GlobalStrings.lua.
        -- LM_Warning("You don't know any mounts you can use right now.")
        LM_Warning(SPELL_FAILED_NO_MOUNTS_ALLOWED)

        LM_Debug("Setting action to can't mount now.")
        return LM_SecureAction:Macro("")
    end

ACTIONS['Combat'] =
    function ()
        LM_Debug("Setting action to in-combat action.")

        if LM_Options.db.char.useCombatMacro then
            return LM_SecureAction:Macro(LM_Options.db.char.combatMacro)
        else
            return LM_SecureAction:Macro(LM_Actions:DefaultCombatMacro())
        end
    end

ACTIONS['Stop'] =
    function ()
        -- return true and set up to do nothing
        return LM_SecureAction:Macro("")
    end

_G.LM_Actions = { }

local function GetDruidMountForms()
    local forms = {}
    for i = 1,GetNumShapeshiftForms() do
        local spell = select(5, GetShapeshiftFormInfo(i))
        if spell == LM_SPELL.FLIGHT_FORM or spell == LM_SPELL.TRAVEL_FORM then
            tinsert(forms, i)
        end
    end
    return table.concat(forms, "/")
end

-- This is the macro that gets set as the default and will trigger if
-- we are in combat.  Don't put anything in here that isn't specifically
-- combat-only, because out of combat we've got proper code available.
-- Note that macros are limited to 255 chars, even inside a SecureActionButton.

function LM_Actions:DefaultCombatMacro()

    local mt = "/dismount [mounted]\n"

    local _, playerClass = UnitClass("player")

    if playerClass ==  "DRUID" then
        local forms = GetDruidMountForms()
        local mount = LM_PlayerMounts:GetMountBySpell(LM_SPELL.TRAVEL_FORM)
        if mount and not LM_Options:IsExcludedMount(mount) then
            mt = mt .. format("/cast [noform:%s] %s\n", forms, mount.name)
            mt = mt .. format("/cancelform [form:%s]\n", forms)
        end
    elseif playerClass == "SHAMAN" then
        local mount = LM_PlayerMounts:GetMountBySpell(LM_SPELL.GHOST_WOLF)
        if mount and not LM_Options:IsExcludedMount(mount) then
            local s = GetSpellInfo(LM_SPELL.GHOST_WOLF)
            mt = mt .. "/cast [noform] " .. s .. "\n"
            mt = mt .. "/cancelform [form]\n"
        end
    end

    mt = mt .. "/leavevehicle\n"

    return mt
end

function LM_Actions:GetHandler(action)
    return ACTIONS[action]
end
