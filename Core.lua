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

LiteMount = LM_CreateAutoEventFrame("Frame", "LiteMount", UIParent)
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

local ButtonActions = {
    [1] = [[
        LeaveVehicle
        Dismount
        CancelForm
        CopyTargetsMount
        Vashjir
        Fly
        Swim
        Nagrand
        AQ
        Run
        Walk
        Macro
    ]],
    [2] = [[
        LeaveVehicle
        Dismount
        CancelForm
        CopyTargetsMount
        Vashjir
        Swim
        Nagrand
        AQ
        Run
        Walk
        Macro
    ]],
    [3] = [[
        LeaveVehicle
        Dismount
        CancelForm
        Custom1
    ]],
    [4] = [[
        LeaveVehicle
        Dismount
        CancelForm
        Custom2
    ]],
}

function LiteMount:Initialize()

    LM_Debug("Initialize")

    LM_Options:Initialize()
    LM_PlayerMounts:Initialize()

    -- Delayed scanning stops us rescanning unnecessarily.
    self.needScan = true

    SlashCmdList["LiteMount"] = LiteMount_SlashCommandFunc
    SLASH_LiteMount1 = "/litemount"
    SLASH_LiteMount2 = "/lmt"

    -- Rescan event setup
    for _,ev in ipairs(RescanEvents) do
        self[ev] = function (self, event, ...)
                            LM_Debug("Got rescan event "..event)
                            self.needScan = true
                        end
        self:RegisterEvent(ev)
    end

    -- Create SecureActionButtons
    for i,actions in ipairs(ButtonActions) do
        self["action"..i] = LM_ActionButton_Create(i, actions)
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

