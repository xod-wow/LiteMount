--[[----------------------------------------------------------------------------

  LiteMount/UI/Macro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2018 Mike Battersby

----------------------------------------------------------------------------]]--

function LiteMountOptionsMacro_OnLoad(self)
    self.name = MACRO .. " : " .. UNAVAILABLE
    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountOptionsMacro_OnTextChanged(self)
    local c = strlen(self:GetText() or "")
    LiteMountOptionsMacro.Count:SetText(format(MACROFRAME_CHAR_LIMIT, c))
    LiteMountOptionsControl_OnChanged(self)
end

