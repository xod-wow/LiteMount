--[[----------------------------------------------------------------------------

  LiteMount/Core.lua

  Addon core.

----------------------------------------------------------------------------]]--

local MACRO_DISMOUNT = "/dismount"
local MACRO_CANCELFORM = "/cancelform"
local MACRO_EXITVEHICLE = "/run VehicleExit()"
local MACRO_DISMOUNT_CANCELFORM = "/dismount\n/cancelform"

local Default_LM_OptionsDB = {
    ["excludedspells"] = { },
    ["flagoverrides"]  = { },
}

LiteMount = LM_CreateAutoEventFrame("Button", "LiteMount", UIParent, "SecureActionButtonTemplate")
LiteMount:RegisterEvent("PLAYER_LOGIN")
LiteMount.ml = LM_MountList:new()

local RescanEvents = {
    -- Companion change
    "COMPANION_LEARNED", "COMPANION_UNLEARNED",
    -- Might have learned a new mount spell
    "TRAINER_CLOSED",
    -- You might have learned instant ghost wolf
    "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE",
}

function LiteMount:Initialize()

    LM_Debug("Initialize")

    if not LM_OptionsDB then
        LM_OptionsDB = Default_LM_OptionsDB
    elseif not LM_OptionsDB.excludedspells then
        local orig = LM_OptionsDB
        LM_OptionsDB = Default_LM_OptionsDB
        LM_OptionsDB.excludedspells = orig
    end

    self.needscan = true
    self.excludedspells = LM_OptionsDB.excludedspells
    self.flagoverrides = LM_OptionsDB.flagoverrides

    SLASH_LiteMount1 = "/lm"
    SlashCmdList["LiteMount"] = function () InterfaceOptionsFrame_OpenToCategory(LiteMountOptions) end

    self.playerClass = select(2, UnitClass("player"))

    if self.playerClass == "DRUID" or self.playerClass == "SHAMAN" then
        self.defaultMacro = MACRO_DISMOUNT_CANCELFORM
    else
        self.defaultMacro = MACRO_DISMOUNT
    end

    -- Button-fu
    self:RegisterForClicks("LeftButtonDown")

    -- SecureActionButton setup
    self:SetScript("PreClick", function () LiteMount:PreClick() end)
    self:SetScript("PostClick", function () LiteMount:PostClick() end)
    self:SetAttribute("macrotext", DismountMacro)
    self:SetAttribute("type", "macro")

    -- Mount event setup
    for _,ev in ipairs(RescanEvents) do
        self[ev] = function (self, event, ...)
                            LM_Debug("Got rescan event "..event)
                            self.needscan = true
                        end
        self:RegisterEvent(ev)
    end

end

function LiteMount:ScanMounts()
    if not self.needscan then return end
    LM_Debug("Rescanning list of mounts.")
    self.ml:ScanMounts()
    self.needscan = nil
end

function LiteMount:GetAllMounts()
    if not self.ml then return {} end
    self:ScanMounts()
    local allmounts = self.ml:GetMounts()
    table.sort(allmounts, function(a,b) return a:Name() < b:Name() end)
    return allmounts
end

function LiteMount:IsExcludedSpell(id)
    for _,s in ipairs(self.excludedspells) do
        if s == id then return true end
    end
end

function LiteMount:AddExcludedSpell(id)
    LM_Debug(string.format("Disabling mount %s (%d).", GetSpellInfo(id), id))
    if not self:IsExcludedSpell(id) then
        table.insert(self.excludedspells, id)
        table.sort(self.excludedspells)
    end
end

function LiteMount:RemoveExcludedSpell(id)
    LM_Debug(string.format("Enabling mount %s (%d).", GetSpellInfo(id), id))
    for i = 1, #self.excludedspells do
        if self.excludedspells[i] == id then
            table.remove(self.excludedspells, i)
            return
        end
    end
end

function LiteMount:SetExcludedSpells(idlist)
    LM_Debug("Setting complete list of disabled mounts.")
    table.wipe(self.excludedspells)
    for _,id in ipairs(idlist) do
        table.insert(self.excludedspells, id)
    end
    table.sort(self.excludedspells)
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

function LiteMount:SetAsDefault()
    LM_Debug("Setting action to default.")
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", self.defaultMacro)
end

function LiteMount:SetAsDismount()
    LM_Debug("Setting action to Dismount.")
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", MACRO_DISMOUNT)
end

function LiteMount:SetAsVehicleExit()
    LM_Debug("Setting action to VehicleExit.")
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", MACRO_EXITVEHICLE)
end

function LiteMount:SetAsCancelForm()
    LM_Debug("Setting action to CancelForm.")
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", MACRO_CANCELFORM)
end

-- Fancy SecureActionButton stuff. The default button mechanism is
-- type="macro" macrotext="...". If we're not in combat we
-- use a preclick handler to set it to what awe really want to do.

function LiteMount:PreClick()

    if InCombatLockdown() then return end

    LM_Debug("PreClick handler called.")

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

    -- Propagate the exclusion list and the flag overrides
    self.ml:SetExcludedSpellIds(self.excludedspells)
    self.ml:SetOverrideSpellFlags(self.flagoverrides)

    local m

    if not m and LM_Location:CanFly() then
        m = self.ml:GetRandomFlyingMount()
    end

    if not m and LM_Location:IsVashjir() then
        m = self.ml:GetRandomVashjirMount()
    end

    if not m and LM_Location:CanSwim() then
        m = self.ml:GetRandomSwimmingMount()
    end

    if not m and LM_Location:IsAQ() then
        m = self.ml:GetRandomAQMount()
    end

    if not m and LM_Location:CanWalk() then
        m = self.ml:GetRandomWalkingMount()
                or self.ml:GetRandomSlowWalkingMount()
    end

    if m then
        LM_Debug("calling m:SetupActionButton")
        m:SetupActionButton(self)
        return
    else
        LM_Warning(SPELL_FAILED_NO_MOUNTS_ALLOWED)
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

    self:SetAsDefault()
end
