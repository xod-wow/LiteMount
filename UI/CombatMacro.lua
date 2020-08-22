--[[----------------------------------------------------------------------------

  LiteMount/UI/CombatMacro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

LiteMountCombatMacroPanelMixin = {}

local function OnTextChanged(self, userInput)
    local c = strlen(self:GetText() or "")
    self:GetParent().Count:SetText(format(MACROFRAME_CHAR_LIMIT, c))
    LiteMountOptionsControl_OnTextChanged(self, userInput)
end

function LiteMountCombatMacroPanelMixin:OnLoad()
    self.name = MACRO .. " : " .. COMBAT

    self.EditBoxContainer:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.8)
    self.EditBoxContainer:SetBackdropColor(0, 0, 0, 0.5)

    self.EditBox.SetOption =
        function (self, v)
            LM_Options:SetCombatMacro(v)
            LiteMount:Refresh()
        end
    self.EditBox.GetOption =
        function (self) return LM_Options:GetCombatMacro() or "" end
    self.EditBox.GetOptionDefault =
        function (self) return LM_Actions:DefaultCombatMacro() end
    self.EditBox:SetScript("OnTextChanged", OnTextChanged)
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

    self.DeleteButton:SetScript("OnClick",
            function () self.EditBox:SetOption("") end)

    self.DefaultButton:SetScript("OnClick",
            function () LiteMountOptionsControl_Default(self.EditBox) end)

    self.RevertButton:SetScript("OnCLick",
            function () LiteMountOptionsPanel_Revert(self) end)
    LiteMountOptionsPanel_OnLoad(self)
end
