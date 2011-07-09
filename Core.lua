--[[----------------------------------------------------------------------------

  LiteMount/Core.lua

  Addon core.

----------------------------------------------------------------------------]]--

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

    local DismountMacro
    if self.playerClass == "DRUID" or self.playerClass == "SHAMAN" then
        DismountMacro = "/dismount\n/cancelform"
    else
        DismountMacro = "/dismount"
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

-- Fancy SecureActionButton stuff. The default button mechanism is
-- type="macro" macrotext="...". If we're not in combat we
-- use a preclick handler to switch it to "spell" and a mount spell ID,
-- and a postclick handler to switch it back to dismount.

function LiteMount:PreClick()

    if InCombatLockdown() then return end

    -- If we're already mounted, leave the button as dismount.
    if IsMounted() then
        return
    end

    if self.playerClass == "DRUID" then
        if GetShapeshiftForm() == 2 then return end
        if GetShapeshiftForm() == 6 then return end
    elseif self.playerClass == "SHAMAN" then
        if GetShapeshiftForm() == 1 then return end
    end

    local m

    if not m and LM_Location:IsVashjir() then
        m = self.ml:GetRandomVashjirMount()
    end

    if not m and LM_Location:CanSwim() then
        m = self.ml:GetRandomSwimmingMount()
    end

    if not m and LM_Location:CanFly() then
        m = self.ml:GetRandomFlyingMount()
    end

    if not m and LM_Location:IsAQ() then
        m = self.ml:GetRandomAQMount()
    end

    if not m and LM_Location:CanWalk() then
        m = self.ml:GetRandomWalkingMount()
                or self.ml:GetRandomSlowWalkingMount()
    end

    if m then
        self:SetAttribute("spell", m:SpellName())
        self:SetAttribute("type", "spell")
    end

end

function LiteMount:PostClick()
    if InCombatLockdown() then return end
    self:SetAttribute("type", "macro")
end
