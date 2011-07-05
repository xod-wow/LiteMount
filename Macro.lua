
--[[----------------------------------------------------------------------------

  LiteMount/Macro.lua

  Macro maintenance.

----------------------------------------------------------------------------]]--

local MacroName = "LiteMount"
local MacroText = "# Auto-created by LiteMount addon.\n/click LiteMount"

LM_Macro = LM_CreateAutoEventFrame("Button", "LiteMount")
LM_Macro:RegisterEvent("PLAYER_LOGIN")

function LM_Macro:CreateOrUpdateMacro()
    local index = GetMacroIndexByName(MacroName)
    if index == 0 then
        index = CreateMacro(MacroName, 1, MacroText)
    else
        EditMacro(index, nil, nil, MacroText)
    end
end

function LM_Macro:Initialize()
    self:CreateOrUpdateMacro()
    self:RegisterEvent("UPDATE_MACROS")
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

