--[[----------------------------------------------------------------------------

  LiteMount/Core.lua

  Addon core.

----------------------------------------------------------------------------]]--

local MACRO_DISMOUNT = "/dismount"
local MACRO_CANCELFORM = "/cancelform"
local MACRO_EXITVEHICLE = "/run VehicleExit()"
local MACRO_DISMOUNT_CANCELFORM = "/dismount\n/cancelform"


LiteMount = LM_CreateAutoEventFrame("Button", "LiteMount", UIParent, "SecureActionButtonTemplate")
LiteMount:RegisterEvent("PLAYER_LOGIN")

local RescanEvents = {
    -- Companion change
    "COMPANION_LEARNED", "COMPANION_UNLEARNED", "COMPANION_UPDATE",
    -- Might have learned a new mount spell
    "LEARNED_SPELL_IN_TAB",
    -- You might have learned instant ghost wolf
    "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE",
}
    
function LiteMount:Initialize()

    self.ml = LM_MountList:new()
    self.ml:ScanMounts()

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

    for _,ev in ipairs(RescanEvents) do
        self[ev] = function (self, event, ...) self.ml:ScanMounts() end
        self:RegisterEvent(ev)
    end

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
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", self.defaultMacro)
end

function LiteMount:SetAsDismount()
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", MACRO_DISMOUNT)
end

function LiteMount:SetAsVehicleExit()
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", MACRO_EXITVEHICLE)
end

function LiteMount:SetAsCancelForm()
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", MACRO_CANCELFORM)
end

function LiteMount:SetAsSpell(spellName)
    self:SetAttribute("type", "spell")
    self:SetAttribute("spell", spellName)
end

-- Fancy SecureActionButton stuff. The default button mechanism is
-- type="macro" macrotext="...". If we're not in combat we
-- use a preclick handler to switch it to "spell" and a mount spell ID,
-- and a postclick handler to switch it back to dismount.

function LiteMount:PreClick()

    if InCombatLockdown() then return end

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

    local form = GetShapeshiftForm(true)

    if self.playerClass == "DRUID" and form == 2 or form == 4 or form == 6 then
        self:SetAsCancelForm()
        return
    elseif self.playerClass == "SHAMAN" and form == 1 then
        self:SetAsCancelForm()
        return
    end

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
        self:SetAsSpell(m:SpellName())
        return
    end

end

function LiteMount:PostClick()
    if InCombatLockdown() then return end

    -- We'd like to set the macro to undo whatever we did, but
    -- tests like IsMounted() and CanExitVehicle() will still
    -- represent the pre-action state at this point.  We don't want
    -- to just blindly do the opposite of whatever we chose because
    -- it might not have worked.

    self:SetAsDefault()
end
