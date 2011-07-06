
--[[----------------------------------------------------------------------------

  LiteMount/Macro.lua

  Macro maintenance.

----------------------------------------------------------------------------]]--

local MacroName = "LiteMount"
local MacroText = "# Auto-created by LiteMount addon.\n/click LiteMount"

local MACRO_ICON_MECHASTRIDER = 300

LM_Macro = LM_CreateAutoEventFrame("Button", "LM_Macro")
LM_Macro:RegisterEvent("PLAYER_LOGIN")

function LM_Macro:CreateOrUpdateMacro()
    local index = GetMacroIndexByName(MacroName)
    if index == 0 then
        index = CreateMacro(MacroName, MACRO_ICON_MECHASTRIDER, MacroText)
    else
        EditMacro(index, nil, nil, MacroText)
    end
end

function LM_Macro:PLAYER_REGEN_ENABLED()
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:CreateOrUpdateMacro()
end

function LM_Macro:PLAYER_LOGIN()
    if InCombatLockdown() then
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        self:CreateOrUpdateMacro()
    end
end

