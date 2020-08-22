--[[----------------------------------------------------------------------------

  LiteMount/UI/CombatMacro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

function LiteMountOptionsCombatMacro_OnLoad(self)
    self.name = MACRO .. " : " .. COMBAT

    self.EditBox.SetOption =
        function (self, v)
            LM_Options:SetCombatMacro(v)
            LiteMount:Refresh()
        end
    self.EditBox.GetOption =
        function (self) return LM_Options:GetCombatMacro() or "" end
    self.EditBox.GetOptionDefault =
        function (self) return LM_Actions:DefaultCombatMacro() end
    LiteMountOptionsPanel_RegisterControl(self.EditBox)

    self.EnableButton.SetOption =
        function (self, v)
            LM_Options:SetUseCombatMacro(v or false)
            LiteMount:Refresh()
        end
    self.EnableButton.GetOption =
        function (self) return LM_Options:GetUseCombatMacro() end
    self.EnableButton.GetOptionDefault =
        function (self) return false end
    LiteMountOptionsPanel_RegisterControl(self.EnableButton)

    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountOptionsCombatMacro_OnTextChanged(self, userInput)
    local c = strlen(self:GetText() or "")
    LiteMountOptionsCombatMacro.Count:SetText(format(MACROFRAME_CHAR_LIMIT, c))
    LiteMountOptionsControl_OnTextChanged(self, userInput)
end
