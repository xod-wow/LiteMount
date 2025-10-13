--[[----------------------------------------------------------------------------

  LiteMount/UI/Macro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

LiteMountMacroEditBoxMixin = {}

function LiteMountMacroEditBoxMixin:OnTextChanged(userInput)
    local c = strlen(self:GetText() or "")
    self:GetParent().Count:SetText(format(MACROFRAME_CHAR_LIMIT, c))
    LiteMountOptionsControl_OnTextChanged(self, userInput)
end

function LiteMountMacroEditBoxMixin:GetOption()
    return LM.Options:GetOption('unavailableMacro') or ""
end
function LiteMountMacroEditBoxMixin:GetOptionDefault()
    return LM.Options:GetOptionDefault('unavailableMacro')
end

function LiteMountMacroEditBoxMixin:SetOption(v)
    LM.Options:SetOption('unavailableMacro', v)
end

--[[------------------------------------------------------------------------]]--

LiteMountMacroTabMixin = {}

function LiteMountMacroTabMixin:OnClick()
    self:GetParent():SetTab(self:GetID())
end

--[[------------------------------------------------------------------------]]--

LiteMountMacroPanelMixin = {}

function LiteMountMacroPanelMixin:Update()
    local selectedTab = PanelTemplates_GetSelectedTab(self)
    if selectedTab == 1 then
        self.Macro.ExplainText:SetText(L.LM_MACRO_EXP)
    else
        self.Macro.ExplainText:SetText(L.LM_COMBAT_MACRO_EXP)
    end

    local dp = CreateDataProvider(self.classMenu)
    self.Class.ScrollBox:SetDataProvider(dp, ScrollBoxConstants.RetainScrollPosition)
end

function LiteMountMacroPanelMixin:OnLoad()
    self.name = MACRO .. " : " .. UNAVAILABLE

    LiteMountOptionsPanel_RegisterControl(self.Macro.EditBox)

    PanelTemplates_SetNumTabs(self, 2)
    PanelTemplates_AnchorTabs(self)
    PanelTemplates_ResizeTabsToFit(self)
    PanelTemplates_SetTab(self, 1)

    local layout = NineSliceUtil.GetLayout("ChatBubble")
    NineSliceUtil.ApplyLayout(self.Macro.EditBox.NineSlice, layout);

    self.selectedClass = 'PLAYER'

    self.Macro.DeleteButton:SetScript("OnClick",
            function () self.Macro.EditBox:SetOption("") end)

    local view = CreateScrollBoxListLinearView(0, 0, 0, 0, 2)
    view:SetElementInitializer("LiteMountListSelectButtonTemplate",
        function (button, elementData)
            local isSelected = self.selectedClass == elementData.key
            button.SelectedTexture:SetShown(isSelected)
            button:SetText(elementData.color:WrapTextInColorCode(elementData.name))
            button:SetScript('OnClick', function () self:SetClass(elementData.key) end)
        end)
    ScrollUtil.InitScrollBoxListWithScrollBar(self.Class.ScrollBox, self.Class.ScrollBar, view)

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

    self:Update()
end

function LiteMountMacroPanelMixin:SetTab(id)
    PanelTemplates_SetTab(self, id)
    self:Update()
end

function LiteMountMacroPanelMixin:SetClass(c)
    self.selectedClass = c
    self:Update()
end
