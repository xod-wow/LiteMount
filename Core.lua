--[[----------------------------------------------------------------------------

  LiteMount/Core.lua

  Addon core.

  Copyright 2011 Mike Battersby

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

local _, LM = ...

-- This is still a SecureActionButton for backwards compatibility with
-- people's macros with /click LiteMount in them.

_G.LiteMount = LM.CreateAutoEventFrame("Button", "LiteMount", UIParent, "SecureActionButtonTemplate")
LiteMount:RegisterEvent("PLAYER_LOGIN")
LiteMount.LM = LM

function LiteMount:MountSpecialTicker(ticker)
    local timerSeconds = LM.Options:GetOption('mountSpecialTimer')

    -- Might have turned off the option while ticker is ticking
    if not IsMounted() or timerSeconds == 0 then
        self.mountSpecialCountdown = nil
        ticker:Cancel()
        return
    end

    if InCombatLockdown() or IsFlying() or LM.Environment:GetStationaryTime() < 5 then
        -- Pause countdown if we are moving around
        return
    end

    if self.mountSpecialCountdown and self.mountSpecialCountdown <= 0 then
        -- Also EMOTE171_TOKEN
        DoEmote("MOUNTSPECIAL")
        self.mountSpecialCountdown = nil
    end

    if self.mountSpecialCountdown then
        self.mountSpecialCountdown = self.mountSpecialCountdown - 1
    else
        timerSeconds = math.max(timerSeconds, 20)
        -- Randomize between 0.5t and 1.5t
        self.mountSpecialCountdown = math.ceil(0.5 * timerSeconds + math.random(timerSeconds))
    end
end

function LiteMount:OnMountSummoned()
    local timer = LM.Options:GetOption('mountSpecialTimer')
    if timer ~= 0 then
        C_Timer.NewTicker(1, function (ticker) self:MountSpecialTicker(ticker) end)
    end
end

function LiteMount:ForceNewRandomMount()
    if not self.actions then
        return
    end

    local allowResummon = true
    for _, actionButton in ipairs(self.actions) do
        if actionButton.ForceNewRandom then
            if actionButton:ForceNewRandom(allowResummon) and allowResummon then
                allowResummon = false
            end
        end
    end
end

function LiteMount:Initialize()

    -- Do this first because LM.Debug doesn't work until it's loaded.
    LM.Options:Initialize()

    local version = C_AddOns.GetAddOnMetadata("LiteMount", "Version") or "UNKNOWN"

    LM.Debug("Initializing LiteMount v%s, debugging enabled.", version)

    LM.MountRegistry:Initialize()

    SlashCmdList["LiteMount"] = LM.SlashCommandFunc
    _G.SLASH_LiteMount1 = "/litemount"
    _G.SLASH_LiteMount2 = "/lmt"

    -- Create SecureActionButtons
    self.actions = { }

    for i = 1,4 do
        self.actions[i] = LM.ActionButton:Create(i)
    end

    -- Backwards-compatibility SecureActionButton setup so you can do
    -- still do /click LiteMount if you had it in a macro.
    self:SetAttribute("type", "click")
    for i = 1,#self.actions do
        self:SetAttribute("*clickbutton"..i, self.actions[i])
    end

    -- Setup actions for the initial profile
    LM.Options:OnProfile()

    -- Filter has to register DB changed callback
    LM.UIFilter.Initialize()

    LM.MountRegistry.RegisterCallback(self, "OnMountSummoned", "OnMountSummoned")
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
    LM.Debug("Got event PLAYER_REGEN_ENABLED")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:Initialize()
end

--@debug@
_G.LM = LM
--@end-debug@
