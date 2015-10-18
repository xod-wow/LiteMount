--[[----------------------------------------------------------------------------

  LiteMount/Core.lua

  Addon core.

  Copyright 2011-2015 Mike Battersby

  LiteMount is free software: you can redistribute it and/or modify it under
  the terms of the GNU General Public License, version 2, as published by
  the Free Software Foundation.

  LiteMount is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
  more details.

  The file LICENSE.txt included with LiteMount contains a copy of the
  license. If the LICENSE.txt file is missing, you can find a copy at
  http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

----------------------------------------------------------------------------]]--

LiteMount = LM_CreateAutoEventFrame("Button", "LiteMount", UIParent, "SecureActionButtonTemplate")
LiteMount:RegisterEvent("PLAYER_LOGIN")

local RescanEvents = {
    -- Companion change. Don't add COMPANION_UPDATE to this as it fires
    -- for units other than "player" and triggers constantly.
    "COMPANION_LEARNED", "COMPANION_UNLEARNED",
    -- Talents (might have mount abilities). Glyphs that teach spells   
    -- fire PLAYER_TALENT_UPDATE too, don't need to watch GLYPH_ events.
    "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_LEVEL_UP", "PLAYER_TALENT_UPDATE",
    -- You might have received a mount item
    "BAG_UPDATE",
    -- Draenor flying is an achievement
    "ACHIEVEMENT_EARNED",
}

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
-- Relies on self.playerClass being set before this is called.
-- Note that macros are limited to 255 chars, even inside a SecureActionButton.

function LiteMount:BuildCombatMacro()

    local mt = "/dismount [mounted]\n"

    if self.playerClass ==  "DRUID" then
        local forms = GetDruidMountForms()
        local mount = LM_PlayerMounts:GetMountBySpell(LM_SPELL_TRAVEL_FORM)
        if mount and not mount:IsExcluded() then
            mt = mt .. format("/cast [noform:%s] %s\n", forms, mount:Name())
            mt = mt .. format("/cancelform [form:%s]\n", forms)
        end
    elseif self.playerClass == "SHAMAN" then
        local mount = LM_PlayerMounts:GetMountBySpell(LM_SPELL_GHOST_WOLF)
        if mount and not mount:IsExcluded() then
            local s = GetSpellInfo(LM_SPELL_GHOST_WOLF)
            mt = mt .. "/cast [noform] " .. s .. "\n"
            mt = mt .. "/cancelform [form]\n"
        end
    end

    mt = mt .. "/leavevehicle\n"

    return mt
end

function LiteMount:Initialize()

    LM_Debug("Initialize")

    LM_Options:Initialize()
    LM_PlayerMounts:Initialize()

    -- Delayed scanning stops us rescanning unnecessarily.
    self.needScan = true

    SlashCmdList["LiteMount"] = LiteMount_SlashCommandFunc
    SLASH_LiteMount1 = "/litemount"
    SLASH_LiteMount2 = "/lmt"

    self.playerClass = select(2, UnitClass("player"))

    -- Button-fu
    self:RegisterForClicks("AnyDown")

    -- SecureActionButton setup
    self:SetScript("PreClick", self.PreClick)
    self:SetScript("PostClick", self.PostClick)
    self:SetAttribute("type", "macro")
    self:SetAttribute("unit", "player")
    self:SetAsInCombatAction()

    -- Mount event setup
    for _,ev in ipairs(RescanEvents) do
        self[ev] = function (self, event, ...)
                            LM_Debug("Got rescan event "..event)
                            self.needScan = true
                        end
        self:RegisterEvent(ev)
    end

end

function LiteMount:ScanMounts()
    if not self.needScan then return end
    LM_Debug("Rescanning list of mounts.")
    LM_PlayerMounts:ScanMounts()
    LM_Debug("Finished rescan.")
    self.needScan = nil
end

function LiteMount:GetAllMounts()
    if not LM_PlayerMounts then return {} end
    self:ScanMounts()
    local allmounts = LM_PlayerMounts:GetAllMounts()
    allmounts:Sort()
    return allmounts
end

function LiteMount:PLAYER_LOGIN()
    self:UnregisterEvent("PLAYER_LOGIN")

    -- We might login already in combat.
    if InCombatLockdown() then
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        self:Initialize()
    end
end

function LiteMount:PLAYER_REGEN_ENABLED()
    LM_Debug("Got event PLAYER_REGEN_ENABLED")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:Initialize()
end

function LiteMount:SetAsInCombatAction()
    LM_Debug("Setting action to in-combat action.")
    self:SetAttribute("type", "macro")

    if LM_Options:UseCombatMacro() then
        self:SetAttribute("macrotext", LM_Options:GetCombatMacro())
    else
        self:SetAttribute("macrotext", self:BuildCombatMacro())
    end
end

function LiteMount:SetAsCantMount()
    LM_Debug("Setting action to can't mount now.")
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", nil)
end

function LiteMount:SetAsDismount()
    LM_Debug("Setting action to Dismount.")
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", SLASH_DISMOUNT1)
end

function LiteMount:SetAsVehicleExit()
    LM_Debug("Setting action to VehicleExit.")
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", SLASH_LEAVEVEHICLE1)
end

function LiteMount:SetAsCancelForm()
    LM_Debug("Setting action to CancelForm.")
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", SLASH_CANCELFORM1)
end

function LiteMount:SetAsPlayerTargetedSpell(spellId)
    local name = GetSpellInfo(spellId)
    LM_Debug("Setting action to " .. name .. ".")
    self:SetAttribute("type", "spell")
    self:SetAttribute("spell", name)
    -- self:SetAttribute("unit", "player") -- Already done in setup
end

function LiteMount:SetAsMacroText(macrotext)
    LM_Debug("Setting as raw macro text.")
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", macrotext)
end

-- Fancy SecureActionButton stuff. The default button mechanism is
-- type="macro" macrotext="...". If we're not in combat we
-- use a preclick handler to set it to what we really want to do.

function LiteMount:PreClick(mouseButton)

    if InCombatLockdown() then return end

    LM_Debug("PreClick handler called. Button " .. (mouseButton or "nil"))

    self:ScanMounts()

    -- In vehicle -> exit it
    if CanExitVehicle() then
        self:SetAsVehicleExit()
        return
    end

    -- Mounted -> dismount
    if IsMounted() then
        self:SetAsDismount()
        return
    end

    -- We only want to cancel forms that we will activate (mount-style ones).
    -- See: http://wowprogramming.com/docs/api/GetShapeshiftFormID
    local formIndex = GetShapeshiftForm()
    if formIndex > 0 then
        local form = LM_PlayerMounts:GetMountByShapeshiftForm(formIndex)
        if form and not form:IsExcluded() then
            self:SetAsCancelForm()
            return
        end
    end

    local m

    -- Got a player target, try copying their mount
    if not m and UnitIsPlayer("target") and LM_Options:CopyTargetsMount() then
        LM_Debug("Trying to clone target's mount")
        m = LM_PlayerMounts:GetMountFromUnitAura("target")
    end

    if not m and LM_Location:CanSwim() and LM_Location:IsVashjir() then
        LM_Debug("Trying GetVashjirMount")
        m = LM_PlayerMounts:GetVashjirMount()
    end

    -- The order of GetSwimmingMount and GetFlyingMount here is uncertain
    -- now that we can't properly detect if you're under water or floating
    -- on top.

    if not m and LM_Location:CanFly() then
        if mouseButton == "LeftButton" then
            LM_Debug("Trying GetFlyingMount")
            m = LM_PlayerMounts:GetFlyingMount()
        end
    end

    if not m and LM_Location:CanSwim() then
        LM_Debug("Trying GetSwimmingMount")
        m = LM_PlayerMounts:GetSwimmingMount()
    end

    if not m and LM_Location:IsDraenorNagrand() then
        LM_Debug("Trying GetNagrandMount")
        m = LM_PlayerMounts:GetNagrandMount()
    end

    if not m and LM_Location:IsAQ() then
        LM_Debug("Trying GetAQMount")
        m = LM_PlayerMounts:GetAQMount()
    end

    if not m then
        LM_Debug("Trying GetRunningMount")
        m = LM_PlayerMounts:GetRunningMount()
    end

    if not m then
        LM_Debug("Trying GetWalkingMount")
        m = LM_PlayerMounts:GetWalkingMount()
    end

    if m then
        LM_Debug(format("Setting button to %s (spell %s)", m:Name(), m:SpellName()))
        m:SetupActionButton(self)
        return
    end

    LM_Debug("No usable mount found, checking for custom macro.")
    if LM_Options:UseMacro() then
        self:SetAsMacroText(LM_Options:GetMacro())
        return
    end

    -- This isn't a great message, but there isn't a better one that
    -- Blizzard have already localized. See FrameXML/GlobalStrings.lua.
    -- LM_Warning("You don't know any mounts you can use right now.")
    LM_Warning(SPELL_FAILED_NO_MOUNTS_ALLOWED)
    self:SetAsCantMount()

end

function LiteMount:PostClick()
    if InCombatLockdown() then return end

    LM_Debug("PostClick handler called.")

    -- We'd like to set the macro to undo whatever we did, but
    -- tests like IsMounted() and CanExitVehicle() will still
    -- represent the pre-action state at this point.  We don't want
    -- to just blindly do the opposite of whatever we chose because
    -- it might not have worked.

    self:SetAsInCombatAction()
end
