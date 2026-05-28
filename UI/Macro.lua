--[[----------------------------------------------------------------------------

  LiteMount/UI/Macro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.L

--[[------------------------------------------------------------------------]]--

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

function LiteMountMacroPanelMixin:GetSettingsForTab()
    local selectedTab = self.selectedTab
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
    local selectedTab = self.selectedTab
    local macroKey, useKey = unpack(OptionKeysByTab[selectedTab])
    local macro = self.Macro.EditBox:GetText()
    if macro == "" or self:IsDefaultMacro(macro) then
        macro = nil
    end
    local use = self.Macro.EnableButton:GetChecked() and true or nil
    self:MarkDirty()
    LM.Options:SetClassOption(self.selectedClass, macroKey, macro)
    LM.Options:SetClassOption(self.selectedClass, useKey, use)
end

function LiteMountMacroPanelMixin:IsDefaultMacro(text)
    local isCombat = self.selectedTab == 2
    local default = LM.Macro:GetDefault(isCombat, self.selectedClass)
    return text == default
end

function LiteMountMacroPanelMixin:GenerateClassMenu()
    local selectedTab = self.selectedTab
    local _, useKey = unpack(OptionKeysByTab[selectedTab])

    local classMenu = { }

    for i = 1, GetNumClasses() do
        local name, key, id = GetClassInfo(i)
        local color = C_ClassColor.GetClassColor(key)
        local enabled =  LM.Options:GetClassOption(key, useKey)
        table.insert(classMenu, { name=name, key=key, id=id, color=color, enabled=enabled })
    end
    table.sort(classMenu, function (a, b) return a.name < b.name end)
    local name = string.join('-', UnitFullName('player'))
    local enabled = LM.Options:GetClassOption('PLAYER', useKey)
    table.insert(classMenu, 1, { name=name, key='PLAYER', id=0, color=WHITE_FONT_COLOR, enabled=enabled })
    -- GRAY, GREEN, HIGHLIGHT, ITEM_LEGENDARY, GOLD
    return classMenu
end

function LiteMountMacroPanelMixin:RefreshDisplay()
    local text, isEnabled, helpText = self:GetSettingsForTab()
    self.Macro.EditBox:SetText(text or "")
    self.Macro.EnableButton:SetChecked(isEnabled)
    self.Macro.ExplainText:SetText(helpText)

    local dp = CreateDataProvider(self:GenerateClassMenu())
    self.Class.ScrollBox:SetDataProvider(dp, ScrollBoxConstants.RetainScrollPosition)

    LiteMountSettingsPanelMixin.RefreshDisplay(self)
end

function LiteMountMacroPanelMixin:LoadSettings(t)
    LM.Macro:SetRawSettings(CopyTable(t))
end

function LiteMountMacroPanelMixin:LoadDefaultSettings()
    LM.Macro:SetDefaultSettings()
end
function LiteMountMacroPanelMixin:SaveSettings()
    return CopyTable(LM.Macro:GetRawSettings())
end

function LiteMountMacroPanelMixin:OnLoad()
    self.name = MACROS

    self.tabsGroup = CreateRadioButtonGroup()

    self.tabsGroup:AddButtons({ self.Tab1, self.Tab2 })
    self.tabsGroup:SelectAtIndex(1)
    self.tabsGroup:RegisterCallback(ButtonGroupBaseMixin.Event.Selected, self.SetTab, self)

    self.selectedTab = 1

    self.selectedClass = 'PLAYER'

    self.Macro.DeleteButton:SetScript("OnClick",
        function ()
            self.Macro.EditBox:SetText("")
            -- Need to call this directly because userInput is false in OnTextChanged
            self:WriteSettingsForTab()
        end)

    local view = CreateScrollBoxListLinearView(0, 0, 0, 0, 2)
    view:SetElementInitializer("LiteMountMacroListSelectButtonTemplate",
        function (button, elementData)
            local isSelected = self.selectedClass == elementData.key
            button.SelectedTexture:SetShown(isSelected)
            button.EnabledTexture:SetShown(elementData.enabled)
            button:SetText(elementData.color:WrapTextInColorCode(elementData.name))
            button:SetScript('OnClick', function () self:SetClass(elementData.key) end)
        end)
    ScrollUtil.InitScrollBoxListWithScrollBar(self.Class.ScrollBox, self.Class.ScrollBar, view)

    LiteMountSettingsPanelMixin.OnLoad(self)
end

function LiteMountMacroPanelMixin:SetTab(tab)
    self.selectedTab = tab:GetID()
    self:RefreshDisplay()
end

function LiteMountMacroPanelMixin:SetClass(c)
    self.selectedClass = c
    self:RefreshDisplay()
end
