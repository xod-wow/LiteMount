--[[----------------------------------------------------------------------------

  LiteMount/UI/PanelTemplate.lua

  Copyright 2016-2020 Mike Battersby

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

function LiteMountOptionsPanel_Refresh(self, trigger, isProfileChange)
    LM_UIDebug(self, "Panel_Refresh")
    LM_UIDebug(self, "- trigger " .. tostring(trigger))
    for _,control in ipairs(self.controls or {}) do
        LiteMountOptionsControl_Refresh(control, trigger, isProfileChange)
    end
end

function LiteMountOptionsPanel_Default(self)
    LM_UIDebug(self, "Panel_Default")
    for _,control in ipairs(self.controls or {}) do
        LiteMountOptionsControl_Default(control)
    end
end

function LiteMountOptionsPanel_Okay(self)
    LM_UIDebug(self, "Panel_Okay")
    for _,control in ipairs(self.controls or {}) do
        LiteMountOptionsControl_Okay(control)
    end
end

function LiteMountOptionsPanel_Revert(self)
    LM_UIDebug(self, "Panel_Revert")
    for _,control in ipairs(self.controls or {}) do
        LiteMountOptionsControl_Revert(control)
    end
end

function LiteMountOptionsPanel_Cancel(self)
    LM_UIDebug(self, "Panel_Cancel")
    for _,control in ipairs(self.controls or {}) do
        LiteMountOptionsControl_Cancel(control)
    end
end

function LiteMountOptionsPanel_RegisterControl(control, parent)
    parent = parent or control:GetParent()
    parent.controls = parent.controls or { }
    tinsert(parent.controls, control)
end

function LiteMountOptionsPanel_OnShow(self)
    LM_UIDebug(self, "Panel_OnShow")
    LiteMountOptions.CurrentOptionsPanel = self

    if not self.dontShowProfile then
        LiteMountOptionsProfileDropDown_Attach(self)
    end

    -- LiteMountOptionsPanel_Refresh(self)

    LM_Options.db.RegisterCallback(self, "OnOptionsModified", "refresh")
end

function LiteMountOptionsPanel_OnHide(self)
    LM_UIDebug(self, "Panel_OnHide")

    LM_Options.db.UnregisterAllCallbacks(self)

    -- Seems like the InterfacePanel calls all the Okay or Cancel for
    -- anything that's been opened when the appropriate button is clicked
    -- LiteMountOptionsPanel_Okay(self)
end

function LiteMountOptionsPanel_OnLoad(self)

    if self ~= LiteMountOptions then
        self.parent = LiteMountOptions.name
        self.name = _G[self.name] or self.name
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

function LiteMountOptionsControl_Refresh(self, trigger, isProfileChange)
    LM_UIDebug(self, string.format("Control_Refresh t=%s i=%s",
                                   tostring(trigger),
                                   tostring(isProfileChange)))
    if isProfileChange or self.oldValues == nil then
        self.oldValues = table.wipe(self.oldValues or {})
        for i = 1, (self.ntabs or 1) do
            self.oldValues[i] = self:GetOption(i)
        end
        self.isDirty = nil
    end
    self:SetControl(self:GetOption(self.tab), self.tab)
end

function LiteMountOptionsControl_Okay(self)
    LM_UIDebug(self, "Control_Okay")
    self.oldValues = nil
    self.isDirty = nil
end

function LiteMountOptionsControl_Revert(self)
    LM_UIDebug(self, "Control_Revert")
    for i = 1, (self.ntabs or 1) do
        if self.oldValues[i] ~= nil then
            self:SetOption(self.oldValues[i], i)
        end
    end
    self.isDirty = nil
end

function LiteMountOptionsControl_Cancel(self)
    LM_UIDebug(self, "Control_Cancel")
    if self.isDirty then
        LiteMountOptionsControl_Revert(self)
    end
    self.oldValues = nil
end

function LiteMountOptionsControl_Default(self, onlyCurrentTab)
    if not self.GetOptionDefault then return end

    LM_UIDebug(self, "Control_Default "..tostring(onlyCurrentTab))

    if onlyCurrentTab then
        self:SetOption(self:GetOptionDefault(self.tab), self.tab)
    else
        for i = 1, (self.ntabs or 1) do
            self:SetOption(self:GetOptionDefault(i), i)
        end
    end
    self.isDirty = true
end

function LiteMountOptionsControl_OnChanged(self)
    LM_UIDebug(self, "Control_OnChanged")
    self:SetOption(self:GetControl(), self.tab)
    self.isDirty = true
end

function LiteMountOptionsControl_OnTextChanged(self, userInput)
    if userInput == true then
        LM_UIDebug(self, "Control_OnTextChanged")
        self:SetOption(self:GetControl(), self.tab)
    end
    self.isDirty = true
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

    self.tab = 1

    -- Note we don't set an OnShow per control, the panel handler takes care
    -- of running the refresh for all the controls in its OnShow

    LiteMountOptionsPanel_RegisterControl(self, parent)
end
