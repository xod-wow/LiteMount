--[[----------------------------------------------------------------------------

  LiteMount/UI/Actions.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local function BindingText(n)
    return format('%s %s', KEY_BINDING, n)
end

--[[--------------------------------------------------------------------------]]--

LiteMountActionsButtonMixin = {}

function LiteMountActionsButtonMixin:OnShow()
    self:SetWidth(self:GetParent():GetWidth())
end

--[[--------------------------------------------------------------------------]]--

LiteMountActionsScrollMixin = {}

LoadAddOn('Blizzard_DebugTools')

function LiteMountActionsScrollMixin:Update()
    if not self.buttons then return end

    local offset = HybridScrollFrame_GetOffset(self)

    local text = LM.Options:GetButtonAction(self.tab)

    local actions = LM.ActionList:Compile(text)

    local totalHeight = #actions * self.buttons[1]:GetHeight()
    local displayedHeight = #self.buttons * self.buttons[1]:GetHeight()

    for i = 1, #self.buttons do
        local button = self.buttons[i]
        local index = offset + i
        if index <= #actions then
            local action = actions[index]
            button.NumText:SetText(index)
            button.ActionText:SetText(action.line)
            button:Show()
        else
            button:Hide()
        end
    end

    HybridScrollFrame_Update(self, totalHeight, displayedHeight)
end

function LiteMountActionsScrollMixin:OnShow()
    self.EditBox:SetWidth(self:GetWidth() - 18)
end

function LiteMountActionsScrollMixin:SetOption(v, i)
end

function LiteMountActionsScrollMixin:GetOption(i)
    return LM.Options:GetButtonAction(i)
end

function LiteMountActionsScrollMixin:GetOptionDefault()
    return LM.Options:GetButtonAction('*')
end

function LiteMountActionsScrollMixin:OnLoad()
    local track = _G[self.scrollBar:GetName().."Track"]
    track:Hide()
    self.ntabs = 4
    self.update = self.Update
    self.SetControl = self.Update
end

--[[--------------------------------------------------------------------------]]--

local function BindingDropDown_Initialize(dropDown, level)
    local info = UIDropDownMenu_CreateInfo()
    local scroll = LiteMountActionsPanel.Scroll
    if level == 1 then
        for i = 1,4 do
            info.text = BindingText(i)
            info.arg1 = i
            info.arg2 = BindingText(i)
            info.func = function (button, v, t)
                    LiteMountOptionsControl_SetTab(scroll, v)
                    UIDropDownMenu_SetText(dropDown, t)
                end
            info.checked = (scroll.tab == i)
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

--[[--------------------------------------------------------------------------]]--

LiteMountActionsPanelMixin = {}

function LiteMountActionsPanelMixin:OnSizeChanged(x, y)
    HybridScrollFrame_CreateButtons(
            self.Scroll,
            "LiteMountActionsButtonTemplate",
            0, 0, "TOPLEFT", "TOPLEFT",
            0, 0, "TOP", "BOTTOM"
        )
    self.Scroll:Update()
end

function LiteMountActionsPanelMixin:OnLoad()
    self.name = "Actions"

    LiteMountOptionsPanel_RegisterControl(self.Scroll)

    UIDropDownMenu_Initialize(self.BindingDropDown, BindingDropDown_Initialize)
    UIDropDownMenu_SetText(self.BindingDropDown, BindingText(1))

    LiteMountOptionsPanel_OnLoad(self)
end
