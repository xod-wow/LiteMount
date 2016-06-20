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

function LM_ActionAsMount:Name() end


--[[------------------------------------------------------------------------]]--

LM_Action = { }

local function GetDruidMountForms()
    local forms = {}
    for i = 1,GetNumShapeshiftForms() do
        local spell = select(5, GetShapeshiftFormInfo(i))
        if spell == LM_SPELL_FLIGHT_FORM or spell == LM_SPELL_TRAVEL_FORM then
            tinsert(forms, i)
        end
    end
    return table.concat(forms, "/")
end

-- This is the macro that gets set as the default and will trigger if
-- we are in combat.  Don't put anything in here that isn't specifically
-- combat-only, because out of combat we've got proper code available.
-- Note that macros are limited to 255 chars, even inside a SecureActionButton.

function LM_Action:DefaultCombatMacro()

    local mt = "/dismount [mounted]\n"

    local playerClass = select(2, UnitClass("player"))

    if playerClass ==  "DRUID" then
        local forms = GetDruidMountForms()
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

function LM_Action:Spell(spellID)
    local name = GetSpellInfo(spellID)
    LM_Debug("Setting action to " .. name .. ".")
    return LM_ActionAsMount:Spell(name)
end

function LM_Action:Zone(zoneID)
    if not LM_Location:IsZone(zoneID) then return end

    LM_Debug(format("Trying zone mount for %s (%d).", LM_Location:GetName(), LM_Location:GetID()))
    return LM_PlayerMounts:GetZoneMount(zoneID)
end

-- In vehicle -> exit it
function LM_Action:LeaveVehicle()
    if not CanExitVehicle() then return end

    LM_Debug("Setting action to VehicleExit.")
    return LM_ActionAsMount:Macro(SLASH_LEAVEVEHICLE1)
end

-- Mounted -> dismount
function LM_Action:Dismount()
    if not IsMounted() then return end

    LM_Debug("Setting action to Dismount.")
    return LM_ActionAsMount:Macro(SLASH_DISMOUNT1)
end

function LM_Action:CancelForm()
    -- We only want to cancel forms that we will activate (mount-style ones).
    -- See: http://wowprogramming.com/docs/api/GetShapeshiftFormID
    local formIndex = GetShapeshiftForm()
    if formIndex == 0 then return end

    local form = LM_PlayerMounts:GetMountByShapeshiftForm(formIndex)
    if not form or LM_Options:IsExcludedMount(form) then return end

    LM_Debug("Setting action to CancelForm.")
    return LM_ActionAsMount:Macro(SLASH_CANCELFORM1)
end

-- Got a player target, try copying their mount
function LM_Action:CopyTargetsMount()
    if not UnitIsPlayer("target") then return end
    if not LM_Options:CopyTargetsMount() then return end

    LM_Debug("Trying to clone target's mount")
    return LM_PlayerMounts:GetMountFromUnitAura("target")
end

function LM_Action:Vashjir()
    if not LM_Location:CanSwim() then return end
    if not LM_Location:IsVashjir() then return end

    LM_Debug("Trying GetVashjirMount")
    return LM_PlayerMounts:GetRandomMount(LM_FLAG_BIT_VASHJIR)
end

function LM_Action:Fly()
    if not LM_Location:CanFly() then return end

    LM_Debug("Trying GetFlyingMount")
    return LM_PlayerMounts:GetRandomMount(LM_FLAG_BIT_FLY)
end

function LM_Action:Swim()
    if not LM_Location:CanSwim() then return end

    LM_Debug("Trying GetSwimmingMount")
    return LM_PlayerMounts:GetRandomMount(LM_FLAG_BIT_SWIM)
end

function LM_Action:Nagrand()
    if not LM_Location:IsDraenorNagrand() then return end

    LM_Debug("Trying GetNagrandMount")
    return LM_PlayerMounts:GetRandomMount(LM_FLAG_BIT_NAGRAND)
end

function LM_Action:AQ()
    if not LM_Location:IsAQ() then return end

    LM_Debug("Trying GetAQMount")
    return LM_PlayerMounts:GetRandomMount(LM_FLAG_BIT_AQ)
end

function LM_Action:Run()
    LM_Debug("Trying GetRunningMount")
    return LM_PlayerMounts:GetRandomMount(LM_FLAG_BIT_RUN)
end

function LM_Action:Walk()
    LM_Debug("Trying GetWalkingMount")
    return LM_PlayerMounts:GetRandomMount(LM_FLAG_BIT_WALK)
end

function LM_Action:Custom1()
    LM_Debug("Trying GetCustom1Mount")
    return LM_PlayerMounts:GetRandomMount(LM_FLAG_BIT_CUSTOM1)
end

function LM_Action:Custom2()
    LM_Debug("Trying GetCustom2Mount")
    return LM_PlayerMounts:GetRandomMount(LM_FLAG_BIT_CUSTOM2)
end

function LM_Action:Macro()
    if not LM_Options:UseMacro() then return end

    LM_Debug("Using custom macro.")
    return LM_ActionAsMount:Macro(LM_Options:GetMacro())
end

function LM_Action:CantMount()
    -- This isn't a great message, but there isn't a better one that
    -- Blizzard have already localized. See FrameXML/GlobalStrings.lua.
    -- LM_Warning("You don't know any mounts you can use right now.")
    LM_Warning(SPELL_FAILED_NO_MOUNTS_ALLOWED)

    LM_Debug("Setting action to can't mount now.")
    return LM_ActionAsMount:Macro("")
end

function LM_Action:Combat()
    LM_Debug("Setting action to in-combat action.")

    if LM_Options:UseCombatMacro() then
        return LM_ActionAsMount:Macro(LM_Options:GetCombatMacro())
    else
        return LM_ActionAsMount:Macro(self:DefaultCombatMacro())
    end
end
