--[[----------------------------------------------------------------------------

  LiteMount/UI/CombatMacro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

function LiteMountOptionsCombatMacro_OnLoad(self)
    self.name = MACRO .. " : " .. COMBAT

    self.EditBox.SetOption =
        function (self, v)
            LM_Options.db.char.combatMacro = v
            LiteMount:Refresh()
        end
    self.EditBox.GetOption =
        function (self) return LM_Options.db.char.combatMacro or "" end
    self.EditBox.GetOptionDefault =
        function (self) return LM_Actions:DefaultCombatMacro() end
    LiteMountOptionsControl_OnLoad(self.EditBox)

    self.EnableButton.SetOption =
        function (self, v) LM_Options.db.char.useCombatMacro = (v or false) end
    self.EnableButton.GetOption =
        function (self) return LM_Options.db.char.useCombatMacro end
    self.EnableButton.GetOptionDefault =
        function (self) return false end
    LiteMountOptionsControl_OnLoad(self.EnableButton)

    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountOptionsCombatMacro_OnTextChanged(self)
    local c = strlen(self:GetText() or "")
    LiteMountOptionsCombatMacro.Count:SetText(format(MACROFRAME_CHAR_LIMIT, c))
    LiteMountOptionsControl_OnChanged(self)
end
