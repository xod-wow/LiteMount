--[[----------------------------------------------------------------------------

  LiteMount/OptionsUI/Macro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

function LM_OptionsUIMacro_OnLoad(self)
    self.name = MACRO .. " : " .. UNAVAILABLE
    LM_OptionsUIPanel_OnLoad(self)
end

function LM_OptionsUIMacro_OnShow(self)
    LM_OptionsUIPanel_OnShow(self)
end

function LM_OptionsUIMacro_OnTextChanged(self)
    local c = strlen(self:GetText() or "")
    LM_OptionsUIMacroCount:SetText(format(MACROFRAME_CHAR_LIMIT, c))
end

