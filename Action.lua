--[[----------------------------------------------------------------------------

  LiteMount/Action.lua

  Mounting actions.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

--[[------------------------------------------------------------------------]]--

LM_Action = { }

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

function LM_Action:DefaultCombatMacro()

    local mt = "/dismount [mounted]\n"

    local playerClass = select(2, UnitClass("player"))

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

function LM_Action:Spell(spellID)
    local name = GetSpellInfo(spellID)
    LM_Debug("Setting action to " .. name .. ".")
    return LM_SecureAction:Spell(name)
end

-- In vehicle -> exit it
function LM_Action:LeaveVehicle()
    if not CanExitVehicle() then return end

    LM_Debug("Setting action to VehicleExit.")
    return LM_SecureAction:Macro(SLASH_LEAVEVEHICLE1)
end

-- Mounted -> dismount
function LM_Action:Dismount()
    if not IsMounted() then return end

    LM_Debug("Setting action to Dismount.")
    return LM_SecureAction:Macro(SLASH_DISMOUNT1)
end

function LM_Action:CancelForm()
    -- We only want to cancel forms that we will activate (mount-style ones).
    -- See: http://wowprogramming.com/docs/api/GetShapeshiftFormID
    local formIndex = GetShapeshiftForm()
    if formIndex == 0 then return end

    local form = LM_PlayerMounts:GetMountByShapeshiftForm(formIndex)
    if not form or LM_Options:IsExcludedMount(form) then return end

    LM_Debug("Setting action to CancelForm.")
    return LM_SecureAction:Macro(SLASH_CANCELFORM1)
end

-- Got a player target, try copying their mount
function LM_Action:CopyTargetsMount()
    if LM_Options.db.char.copyTargetsMount and UnitIsPlayer("target") then
        LM_Debug("Trying to clone target's mount")
        return LM_PlayerMounts:GetMountFromUnitAura("target")
    end
end

function LM_Action:Vashjir()
    if LM_Location:CanSwim() and LM_Location:IsVashjir() then
        LM_Debug("Trying Vashjir Mount")
        return LM_PlayerMounts:GetRandomMount(LM_FLAG.VASHJIR)
    end
end

function LM_Action:Fly()
    if LM_Location:CanFly() then
        LM_Debug("Trying Flying Mount")
        return LM_PlayerMounts:GetRandomMount(LM_FLAG.FLY)
    end
end

function LM_Action:Underwater()
    if select(2, UnitRace("player")) == "Undead" then return end
    if LM_Location:CanSwim() and LM_Location:CantBreathe() then
        LM_Debug("Trying SuramarCity mount")
        return LM_PlayerMounts:GetRandomMount(LM_FLAG.SWIM)
    end
end

function LM_Action:SuramarCity()
    if LM_Location:CanSuramarMasquerade() then
        local m = LM_PlayerMounts:GetMountBySpell(230987)
        if m and m:IsCastable() and not LM_Options:IsExcludedMount(m) then
            return m
        end
    end
end

function LM_Action:Float()
    if LM_Location:IsFloating() then
        LM_Debug("Trying Floating mount")
        return LM_PlayerMounts:GetRandomMount(LM_FLAG.FLOAT)
    end
end

function LM_Action:Swim()
    if LM_Location:CanSwim() and not LM_Location:IsFloating() then
        LM_Debug("Trying Swimming Mount")
        return LM_PlayerMounts:GetRandomMount(LM_FLAG.SWIM)
    end
end

function LM_Action:Nagrand()
    if LM_Location:IsDraenorNagrand() then
        LM_Debug("Trying Nagrand Mount")
        return LM_PlayerMounts:GetRandomMount(LM_FLAG.NAGRAND)
    end
end

function LM_Action:AQ()
    if LM_Location:IsAQ() then
        LM_Debug("Trying AQ Mount")
        return LM_PlayerMounts:GetRandomMount(LM_FLAG.AQ)
    end
end

function LM_Action:Run()
    LM_Debug("Trying Running Mount")
    return LM_PlayerMounts:GetRandomMount(LM_FLAG.RUN)
end

function LM_Action:Walk()
    LM_Debug("Trying Walking Mount")
    return LM_PlayerMounts:GetRandomMount(LM_FLAG.WALK)
end

function LM_Action:Custom1()
    LM_Debug("Trying Custom1 Mount")
    return LM_PlayerMounts:GetRandomMount(LM_FLAG.CUSTOM1)
end

function LM_Action:Custom2()
    LM_Debug("Trying Custom2 Mount")
    return LM_PlayerMounts:GetRandomMount(LM_FLAG.CUSTOM2)
end

function LM_Action:Macro()
    if LM_Options.db.char.useUnavailableMacro then
        LM_Debug("Using custom macro.")
        return LM_SecureAction:Macro(LM_Options.db.char.unavailableMacro)
    end
end

function LM_Action:CantMount()
    -- This isn't a great message, but there isn't a better one that
    -- Blizzard have already localized. See FrameXML/GlobalStrings.lua.
    -- LM_Warning("You don't know any mounts you can use right now.")
    LM_Warning(SPELL_FAILED_NO_MOUNTS_ALLOWED)

    LM_Debug("Setting action to can't mount now.")
    return LM_SecureAction:Macro("")
end

function LM_Action:Combat()
    LM_Debug("Setting action to in-combat action.")

    if LM_Options.db.char.useCombatMacro then
        return LM_SecureAction:Macro(LM_Options.db.char.combatMacro)
    else
        return LM_SecureAction:Macro(self:DefaultCombatMacro())
    end
end
