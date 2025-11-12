--[[----------------------------------------------------------------------------

  LiteMount/UI/Macro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

--[[------------------------------------------------------------------------]]--

local PanelTemplates_AnchorTabs = PanelTemplates_AnchorTabs or LM.PanelTemplates_AnchorTabs
local C_ClassColor = C_ClassColor or LM.C_ClassColor


--[[------------------------------------------------------------------------]]--

LiteMountMacroEditBoxMixin = {}

function LiteMountMacroEditBoxMixin:OnTextChanged(userInput)
    local parent = self:GetParent()
    local text = self:GetText()
    local c = strlen(text)
    parent.Count:SetText(format(MACROFRAME_CHAR_LIMIT, c))
    if LiteMountMacroPanel:IsDefaultMacro(text) then
        self:SetTextColor(0.5, 0.5, 0.5)
    else
        self:SetTextColor(1, 1, 1)
    end
    if userInput then
        LiteMountMacroPanel:WriteSettingsForTab()
    end
end

--[[------------------------------------------------------------------------]]--

LiteMountMacroEnableButtonMixin = {}

function LiteMountMacroEnableButtonMixin:OnClick()
    LiteMountMacroPanel:WriteSettingsForTab()
end

--[[------------------------------------------------------------------------]]--

LiteMountMacroTabMixin = {}

function LiteMountMacroTabMixin:OnClick()
    self:GetParent():SetTab(self:GetID())
end

--[[------------------------------------------------------------------------]]--

LiteMountMacroPanelMixin = {}

local OptionKeysByTab = {
    [1] = { 'unavailableMacro', 'useUnavailableMacro', L.LM_MACRO_EXP },
    [2] = { 'combatMacro', 'useCombatMacro', L.LM_COMBAT_MACRO_EXP },
}

function LiteMountMacroPanelMixin:SetControl()
    self:Update()
end

function LiteMountMacroPanelMixin:GetSettingsForTab()
    local selectedTab = PanelTemplates_GetSelectedTab(self)
    local macroKey, useKey, helpText = unpack(OptionKeysByTab[selectedTab])
    local macro = LM.Options:GetClassOption(self.selectedClass, macroKey)
    local use = LM.Options:GetClassOption(self.selectedClass, useKey)
    if macro == nil then
        local isCombat = selectedTab == 2
        macro = LM.Macro:GetDefault(isCombat, self.selectedClass)
    end
    return macro, use, helpText
end

function LiteMountMacroPanelMixin:WriteSettingsForTab()
    local selectedTab = PanelTemplates_GetSelectedTab(self)
    local macroKey, useKey = unpack(OptionKeysByTab[selectedTab])
    local macro = self.Macro.EditBox:GetText()
    if macro == "" or self:IsDefaultMacro(macro) then
        macro = nil
    end
    local use = self.Macro.EnableButton:GetChecked() and true or nil
    self.isDirty = true
    LM.Options:SetClassOption(self.selectedClass, macroKey, macro)
    LM.Options:SetClassOption(self.selectedClass, useKey, use)
end

function LiteMountMacroPanelMixin:IsDefaultMacro(text)
    local isCombat = PanelTemplates_GetSelectedTab(self) == 2
    local default = LM.Macro:GetDefault(isCombat, self.selectedClass)
    return text == default
end

function LiteMountMacroPanelMixin:Update()
    local text, isEnabled, helpText = self:GetSettingsForTab()
    self.Macro.EditBox:SetText(text or "")
    self.Macro.EnableButton:SetChecked(isEnabled)
    self.Macro.ExplainText:SetText(helpText)

    local dp = CreateDataProvider(self.classMenu)
    self.Class.ScrollBox:SetDataProvider(dp, ScrollBoxConstants.RetainScrollPosition)
end

function LiteMountMacroPanelMixin:SetOption(t)
    local classKey = UnitClassBase('player')
    LM.db.char = t.char
    LM.db.class = t.class and t.class[classKey] or nil
    LM.db.sv.class = t.class
    LM.Options:NotifyChanged()
end

function LiteMountMacroPanelMixin:GetOption()
    return {
        char = LM.db.char and CopyTable(LM.db.char),
        class = LM.db.sv.class and CopyTable(LM.db.sv.class),
    }
end

function LiteMountMacroPanelMixin:OnLoad()
    self.name = MACROS

    PanelTemplates_SetNumTabs(self, 2)
    PanelTemplates_AnchorTabs(self)
    PanelTemplates_ResizeTabsToFit(self)
    PanelTemplates_SetTab(self, 1)

    self.selectedClass = 'PLAYER'

    self.Macro.DeleteButton:SetScript("OnClick",
        function ()
            self.Macro.EditBox:SetText("")
            -- Need to call this directly because userInput is false in OnTextChanged
            self:WriteSettingsForTab()
        end)

    local view = CreateScrollBoxListLinearView(0, 0, 0, 0, 2)
    view:SetElementInitializer("LiteMountListSelectButtonTemplate",
        function (button, elementData)
            local isSelected = self.selectedClass == elementData.key
            button.SelectedTexture:SetShown(isSelected)
            button:SetText(elementData.color:WrapTextInColorCode(elementData.name))
            button:SetScript('OnClick', function () self:SetClass(elementData.key) end)
        end)
    ScrollUtil.InitScrollBoxListWithScrollBar(self.Class.ScrollBox, self.Class.ScrollBar, view)

    LiteMountOptionsPanel_RegisterControl(self, self)
end

function LiteMountMacroPanelMixin:OnShow()
    self.classMenu = { }

    for i = 1, GetNumClasses() do
        local name, key, id = GetClassInfo(i)
        local color = C_ClassColor.GetClassColor(key)
        table.insert(self.classMenu, { name=name, key=key, id=id, color=color })
    end
    table.sort(self.classMenu, function (a, b) return a.name < b.name end)
    local playerName = string.join('-', UnitFullName('player'))
    table.insert(self.classMenu, 1, { name=playerName, key='PLAYER', id=0, color=WHITE_FONT_COLOR })
    -- GRAY, GREEN, HIGHLIGHT, ITEM_LEGENDARY, GOLD

    LiteMountOptionsPanel_OnShow(self)
end

function LiteMountMacroPanelMixin:SetTab(id)
    PanelTemplates_SetTab(self, id)
    self:SetControl()
end

function LiteMountMacroPanelMixin:SetClass(c)
    self.selectedClass = c
    self:SetControl()
end
