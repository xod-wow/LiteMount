--[[----------------------------------------------------------------------------

  LiteMount/Core.lua

  Addon core.

  Copyright 2011-2017 Mike Battersby

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

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

-- This is still a SecureActionButton for backwards compatibility with
-- people's macros with /click LiteMount in them.

_G.LiteMount = LM_CreateAutoEventFrame("Button", "LiteMount", UIParent, "SecureActionButtonTemplate")
LiteMount:RegisterEvent("PLAYER_LOGIN")

function LiteMount:VersionUpgrade()
    local keys

    -- When there were only 2 bindings they were attached directly to
    -- the core addon table. Move them to button1 and button2.
    -- I later renamed the buttons to be a lot shorter for macro purposes
    keys = { GetBindingKey("CLICK LiteMount:LeftButton") }
    for _,k in ipairs(keys) do
        SetBinding(k, "CLICK LM_B1:LeftButton")
    end
    keys = { GetBindingKey("CLICK LiteMount:RightButton") }
    for _,k in ipairs(keys) do
        SetBinding(k, "CLICK LM_B2:LeftButton")
    end

    local old, new
    for i=1,4 do
        old = format("CLICK LiteMountActionButton%d:LeftButton", i)
        new = format("CLICK LM_B%d:LeftButton", i)
        for _,k in ipairs({ GetBindingKey(old) }) do
            SetBinding(k, new)
        end
    end

    -- Update any macros
    local body, n
    for i = 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS do
        body = GetMacroBody(i)
        if body then
            body, n = body:gsub("LiteMountActionButton", "LM_B")
            if n > 0 then EditMacro(i, nil, nil, body) end
        end
    end
end

function LiteMount:Initialize()

    -- Do this first because LM_Debug doesn't work until it's loaded.
    LM_Options:Initialize()

    local version = GetAddOnMetadata("LiteMount", "Version") or "UNKNOWN"

    LM_Debug(format("Initializing LiteMount v%s, debugging enabled.", version))

    self:VersionUpgrade()

    LM_PlayerMounts:Initialize()

    SlashCmdList["LiteMount"] = LiteMount_SlashCommandFunc
    _G.SLASH_LiteMount1 = "/litemount"
    _G.SLASH_LiteMount2 = "/lmt"

    -- Create SecureActionButtons
    self.actions = { }

    for i = 1,4 do
        self.actions[i] = LM_ActionButton:Create(i)
    end

    -- Backwards-compatibility SecureActionButton setup so you can do
    -- still do /click LiteMount if you had it in a macro.
    self:SetAttribute("type", "click")
    for i = 1,#self.actions do
        self:SetAttribute("*clickbutton"..i, self.actions[i])
    end

end

function LiteMount:Refresh()
    LM_Debug("Refresh")

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
    LM_Debug("Got event PLAYER_REGEN_ENABLED")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:Initialize()
end

