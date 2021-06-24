--[[----------------------------------------------------------------------------

  LiteMount/UI/Advanced.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local function BindingText(n)
    return format('%s %s', KEY_BINDING, n)
end

--[[--------------------------------------------------------------------------]]--

LiteMountAdvancedUnlockButtonMixin = {}

function LiteMountAdvancedUnlockButtonMixin:OnShow()
    local parent = self:GetParent()
    local editBox = parent.EditScroll.EditBox
    editBox:SetAlpha(0.5)
    editBox:Disable()
    parent.DefaultButton:Disable()
    self:SetFrameLevel(parent.RevertButton:GetFrameLevel() + 1)
end

function LiteMountAdvancedUnlockButtonMixin:OnClick()
    local parent = self:GetParent()
    local editBox = parent.EditScroll.EditBox
    editBox:SetAlpha(1.0)
    editBox:Enable()
    parent.DefaultButton:Enable()
    self:Hide()
end

--[[--------------------------------------------------------------------------]]--

local function BindingDropDown_Initialize(dropDown, level)
    local info = UIDropDownMenu_CreateInfo()
    local editBox = LiteMountAdvancedPanel.EditScroll.EditBox
    if level == 1 then
        for i = 1,4 do
            info.text = BindingText(i)
            info.arg1 = i
            info.arg2 = BindingText(i)
            info.func = function (button, v, t)
                    LiteMountOptionsControl_SetTab(editBox, v)
                    UIDropDownMenu_SetText(dropDown, t)
                end
            info.checked = (editBox.tab == i)
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

--[[--------------------------------------------------------------------------]]--

LiteMountAdvancedEditScrollMixin = {}

function LiteMountAdvancedEditScrollMixin:OnLoad()
    self.scrollBarHideable = 1
    self.ScrollBar:Hide()
end

function LiteMountAdvancedEditScrollMixin:OnShow()
    self.EditBox:SetWidth(self:GetWidth() - 18)
end

--[[--------------------------------------------------------------------------]]--

LiteMountAdvancedEditBoxMixin = {}

function LiteMountAdvancedEditBoxMixin:SetOption(v, i)
    LM.Options:SetButtonAction(i, v)
end

function LiteMountAdvancedEditBoxMixin:GetOption(i)
    return LM.Options:GetButtonAction(i)
end

function LiteMountAdvancedEditBoxMixin:GetOptionDefault()
    return LM.Options:GetButtonAction('__default__')
end

function LiteMountAdvancedEditBoxMixin:OnLoad()
    self.ntabs = 4
end

--[[--------------------------------------------------------------------------]]--

LiteMountAdvancedPanelMixin = {}

function LiteMountAdvancedPanelMixin:OnLoad()
    self.name = ADVANCED_OPTIONS

    LiteMountOptionsPanel_RegisterControl(self.EditScroll.EditBox, self)

    UIDropDownMenu_Initialize(self.BindingDropDown, BindingDropDown_Initialize)
    UIDropDownMenu_SetText(self.BindingDropDown, BindingText(1))

    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountAdvancedPanelMixin:OnShow()
    self.UnlockButton:Show()
end
