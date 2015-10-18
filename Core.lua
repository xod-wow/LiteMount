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
    "UNIT_LEVEL", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE",
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
    LM_Action:Combat()(self)
end

-- Fancy SecureActionButton stuff. The default button mechanism is
-- type="macro" macrotext="...". If we're not in combat we
-- use a preclick handler to set it to what we really want to do.

function LiteMount:PreClick(mouseButton)

    if InCombatLockdown() then return end

    LM_Debug("PreClick handler called. Button " .. (mouseButton or "nil"))

    self:ScanMounts()

    local ActionList = {
        "LeaveVehicle",
        "Dismount",
        "CancelForm",
        "CopyTargetsMount",
        "Vashjir",
        "Fly",
        "Swim",
        "Nagrand",
        "AQ",
        "Run",
        "Walk",
        "Macro",
        "CantMount"
    }

    for _, action in ipairs(ActionList) do
        if not LM_Action[action] then next end
        local m = LM_Action[action]()
        if m then return m:SetupActionButton(self) end
    end

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
