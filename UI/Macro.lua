--[[----------------------------------------------------------------------------

  LiteMount/UI/Macro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

function LiteMountOptionsMacro_OnLoad(self)
    self.name = MACRO .. " : " .. UNAVAILABLE

    self.EditBox.SetOption =
        function (self, v)
            LM_Options:SetUnavailableMacro(v)
        end
    self.EditBox.GetOption =
        function (self) return LM_Options:GetUnavailableMacro() or "" end
    self.EditBox.GetOptionDefault =
        function (self) return "" end
    LiteMountOptionsControl_OnLoad(self.EditBox)

    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountOptionsMacro_OnTextChanged(self, userInput)
    local c = strlen(self:GetText() or "")
    LiteMountOptionsMacro.Count:SetText(format(MACROFRAME_CHAR_LIMIT, c))
    LiteMountOptionsControl_OnTextChanged(self, userInput)
end
