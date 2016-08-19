--[[----------------------------------------------------------------------------

  LiteMount/Action.lua

  Mounting actions.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

-- This wrapper class is so that LM_ActionButton can treat all of the returns
-- from action functions as if they were a Mount class.

local LM_ActionAsMount = { }
LM_ActionAsMount.__index = LM_ActionAsMount

function LM_ActionAsMount:New(attr)
    return setmetatable(attr, LM_ActionAsMount)
end

function LM_ActionAsMount:Macro(macrotext)
    return self:New( { ["type"] = "macro", ["macrotext"] = macrotext } )
end

function LM_ActionAsMount:RunMacro(macroname)
    return self:New( { ["type"] = "macro", ["macro"] = macroname } )
end

function LM_ActionAsMount:Spell(spellname)
    local attr = {
            ["type"] = "spell",
            ["unit"] = "player",
            ["spell"] = spellname
    }
    return self:New(attr)
end

function LM_ActionAsMount:SetupActionButton(button)
    for k,v in pairs(self) do
        button:SetAttribute(k, v)
    end
end

function LM_ActionAsMount:Name()
end


--[[------------------------------------------------------------------------]]--

local ACTIONS = { }

ACTIONS.Print =
    function (msg)
        LM_Print(msg)
        return false
    end

ACTIONS.Spell =
    function (spellID)
        local name = GetSpellInfo(spellID)
        LM_Debug("Setting action to Spell " .. name .. ".")
        return LM_ActionAsMount:Spell(name)
    end

ACTIONS.LeaveVehicle =
    function ()
        LM_Debug("Setting action to LeaveVehicle.")
        return LM_ActionAsMount:Macro(SLASH_LEAVEVEHICLE1)
    end

ACTIONS.Dismount =
    function ()
        LM_Debug("Setting action to Dismount.")
        return LM_ActionAsMount:Macro(SLASH_DISMOUNT1)
    end

ACTIONS.CancelMountForm =
    function ()
        -- Only want to cancel forms that we will activate (mount-style ones).
        -- See: http://wowprogramming.com/docs/api/GetShapeshiftFormID
        local formIndex = GetShapeshiftForm()
        if formIndex == 0 then return end

        local form = LM_PlayerMounts:GetMountByShapeshiftForm(formIndex)
        if not form or LM_Options:IsExcludedMount(form) then return end

        LM_Debug("Setting action to CancelMountForm.")
        return LM_ActionAsMount:Macro(SLASH_CANCELFORM1)
    end

-- Got a player target, try copying their mount
ACTIONS.CopyTargetsMount =
    function ()
        if not UnitIsPlayer("target") then return end
        if not LM_Options:CopyTargetsMount() then return end

        LM_Debug("Trying to clone target's mount")
        return LM_PlayerMounts:GetMountFromUnitAura("target")
    end

ACTIONS.Mount =
    function (tag)
        if tag == "fly" then
            return LM_PlayerMounts:GetRandomMount(LM_FLAG_BIT_FLY)
        elseif tag == "swim" then
            return LM_PlayerMounts:GetRandomMount(LM_FLAG_BIT_SWIM)
        elseif tag == "nagrand" then
            return LM_PlayerMounts:GetRandomMount(LM_FLAG_BIT_NAGRAND)
        elseif tag == "aq" then
            return LM_PlayerMounts:GetRandomMount(LM_FLAG_BIT_AQ)
        elseif tag == "vashjir" then
            return LM_PlayerMounts:GetRandomMount(LM_FLAG_BIT_VASHJIR)
        elseif tag == "run" then
            return LM_PlayerMounts:GetRandomMount(LM_FLAG_BIT_RUN)
        elseif tag == "walk" then
            return LM_PlayerMounts:GetRandomMount(LM_FLAG_BIT_WALK)
        elseif tag == "custom1" then
            return LM_PlayerMounts:GetRandomMount(LM_FLAG_BIT_CUSTOM1)
        elseif tag == "custom2" then
            return LM_PlayerMounts:GetRandomMount(LM_FLAG_BIT_CUSTOM2)
        end
    end

-- This will have to wait for a better parser that handles spaces
ACTIONS.Slash =
    function (cmd)
        return LM_ActionAsMount:Macro(cmd)
    end

ACTIONS.RunMacro =
    function (macroname)
        return LM_ActionAsMount:RunMacro(macroname)
    end

ACTIONS.UnvailableMacro =
    function ()
        if not LM_Options:UseMacro() then return end
        LM_Debug("Using custom macro.")
        return LM_ActionAsMount:Macro(LM_Options:GetMacro())
    end

ACTIONS.CantMount =
    function ()
        -- This isn't a great message, but there isn't a better one that
        -- Blizzard have already localized. See FrameXML/GlobalStrings.lua.
        -- LM_Warning("You don't know any mounts you can use right now.")
        LM_Warning(SPELL_FAILED_NO_MOUNTS_ALLOWED)

        LM_Debug("Setting action to can't mount now.")
        return LM_ActionAsMount:Macro("")
    end

ACTIONS.Combat = 
    function ()
        LM_Debug("Setting action to in-combat action.")

        if LM_Options:UseCombatMacro() then
            return LM_ActionAsMount:Macro(LM_Options:GetCombatMacro())
        else
            return LM_ActionAsMount:Macro(self:DefaultCombatMacro())
        end
    end



--[[------------------------------------------------------------------------]]--

LM_Actions = { }

local function GetDruidMountForms()
    local forms = {}
    for i = 1,GetNumShapeshiftForms() do
        local spell = select(5, GetShapeshiftFormInfo(i))
        if spell == LM_SPELL_FLIGHT_FORM or spell == LM_SPELL_TRAVEL_FORM then
            tinsert(forms, i)
        end
    end
    return forms
end

-- This is the macro that gets set as the default and will trigger if
-- we are in combat.  Don't put anything in here that isn't specifically
-- combat-only, because out of combat we've got proper code available.
-- Note that macros are limited to 255 chars, even inside a SecureActionButton.

function LM_Actions:DefaultCombatMacro()

    local mt = "/dismount [mounted]\n"

    local playerClass = select(2, UnitClass("player"))

    if playerClass ==  "DRUID" then
        local forms = table.concat(GetDruidMountForms(), "/")
        local mount = LM_PlayerMounts:GetMountBySpell(LM_SPELL_TRAVEL_FORM)
        if mount and not LM_Options:IsExcludedMount(mount) then
            mt = mt .. format("/cast [noform:%s] %s\n", forms, mount:Name())
            mt = mt .. format("/cancelform [form:%s]\n", forms)
        end
    elseif playerClass == "SHAMAN" then
        local mount = LM_PlayerMounts:GetMountBySpell(LM_SPELL_GHOST_WOLF)
        if mount and not LM_Options:IsExcludedMount(mount) then
            local s = GetSpellInfo(LM_SPELL_GHOST_WOLF)
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
