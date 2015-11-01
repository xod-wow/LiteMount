--[[----------------------------------------------------------------------------

  LiteMount/UIOptionsPanelTemplate.lua

  Copyright 2015 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

-- Recurse all children finding any FontStrings and replacing their texts
-- with localized copies.
function LiteMountOptionsPanel_AutoLocalize(f)
    if not L then return end

    local regions = { f:GetRegions() }
    for _,r in ipairs(regions) do
        if r and r:IsObjectType("FontString") and not r.autoLocalized then
            r:SetText(L[r:GetText()])
            r.autoLocalized = true
        end
    end

    local children = { f:GetChildren() }
    for _,c in ipairs(children) do
        if not c.autoLocalized then
            LiteMountOptionsPanel_AutoLocalize(c)
            c.autoLocalized = true
        end
    end
end

function LiteMountOptionsPanel_Open()
    local f = LiteMountOptions
    if not f.CurrentOptionsPanel then
        f.CurrentOptionsPanel = LiteMountOptionsMounts
    end
    InterfaceOptionsFrame:Show()
    InterfaceOptionsFrame_OpenToCategory(f.CurrentOptionsPanel)
end


function LiteMountOptionsPanel_Refresh(self)
    LM_Debug("Panel_Refresh " .. self:GetName())
    for _,control in ipairs(self.controls or {}) do
        control:SetControl(control:GetOption())
    end
end

function LiteMountOptionsPanel_Default(self)
    LM_Debug("Panel_Default " .. self:GetName())
    for _,control in ipairs(self.controls or {}) do
        if control.GetOptionDefault then
            control:SetOption(control:GetOptionDefault())
        end
    end
end

function LiteMountOptionsPanel_Okay(self)
    LM_Debug("Panel_Okay " .. self:GetName())
    for i,control in ipairs(self.controls or {}) do
        control:SetOption(control:GetControl())
    end
end

function LiteMountOptionsPanel_Cancel(self)
    LM_Debug("Panel_Cancel " .. self:GetName())
end

function LiteMountOptionsPanel_RegisterControl(control, parent)
    parent = parent or control:GetParent()
    parent.controls = parent.controls or { }
    tinsert(parent.controls, control)
end

function LiteMountOptionsPanel_OnShow(self)
    LM_Debug("Panel_OnShow " .. self:GetName())
    LiteMountOptions.CurrentOptionsPanel = self
    LiteMountOptionsPanel_Refresh(self)
end

function LiteMountOptionsPanel_OnLoad(self)
    LM_Debug("Panel_OnLoad " .. self:GetName())

    if self ~= LiteMountOptions then
        self.parent = LiteMountOptions.name
        if not self.name then
            local n = self:GetAttribute("panel-name")
            self.name = _G[n] or n
        end
        self.title:SetText("LiteMount : " .. self.name)
    else
        self.name = "LiteMount"
        self.title:SetText("LiteMount")
    end

    self.okay = self.okay or LiteMountOptionsPanel_Okay
    self.cancel = self.cancel or LiteMountOptionsPanel_Cancel
    self.default = self.default or LiteMountOptionsPanel_Default
    self.refresh = self.refresh or LiteMountOptionsPanel_Refresh

    LiteMountOptionsPanel_AutoLocalize(self)

    InterfaceOptions_AddCategory(self)
end

function LiteMountOptionsControl_GetControl(self)
    if self.GetValue then
        return self:GetValue()
    elseif self.GetChecked then
        return self:GetChecked()
    elseif self.GetText then
        self:GetText()
    end
end

function LiteMountOptionsControl_SetControl(self, v)
    if self.SetValue then
        self:SetValue(v)
    elseif self.SetChecked then
        if v then self:SetChecked(true) else self:SetChecked(false) end
    elseif self.SetText then
        self:SetText(v or "")
    end
end

function LiteMountOptionsControl_OnLoad(self, parent)
    self.GetOption = self.GetOption or function (self) end
    self.SetOption = self.SetOption or function (self, v) end
    self.GetControl = self.GetControl or LiteMountOptionsControl_GetControl
    self.SetControl = self.SetControl or LiteMountOptionsControl_SetControl

    -- Note we don't set an OnShow per control, the panel handler takes care
    -- of running the refresh for all the controls in its OnShow

    LiteMountOptionsPanel_RegisterControl(self, parent)
end
