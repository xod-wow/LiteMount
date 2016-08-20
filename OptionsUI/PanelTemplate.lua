--[[----------------------------------------------------------------------------

  LiteMount/OptionsUI/PanelTemplate.lua

  Copyright 2016 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

-- Recurse all children finding any FontStrings and replacing their texts
-- with localized copies.
function LM_OptionsUIPanel_AutoLocalize(f)
    if not L then return end

    local regions = { f:GetRegions() }
    for _,r in ipairs(regions) do
        if r and r:IsObjectType("FontString") and not r.autoLocalized then
            -- r:SetText(L[r:GetText()])
            r.autoLocalized = true
        end
    end

    local children = { f:GetChildren() }
    for _,c in ipairs(children) do
        if not c.autoLocalized then
            LM_OptionsUIPanel_AutoLocalize(c)
            c.autoLocalized = true
        end
    end
end

function LM_OptionsUIPanel_Open()
    local f = LM_OptionsUI
    if not f.CurrentOptionsPanel then
        f.CurrentOptionsPanel = LM_OptionsUIMounts
    end
    InterfaceOptionsFrame:Show()
    InterfaceOptionsFrame_OpenToCategory(f.CurrentOptionsPanel)
end


function LM_OptionsUIPanel_Refresh(self)
    LM_Debug("Panel_Refresh " .. self:GetName())
    for _,control in ipairs(self.controls or {}) do
        control:SetControl(control:GetOption())
    end
end

function LM_OptionsUIPanel_Default(self)
    LM_Debug("Panel_Default " .. self:GetName())
    for _,control in ipairs(self.controls or {}) do
        if control.GetOptionDefault then
            control:SetOption(control:GetOptionDefault())
        end
    end
end

function LM_OptionsUIPanel_Okay(self)
    LM_Debug("Panel_Okay " .. self:GetName())
    for i,control in ipairs(self.controls or {}) do
        control:SetOption(control:GetControl())
    end
end

function LM_OptionsUIPanel_Cancel(self)
    LM_Debug("Panel_Cancel " .. self:GetName())
end

function LM_OptionsUIPanel_RegisterControl(control, parent)
    parent = parent or control:GetParent()
    parent.controls = parent.controls or { }
    tinsert(parent.controls, control)
end

function LM_OptionsUIPanel_OnShow(self)
    LM_Debug("Panel_OnShow " .. self:GetName())
    LM_OptionsUI.CurrentOptionsPanel = self
    LM_OptionsUIPanel_Refresh(self)
end

function LM_OptionsUIPanel_OnLoad(self)
    LM_Debug("Panel_OnLoad " .. self:GetName())

    if self ~= LM_OptionsUI then
        self.parent = LM_OptionsUI.name
        if not self.name then
            local n = self:GetAttribute("panel-name")
            self.name = _G[n] or n
        end
        self.title:SetText("LiteMount : " .. self.name)
    else
        self.name = "LiteMount"
        self.title:SetText("LiteMount")
    end

    self.okay = self.okay or LM_OptionsUIPanel_Okay
    self.cancel = self.cancel or LM_OptionsUIPanel_Cancel
    self.default = self.default or LM_OptionsUIPanel_Default
    self.refresh = self.refresh or LM_OptionsUIPanel_Refresh

    LM_OptionsUIPanel_AutoLocalize(self)

    InterfaceOptions_AddCategory(self)
end

function LM_OptionsUIControl_GetControl(self)
    if self.GetValue then
        return self:GetValue()
    elseif self.GetChecked then
        return self:GetChecked()
    elseif self.GetText then
        return self:GetText()
    end
end

function LM_OptionsUIControl_SetControl(self, v)
    if self.SetValue then
        self:SetValue(v)
    elseif self.SetChecked then
        if v then self:SetChecked(true) else self:SetChecked(false) end
    elseif self.SetText then
        self:SetText(v or "")
    end
end

function LM_OptionsUIControl_OnLoad(self, parent)
    self.GetOption = self.GetOption or function (self) end
    self.SetOption = self.SetOption or function (self, v) end
    self.GetControl = self.GetControl or LM_OptionsUIControl_GetControl
    self.SetControl = self.SetControl or LM_OptionsUIControl_SetControl

    -- Note we don't set an OnShow per control, the panel handler takes care
    -- of running the refresh for all the controls in its OnShow

    LM_OptionsUIPanel_RegisterControl(self, parent)
end
