--[[----------------------------------------------------------------------------

  LiteMount/UI/Advanced.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

--[[------------------------------------------------------------------------]]--

LiteMountRulesTabAdvancedMixin = {}

function LiteMountRulesTabAdvancedMixin:GetBindingIndex()
    local parent = self:GetParent()
    return parent.tab or 1
end

function LiteMountRulesTabAdvancedMixin:CheckCompileErrors()
    local text = self.EditScroll:GetText()
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

function LiteMountRulesTabAdvancedMixin:Refresh()
    local bindingIndex = self:GetBindingIndex()
    local text = LM.Options:GetButtonRuleSet(bindingIndex)
    -- if text ~= self.EditScroll:GetText() then
        self.EditScroll:SetText(text)
    -- end
end

function LiteMountRulesTabAdvancedMixin:OnLoad()
    local editBox = self.EditScroll.ScrollBox.EditBox
    editBox:SetScript('OnTextChanged',
        function (_, userInput)
            if userInput then
                self:GetParent().isDirty = true
                if self:CheckCompileErrors() then
                    local bindingIndex = self:GetBindingIndex()
                    local text = editBox:GetText()
                    LM.Options:SetButtonRuleSet(bindingIndex, text)
                end
            end
        end)

    ScrollUtil.RegisterScrollBoxWithScrollBar(self.EditScroll.ScrollBox, self.ScrollBar)
end
