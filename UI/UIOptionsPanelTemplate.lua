--[[----------------------------------------------------------------------------

  LiteMount/UIOptionsPanelTemplate.lua

  Copyright 2015 Mike Battersby

----------------------------------------------------------------------------]]--

function LiteMountOptionsPanel_Refresh(self)
    for _, control in next, self.controls do
        control:SetControl(control:GetOption())
    end
end

function LiteMountOptionsPanel_Default(self)
    for _, control in next, self.controls do
        control:SetControl(control:GetOptionDefault())
    end
end

function LiteMountOptionsPanel_Okay(self)
    for _, control in next, self.controls do
        control:SetOption(control:GetControl())
    end
end

function LiteMountOptionsPanel_Cancel(self)
end

function LiteMountOptionsPanel_RegisterControl(control, parent)
    parent = parent or control:GetParent()
    parent.controls = parent.controls or { }
    tinsert(parent.controls, control)
end

function LiteMountOptionsPanel_OnShow(self)
    LiteMountOptions.CurrentOptionsPanel = self
    LiteMountOptionsPanel_Refresh(self)
end

function LiteMountOptionsPanel_OnLoad(self)

    LiteMount_Frame_AutoLocalize(self)

    self.parent = LiteMountOptions.name
    self.name = self:GetAttribute("panel-name")
    self.title:SetText("LiteMount : " .. self.name)

    self.okay = self.okay or LiteMountOptionsPanel_Okay
    self.cancel = self.cancel or LiteMountOptionsPanel_Cancel
    self.default = self.default or LiteMountOptionsPanel_Default
    self.refresh = self.refresh or LiteMountOptionsPanel_Refresh

    InterfaceOptions_AddCategory(self)
end

function LiteMountOptionsControl_GetValue(self, v)
    if self.GetValue then
        return self:GetValue()
    elseif self.GetChecked then
        return self:GetChecked()
    elseif self.GetText then
        self:GetText()
    end
end

function LiteMountOptionsControl_SetValue(self, v)
    if self.SetValue then
        self:SetValue(v)
    elseif self.SetChecked then
        if v then self:SetChecked(true) else self:SetChecked(false) end
    elseif self.SetText then
        self:SetText(v or "")
    end
end

function LiteMountOptionsControl_Okay(self)
    self.SetOption(LiteMountOptionsControl_GetValue(self))
end

function LiteMountOptionsControl_Refresh(self)
    local v = self.GetOption()
    LiteMountOptionsControl_SetValue(self, v)
    self.oldValue = v
end

function LiteMountOptionsControl_Cancel(self)
end

function LiteMountOptionsControl_Default(self)
    LiteMountOptionsControl_SetValue(self, self.defaultValue)
end

function LiteMountOptionsControl_OnLoad(self, parent)
    self.GetOption = self.GetOption or function () end
    self.GetOptionDefault = self.GetOptionDefault or function () end
    self.SetOption = self.SetOption or function (v) end
    self.GetControl = self.GetControl or LiteMountOptionsControl_Get
    self.SetControl = self.SetControl or LiteMountOptionsControl_Set

    -- Note we don't set an OnShow per control, the panel handler takes care
    -- of running the refresh for all the controls in its OnShow

    LiteMountOptionsPanel_RegisterControl(self, parent)
end
