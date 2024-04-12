--[[----------------------------------------------------------------------------

  LiteMount/UI/Advanced.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local LibDD = LibStub("LibUIDropDownMenu-4.0")

local function BindingText(n)
    return format('%s %s', KEY_BINDING, n)
end

--[[------------------------------------------------------------------------]]--

LiteMountAdvancedUnlockButtonMixin = {}

function LiteMountAdvancedUnlockButtonMixin:OnShow()
    local parent = self:GetParent()
    local editBox = parent.EditScroll.EditBox
    editBox:SetAlpha(0.5)
    editBox:Disable()
    parent.DefaultsButton:Disable()
    self:SetFrameLevel(parent.RevertButton:GetFrameLevel() + 1)
end

function LiteMountAdvancedUnlockButtonMixin:OnClick()
    local parent = self:GetParent()
    local editBox = parent.EditScroll.EditBox
    editBox:SetAlpha(1.0)
    editBox:Enable()
    parent.DefaultsButton:Enable()
    self:Hide()
end

--[[------------------------------------------------------------------------]]--

local function BindingDropDown_Initialize(dropDown, level)
    local info = LibDD:UIDropDownMenu_CreateInfo()
    local editBox = LiteMountAdvancedPanel.EditScroll.EditBox
    if level == 1 then
        for i = 1,4 do
            info.text = BindingText(i)
            info.arg1 = i
            info.arg2 = BindingText(i)
            info.func = function (button, v, t)
                    LiteMountOptionsControl_SetTab(editBox, v)
                    LibDD:UIDropDownMenu_SetText(dropDown, t)
                end
            info.checked = (editBox.tab == i)
            LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end
end

--[[------------------------------------------------------------------------]]--

LiteMountAdvancedEditScrollMixin = {}

function LiteMountAdvancedEditScrollMixin:OnLoad()
    self.scrollBarHideable = 1
    self.ScrollBar:Hide()
end

function LiteMountAdvancedEditScrollMixin:OnShow()
    self.EditBox:SetWidth(self:GetWidth() - 18)
end

--[[------------------------------------------------------------------------]]--

LiteMountAdvancedEditBoxMixin = {}

function LiteMountAdvancedEditBoxMixin:CheckCompileErrors()
    local parent = self:GetParent()
    local ruleset = LM.RuleSet:Compile(self:GetText())
    if ruleset.errors then
        local info = ruleset.errors[1]
        local msg = format(L.LM_ERR_BAD_RULE, info.line, info.err)
        parent.ErrorMessage:SetText(msg)
        parent.ErrorMessage:Show()
        return false
    else
        parent.ErrorMessage:Hide()
        return true
    end
end

function LiteMountAdvancedEditBoxMixin:SetOption(v, i)
    if self:CheckCompileErrors() then
        LM.Options:SetButtonRuleSet(i, v)
    end
end

function LiteMountAdvancedEditBoxMixin:GetOption(i)
    return LM.Options:GetButtonRuleSet(i)
end

function LiteMountAdvancedEditBoxMixin:GetOptionDefault()
    return LM.Options:GetButtonRuleSet('__default__')
end

function LiteMountAdvancedEditBoxMixin:OnLoad()
    self.ntabs = 4
end

--[[------------------------------------------------------------------------]]--

LiteMountAdvancedPanelMixin = {}

function LiteMountAdvancedPanelMixin:OnLoad()
    self.name = ADVANCED_OPTIONS
    LibDD:Create_UIDropDownMenu(self.BindingDropDown)
    LiteMountOptionsPanel_RegisterControl(self.EditScroll.EditBox, self)
    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountAdvancedPanelMixin:OnShow()
    local text = BindingText(self.EditScroll.EditBox.tab)
    LibDD:UIDropDownMenu_Initialize(self.BindingDropDown, BindingDropDown_Initialize)
    LibDD:UIDropDownMenu_SetText(self.BindingDropDown, text)
    self.EditScroll.EditBox:CheckCompileErrors()
    self.UnlockButton:Show()
end
