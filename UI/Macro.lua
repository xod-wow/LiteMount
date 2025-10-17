--[[----------------------------------------------------------------------------

  LiteMount/UI/Macro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

--[[------------------------------------------------------------------------]]--

LiteMountMacroEditBoxMixin = {}

function LiteMountMacroEditBoxMixin:OnTextChanged(userInput)
    local parent = self:GetParent()
    local c = strlen(self:GetText())
    parent.Count:SetText(format(MACROFRAME_CHAR_LIMIT, c))
    local text = self:GetText()
    local isCombat, class = LiteMountMacroPanel.selectedClass
    if LiteMountMacroPanel:IsDefaultMacro(text) then
        self:SetTextColor(0.5, 0.5, 0.5)
        if userInput then
            LiteMountMacroPanel:SetAppropriateMacro(nil)
        end
    else
        self:SetTextColor(1, 1, 1)
        if userInput then
            LiteMountMacroPanel:SetAppropriateMacro(text)
        end
    end
end

--[[------------------------------------------------------------------------]]--

LiteMountMacroEnableButtonMixin = {}

function LiteMountMacroEnableButtonMixin:OnClick()
    LiteMountMacroPanel:SetAppropriateEnabled(self:GetChecked())
end

--[[------------------------------------------------------------------------]]--

LiteMountMacroTabMixin = {}

function LiteMountMacroTabMixin:OnClick()
    self:GetParent():SetTab(self:GetID())
end

--[[------------------------------------------------------------------------]]--

LiteMountMacroPanelMixin = {}

local OptionKeyByTab = {
    [1] = 'unavailableMacro',
    [2] = 'combatMacro',
}

function LiteMountMacroPanelMixin:SetControl()
    self:Update()
end

function LiteMountMacroPanelMixin:GetAppropriateEnabled()
    local isCombat = PanelTemplates_GetSelectedTab(self) == 2
    return LM.Macro:GetEnabledOption(isCombat, self.selectedClass)
        or LM.Macro:GetEnabledOptionDefault(isCombat, self.selectedClass)
end

function LiteMountMacroPanelMixin:SetAppropriateEnabled(v)
    local isCombat = PanelTemplates_GetSelectedTab(self) == 2
    self.isDirty = true
    return LM.Macro:SetEnabledOption(isCombat, self.selectedClass, v)
end

function LiteMountMacroPanelMixin:GetAppropriateMacro()
    local isCombat = PanelTemplates_GetSelectedTab(self) == 2
    return LM.Macro:GetMacroOption(isCombat, self.selectedClass)
        or LM.Macro:GetMacroOptionDefault(isCombat, self.selectedClass)
end

function LiteMountMacroPanelMixin:SetAppropriateMacro(text)
    local isCombat = PanelTemplates_GetSelectedTab(self) == 2
    self.isDirty = true
    if text == "" then text = nil end
    return LM.Macro:SetMacroOption(isCombat, self.selectedClass, text)
end

function LiteMountMacroPanelMixin:IsDefaultMacro(text)
    local isCombat = PanelTemplates_GetSelectedTab(self) == 2
    local default = LM.Macro:GetMacroOptionDefault(isCombat, self.selectedClass)
    return text == default
end

function LiteMountMacroPanelMixin:Update()
    local selectedTab = PanelTemplates_GetSelectedTab(self)
    local optionKey = OptionKeyByTab[selectedTab]

    local text = self:GetAppropriateMacro()
    self.Macro.EditBox:SetText(text or "")

    local isEnabled = self:GetAppropriateEnabled()
    self.Macro.EnableButton:SetChecked(isEnabled)

    if selectedTab == 1 then
        self.Macro.ExplainText:SetText(L.LM_MACRO_EXP)
    else
        self.Macro.ExplainText:SetText(L.LM_COMBAT_MACRO_EXP)
    end

    local dp = CreateDataProvider(self.classMenu)
    self.Class.ScrollBox:SetDataProvider(dp, ScrollBoxConstants.RetainScrollPosition)
end

function LiteMountMacroPanelMixin:SetOption(t)
    local classKey = select(2, UnitClass('player'))
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

    local layout = NineSliceUtil.GetLayout("ChatBubble")
    NineSliceUtil.ApplyLayout(self.Macro.EditBox.NineSlice, layout);

    self.selectedClass = 'PLAYER'

    self.Macro.DeleteButton:SetScript("OnClick", function () self:SetAppropriateMacro(nil) end)

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
    LiteMountOptionsPanel_OnLoad(self)
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
