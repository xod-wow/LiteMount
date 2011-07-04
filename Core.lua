--[[----------------------------------------------------------------------------

  LiteMount/Core.lua

  Addon core.

----------------------------------------------------------------------------]]--

LiteMount = LM_CreateAutoEventFrame("Frame", "LiteMount", "SecureActionButtonTemplate")
LiteMount:RegisterEvent("PLAYER_LOGIN")

function LiteMount:Initialize()
    self.ml = LM_MountList:new()
    self.ml:ScanMounts()

    SLASH_LM1 = "/lm"
    SlashCmdList["LM1"] = function () self.ml:ScanMounts() self.ml:Dump() end

    -- Button-fu
    self:RegisterForClicks("LeftButtonDown")

    -- SecureActionButton setup
    self:SetScript("PreClick", function () LiteMount:PreClick() end)
    self:SetScript("PostClick", function () LiteMount:PostClick() end)
    self:SetAttribute("macrotext", "Dismount()")
    self:SetAttribute("type", "macrotext")

    -- Rescanning of MountList
    self:RegisterEvent("COMPANION_LEARNED")
    self:RegisterEvent("COMPANION_UNLEARNED")
    self:RegisterEvent("COMPANION_UPDATE")

end

function LiteMount:COMPANION_LEARNED()
    self.ml:ScanMounts()
end

function LiteMount:COMPANION_UNLEARNED()
    self.ml:ScanMounts()
end

function LiteMount:COMPANION_UPDATE()
    self.ml:ScanMounts()
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
-- type="macrotext" macrotext="Dismount()". If we're not in combat we
-- use a preclick handler to switch it to "spell" and a mount spell ID,
-- and a postclick handler to switch it back to dismount.

function LiteMount:PreClick()

    if InCombatLockdown() then return end

    -- If we're already mounted, leave the button as dismount.
    if IsMounted() then return end

    local m

    if Location:CanFly() then
        m = self.ml:GetRandomFlyingMount()
    end

    if not m and Location:IsAQ() then
        m = self.ml:GetRandomAQMount()
    end

    if not m and Location:IsVashjir() then
        m = self.ml:GetRandomVashjirMount()
    end

    if not m and Location:CanSwim() then
        m = self.ml:GetRandomSwimmingMount()
    end

    if not m and Location:CanWalk() then
        m = self.ml:GetRandomGroundMount()
    end

    if m then
        self:SetAttribute("spell", m:SpellId())
        self:SetAttribute("type", "spell")
    end

end

function LiteMount:PostClick()
    if InCombatLockdown() then return end
    self:SetAttribute("type", "macrotext")
end
