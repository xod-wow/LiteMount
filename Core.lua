--[[----------------------------------------------------------------------------

  LiteMount/Core.lua

  Addon core.

----------------------------------------------------------------------------]]--

LiteMount = LM_CreateAutoEventFrame("Button", "LiteMount", UIParent, "SecureActionButtonTemplate")
LiteMount:RegisterEvent("PLAYER_LOGIN")

local RescanEvents = {
    -- Companion change
    "COMPANION_LEARNED", "COMPANION_UNLEARNED",
    -- Might have learned a new mount spell
    "TRAINER_CLOSED",
    -- You might have learned instant ghost wolf
    "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE",
    -- You might have received a mount item
    "BAG_UPDATE"
}

-- This is the macro that gets set as the default and will trigger if
-- we are in combat.  Don't put anything in here that isn't specifically
-- combat-only, because out of combat we've got proper code available.
-- Relies on self.playerClass being set before this is called.
-- Note that macros are limited to 255 chars, even inside a SecureActionButton.

function LiteMount:BuildCombatMacro()

    local m = "/dismount [mounted]\n" ..
              "/leavevehicle [vehicleui]\n"

    if self.playerClass ==  "DRUID" then
        if IsSpellKnown(LM_SPELL_AQUATIC_FORM) then
            local s = GetSpellInfo(LM_SPELL_AQUATIC_FORM)
            m = m ..  "/cast [swimming,noform:2/4/6] " .. s .. "\n"
        end
        if IsSpellKnown(LM_SPELL_TRAVEL_FORM) then
            local s = GetSpellInfo(LM_SPELL_TRAVEL_FORM)
            m = m ..  "/cast [noform:2/4/6] " .. s .. "\n"
        end
        m = m ..  "/cancelform [form:2/4/6]\n"
    elseif self.playerClass == "SHAMAN" then
        if IsSpellKnown(LM_SPELL_GHOST_WOLF) then
            local s = GetSpellInfo(LM_SPELL_GHOST_WOLF)
            m = m ..
                "/cast [noform] " .. s .. "\n" ..
                "/cancelform [form]\n"
        end
    end

    self.inCombatMacro = m
end

function LiteMount:Initialize()

    LM_Debug("Initialize")

    LM_Options:Initialize()
    LM_PlayerMounts:Initialize()

    -- Delayed scanning does two things. It stops us rescanning unnecessarily,
    -- but more importantly it prevents a weird situation on loading where
    -- the scan errors because GetCompanionInfo("MOUNT", i) fails for some
    -- i < GetNumCompanions("MOUNT").
    self.needScan = true

    SlashCmdList["LiteMount"] = LiteMount_OpenOptionsPanel
    SLASH_LiteMount1 = "/litemount"
    SLASH_LiteMount2 = "/lmt"

    self.playerClass = select(2, UnitClass("player"))

    self:BuildCombatMacro()

    -- Button-fu
    self:RegisterForClicks("AnyDown")

    -- SecureActionButton setup
    self:SetScript("PreClick", function (s,m,d) LiteMount:PreClick(m,d) end)
    self:SetScript("PostClick", function (s,m,d) LiteMount:PostClick(m,d) end)
    self:SetAttribute("macrotext", self.inCombatMacro)
    self:SetAttribute("type", "macro")
    self:SetAttribute("unit", "player")

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
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:Initialize()
end

function LiteMount:SetAsInCombatAction()
    LM_Debug("Setting action to default in-combat action.")
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", self.inCombatMacro)
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

    -- Mounted -> dismount
    if IsMounted() then
        self:SetAsDismount()
        return
    end

    -- In vehicle -> exit it
    if CanExitVehicle() then
        self:SetAsVehicleExit()
        return
    end

    -- The (true) here stops it returning stances and other pseudo-forms
    local form = GetShapeshiftForm(true)

    if self.playerClass == "DRUID" and form == 2 or form == 4 or form == 6 then
        self:SetAsCancelForm()
        return
    elseif self.playerClass == "SHAMAN" and form == 1 then
        self:SetAsCancelForm()
        return
    end

    local m

    if not m and LM_Location:CanFly() and mouseButton == "LeftButton" then
        LM_Debug("Trying GetFlyingMount")
        m = LM_PlayerMounts:GetFlyingMount()
    end

    if not m and LM_Location:IsVashjir() then
        LM_Debug("Trying GetVashjirMount")
        m = LM_PlayerMounts:GetVashjirMount()
    end

    if not m and LM_Location:CanSwim() then
        LM_Debug("Trying GetSwimmingMount")
        m = LM_PlayerMounts:GetSwimmingMount()
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
        LM_Debug("calling m:SetupActionButton")
        m:SetupActionButton(self)
        return
    end

    LM_Debug("No usable mount found, checking for custom macro.")
    local macro = LM_Options:GetMacro()
    if macro then
        self:SetAsMacroText(macro)
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
