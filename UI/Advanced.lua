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

function LiteMountAdvancedPanelMixin:LoadSettings(sets)
    local dontFire = true
    for i = 1, self.ntabs do
        LM.Options:SetButtonRuleSet(i, sets[i], dontFire)
    end
end

function LiteMountAdvancedPanelMixin:SaveSettings(i)
    local sets = {}
    for i = 1, self.ntabs do
        sets[i] = LM.Options:GetButtonRuleSet(i)
    end
    return sets
end

function LiteMountAdvancedPanelMixin:LoadDefaultSettings()
    local rules = LM.Options:GetButtonRuleSet('__default__')
    local dontFire = true
    for i = 1, self.ntabs or 1 do
        LM.Options:SetButtonRuleSet(i, rules, dontFire)
    end
end

function LiteMountAdvancedPanelMixin:RefreshDisplay()
    local rulesText = LM.Options:GetButtonRuleSet(self.tab)
    self.EditScroll.ScrollBox.EditBox:SetText(rulesText)
    self:CheckCompileErrors(rulesText)
    LiteMountOptionsPanelMixin.RefreshDisplay(self)
end

function LiteMountAdvancedPanelMixin:OnLoad()
    self.name = ADVANCED_OPTIONS
    self.ntabs = 4
    self.tab = 1

    local editBox = self.EditScroll.ScrollBox.EditBox
    editBox:SetFontObject(LiteMountMonoFont)
    editBox:SetScript('OnTextChanged',
        function (_, userInput)
            if userInput == true then
                LM.UIDebug(self, "Control_OnTextChanged")
                self:MarkDirty()
                LM.Options:SetButtonRuleSet(self.tab, editBox:GetText())
                -- dontFire isn't set, so no need to RefreshDisplay
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
