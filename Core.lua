--[[----------------------------------------------------------------------------

  LiteMount/Core.lua

  Addon core.

  Copyright 2011-2020 Mike Battersby

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

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

-- This is still a SecureActionButton for backwards compatibility with
-- people's macros with /click LiteMount in them.

_G.LiteMount = LM.CreateAutoEventFrame("Button", "LiteMount", UIParent, "SecureActionButtonTemplate")
LiteMount:RegisterEvent("PLAYER_LOGIN")
LiteMount.LM = LM

function LiteMount:Initialize()

    -- Do this first because LM.Debug doesn't work until it's loaded.
    LM.Options:Initialize()

    local version = GetAddOnMetadata("LiteMount", "Version") or "UNKNOWN"

    LM.Debug(format("Initializing LiteMount v%s, debugging enabled.", version))

    LM.PlayerMounts:Initialize()

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

end

function LiteMount:RecompileActions()
    for _,b in ipairs(self.actions) do
        b:CompileActions()
    end
end

function LiteMount:Refresh()
    LM.Debug("Refresh")

    for _,actionButton in ipairs(self.actions) do
        actionButton:PostClick()
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
    LM.Debug("Got event PLAYER_REGEN_ENABLED")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:Initialize()
end

