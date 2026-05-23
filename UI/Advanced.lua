--[[----------------------------------------------------------------------------

  LiteMount/UI/Advanced.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.L

local function BindingText(n)
    return format('%s %s', KEY_BINDING, n)
end

--[[------------------------------------------------------------------------]]--

LiteMountAdvancedUnlockButtonMixin = {}

function LiteMountAdvancedUnlockButtonMixin:OnShow()
    local parent = self:GetParent()
    local editBox = parent.EditScroll.ScrollBox.EditBox
    editBox:SetAlpha(0.5)
    editBox:Disable()
    parent.DefaultsButton:Disable()
    self:SetFrameLevel(parent.RevertButton:GetFrameLevel() + 1)
end

function LiteMountAdvancedUnlockButtonMixin:OnClick()
    local parent = self:GetParent()
    local editBox = parent.EditScroll.ScrollBox.EditBox
    editBox:SetAlpha(1.0)
    editBox:Enable()
    parent.DefaultsButton:Enable()
    self:Hide()
end

--[[------------------------------------------------------------------------]]--

local function BindingGenerator(owner, rootDescription)
    local self = LiteMountAdvancedPanel
    local IsSelected = function (v) return self.tab == v end
    local SetSelected = function (v) self:SetTab(v) end
    for i = 1, self.ntabs do
        rootDescription:CreateRadio(BindingText(i), IsSelected, SetSelected, i)
    end
end

--[[------------------------------------------------------------------------]]--

LiteMountAdvancedPanelMixin = {}

function LiteMountAdvancedPanelMixin:CheckCompileErrors(text)
    local ruleset = LM.RuleSet:Compile(text)
    if ruleset.errors then
        -- It's possible we should just show the first one
        local errs = LM.tMap(ruleset.errors, function (info) return info.err end)
        local msg = table.concat(errs, "\n")
        self.ErrorMessage:SetText(msg)
        self.ErrorMessage:Show()
        return false
    else
        self.ErrorMessage:Hide()
        return true
    end
end

function LiteMountAdvancedPanelMixin:SetOption(v, i)
    if self:CheckCompileErrors(v) then
        LM.Options:SetButtonRuleSet(i, v)
    end
end

function LiteMountAdvancedPanelMixin:GetOption(i)
    return LM.Options:GetButtonRuleSet(i)
end

function LiteMountAdvancedPanelMixin:GetOptionDefault()
    return LM.Options:GetButtonRuleSet('__default__')
end

function LiteMountAdvancedPanelMixin:RefreshDisplay()
    local rulesText = LM.Options:GetButtonRuleSet(self.tab)
    self.EditScroll.ScrollBox.EditBox:SetText(rulesText)
    self:CheckCompileErrors(rulesText)
end

function LiteMountAdvancedPanelMixin:OnLoad()
    self.name = ADVANCED_OPTIONS
    self.ntabs = 4
    self.tab = 1

    local editBox = self.EditScroll.ScrollBox.EditBox
    editBox:SetFontObject(LiteMountMonoFont)
    editBox:SetScript('OnTextChanged',
        function (_, userInput)
            self.isDirty = true
            if userInput == true then
                LM.UIDebug(self, "Control_OnTextChanged")
                self:SetOption(editBox:GetText(), self.tab)
            end
        end)
    self.BindingDropDown:SetupMenu(BindingGenerator)

    ScrollUtil.RegisterScrollBoxWithScrollBar(self.EditScroll.ScrollBox, self.ScrollBar)
    LiteMountOptionsPanelMixin.OnLoad(self)
end

function LiteMountAdvancedPanelMixin:OnShow()
    self.UnlockButton:Show()
    LiteMountOptionsPanelMixin.OnShow(self)
end
