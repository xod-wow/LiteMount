--[[----------------------------------------------------------------------------

  LiteMount/PanelTemplate.lua

  Copyright 2016-2017 Mike Battersby

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
        for i = 1, (control.ntabs or 1) do
            if control.oldValues[i] == nil then
                control.oldValues[i] = control:GetOption(i)
            end
        end
        local cur = control.tab
        control:SetControl(control.oldValues[cur], cur)
    end
end

function LiteMountOptionsPanel_Default(self)
    LM_Debug("Panel_Default " .. self:GetName())
    for _,control in ipairs(self.controls or {}) do
        for i = 1, (control.ntabs or 1) do
            if control.GetOptionDefault then
                control:SetOption(control:GetOptionDefault(i), i)
            end
        end
    end
end

function LiteMountOptionsPanel_Okay(self)
    LM_Debug("Panel_Okay " .. self:GetName())
    for _,control in ipairs(self.controls or {}) do
        wipe(control.oldValues)
    end
end

function LiteMountOptionsPanel_Cancel(self)
    LM_Debug("Panel_Cancel " .. self:GetName())
    for _,control in ipairs(self.controls or {}) do
        for i = 1, (control.ntabs or 1) do
            if control.oldValues[i] ~= nil then
                control:SetOption(control.oldValues[i], i)
            end
            wipe(control.oldValues)
        end
    end
end

function LiteMountOptionsPanel_RegisterControl(control, parent)
    parent = parent or control:GetParent()
    parent.controls = parent.controls or { }
    tinsert(parent.controls, control)
end

function LiteMountOptionsPanel_OnShow(self)
    LM_Debug("Panel_OnShow " .. self:GetName())
    LiteMountOptions.CurrentOptionsPanel = self
    LiteMountOptionsProfileDropDown_Attach(self)
    LiteMountOptionsPanel_Refresh(self)
end

function LiteMountOptionsPanel_OnHide(self)
    LM_Debug("Panel_OnHide " .. self:GetName())
    LiteMountOptionsPanel_Okay(self)
end

function LiteMountOptionsPanel_OnLoad(self)
    if self ~= LiteMountOptions then
        self.parent = LiteMountOptions.name
        if not self.name then
            local n = self:GetAttribute("panel-name")
            self.name = _G[n] or n
        end
        self.Title:SetText("LiteMount : " .. self.name)
    else
        self.name = "LiteMount"
        self.Title:SetText("LiteMount")
    end

    self.okay = self.okay or LiteMountOptionsPanel_Okay
    self.cancel = self.cancel or LiteMountOptionsPanel_Cancel
    self.default = self.default or LiteMountOptionsPanel_Default
    self.refresh = self.refresh or LiteMountOptionsPanel_Refresh

    LiteMountOptionsPanel_AutoLocalize(self)

    InterfaceOptions_AddCategory(self)
end

function LiteMountOptionsControl_OnChanged(self)
    self:SetOption(self:GetControl(), self.tab)
end

function LiteMountOptionsControl_SetTab(self, n)
    self.tab = n
    self:SetControl(self:GetOption(n))
end

function LiteMountOptionsControl_GetControl(self)
    if self.GetValue then
        return self:GetValue()
    elseif self.GetChecked then
        return self:GetChecked()
    elseif self.GetText then
        return self:GetText()
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
    self.SetOption = self.SetOption or function (self, v, i) end
    self.GetControl = self.GetControl or LiteMountOptionsControl_GetControl
    self.SetControl = self.SetControl or LiteMountOptionsControl_SetControl

    self.oldValues = { }
    self.tab = 1

    -- Note we don't set an OnShow per control, the panel handler takes care
    -- of running the refresh for all the controls in its OnShow

    LiteMountOptionsPanel_RegisterControl(self, parent)
end