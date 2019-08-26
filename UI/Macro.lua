--[[----------------------------------------------------------------------------

  LiteMount/UI/Macro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2019 Mike Battersby

----------------------------------------------------------------------------]]--

function LiteMountMacro_OnLoad(self)
    self.name = MACRO .. " : " .. UNAVAILABLE
    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountMacro_OnTextChanged(self)
    local c = strlen(self:GetText() or "")
    LiteMountMacro.Count:SetText(format(MACROFRAME_CHAR_LIMIT, c))
    LiteMountOptionsControl_OnChanged(self)
end

