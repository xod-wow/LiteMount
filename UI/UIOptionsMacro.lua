--[[----------------------------------------------------------------------------

  LiteMount/UIOptionsMacro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

function LiteMountOptionsMacro_OnLoad(self)
    self.name = MACRO .. " : " .. UNAVAILABLE
    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountOptionsMacro_OnTextChanged(self)
    local c = strlen(self:GetText() or "")
    LiteMountOptionsMacroCount:SetText(format(MACROFRAME_CHAR_LIMIT, c))
    LiteMountOptionsControl_OnChanged(self)
end

