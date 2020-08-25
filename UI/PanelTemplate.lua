--[[----------------------------------------------------------------------------

  LiteMount/UI/PanelTemplate.lua

  Copyright 2016-2020 Mike Battersby

  This is inspired by the Blizzard options panel code, but instead of saving
  the current values of settings and applying them whenk Okay is clicked, it
  applies them immediately and backs them out when you click Cancel.

  Create an options panel from like this

  <Frame name=... hidden="true" inherits="LiteMountOptionsPanelTemplate">

  The OnLoad handler must call LiteMountOptionsPanel_OnLoad(self).

  Inside the panel define controls which can have these methods
    GetOption()
    GetOptionDefault()
    SetOption(v)
    GetControl()
    SetControl(v)

  Call LiteMountOptionsPanel_RegisterControl(control, [panel]) for each one.
  If panel is the direct parent of control then it can be omitted.

  There are inbuilt versions of Get/SetControl that work for CheckButton and
  TextEdit widgets. And maybe Slider, I can't remember.

  When a control is changed call LiteMountOptionsControl_OnChanged(self)
  which will do SetOption(GetControl()). Alternatively handle it natively
  and set control.isDirty = true when it has changed and needs to be backed
  out when Cancel is clicked.

  SetControl does not necessarily need to use the v passed to it, it can
  read all of the settings itself. Nor do SetOption or OnChanged need to
  be used when things are modified, as long as isDirty is maintained. This
  allows use of GetOption/SetOption just for the undo functionality.

  Don't refresh any of UI elements that are controls. The panel has a callback
  into LM.Options.db that redraws when anything is modified and handles the
  profile switching.

  In an ideal world most of this would be replaced with an AceDB that has a
  snapshot and restore capability.

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

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
        f.CurrentOptionsPanel = LiteMountMountsPanel
    end
    InterfaceOptionsFrame:Show()
    InterfaceOptionsFrame_OpenToCategory(f.CurrentOptionsPanel)
end

function LiteMountOptionsPanel_Reset(self, trigger)
    LM.UIDebug(self, "Panel_Reset t="..tostring(trigger))
    for _,control in ipairs(self.controls or {}) do
        LiteMountOptionsControl_Okay(control, trigger)
        LiteMountOptionsControl_Refresh(control, trigger)
    end
end

function LiteMountOptionsPanel_Refresh(self, trigger)
    LM.UIDebug(self, "Panel_Refresh t="..tostring(trigger))
    for _,control in ipairs(self.controls or {}) do
        LiteMountOptionsControl_Refresh(control, trigger)
    end
    LM.Options.db.RegisterCallback(self, "OnOptionsModified", "refresh")
    LM.Options.db.RegisterCallback(self, "OnOptionsProfile", "reset")
end

function LiteMountOptionsPanel_Default(self)
    LM.UIDebug(self, "Panel_Default")
    for _,control in ipairs(self.controls or {}) do
        LiteMountOptionsControl_Default(control)
    end
end

function LiteMountOptionsPanel_Okay(self)
    LM.UIDebug(self, "Panel_Okay")
    LM.Options.db.UnregisterAllCallbacks(self)
    for _,control in ipairs(self.controls or {}) do
        LiteMountOptionsControl_Okay(control)
    end
end

function LiteMountOptionsPanel_Revert(self)
    LM.UIDebug(self, "Panel_Revert")
    for _,control in ipairs(self.controls or {}) do
        LiteMountOptionsControl_Revert(control)
    end
end

function LiteMountOptionsPanel_Cancel(self)
    LM.UIDebug(self, "Panel_Cancel")
    LM.Options.db.UnregisterAllCallbacks(self)
    for _,control in ipairs(self.controls or {}) do
        LiteMountOptionsControl_Cancel(control)
    end
end

function LiteMountOptionsPanel_OnShow(self)
    LM.UIDebug(self, "Panel_OnShow")
    LiteMountOptions.CurrentOptionsPanel = self

    if not self.dontShowProfile then
        LiteMountProfileButton:Attach(self)
    end
end

function LiteMountOptionsPanel_OnHide(self)
    LM.UIDebug(self, "Panel_OnHide")

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
        self.RevertButton:Hide()
    end

    self.okay = self.okay or LiteMountOptionsPanel_Okay
    self.cancel = self.cancel or LiteMountOptionsPanel_Cancel
    self.default = self.default or LiteMountOptionsPanel_Default
    self.refresh = self.refresh or LiteMountOptionsPanel_Refresh
    self.reset = self.reset or LiteMountOptionsPanel_Reset

    LiteMountOptionsPanel_AutoLocalize(self)

    InterfaceOptions_AddCategory(self)
end

function LiteMountOptionsControl_Refresh(self, trigger)
    LM.UIDebug(self, "Control_Refresh t="..tostring(trigger))
    if self.oldValues == nil then
        self.oldValues = {}
        for i = 1, (self.ntabs or 1) do
            self.oldValues[i] = self:GetOption(i)
        end
        self.isDirty = nil
    end
    self:SetControl(self:GetOption(self.tab), self.tab)
end

function LiteMountOptionsControl_Okay(self)
    LM.UIDebug(self, "Control_Okay")
    self.oldValues = nil
    self.isDirty = nil
end

function LiteMountOptionsControl_Revert(self)
    LM.UIDebug(self, "Control_Revert")
    for i = 1, (self.ntabs or 1) do
        if self.oldValues[i] ~= nil then
            self:SetOption(self.oldValues[i], i)
        end
    end
    self.isDirty = nil
end

function LiteMountOptionsControl_Cancel(self)
    LM.UIDebug(self, "Control_Cancel")
    if self.isDirty then
        LiteMountOptionsControl_Revert(self)
    end
    self.oldValues = nil
end

function LiteMountOptionsControl_Default(self, onlyCurrentTab)
    if not self.GetOptionDefault then return end

    LM.UIDebug(self, "Control_Default "..tostring(onlyCurrentTab))

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
    LM.UIDebug(self, "Control_OnChanged")
    self:SetOption(self:GetControl(), self.tab)
    self.isDirty = true
end

function LiteMountOptionsControl_OnTextChanged(self, userInput)
    if userInput == true then
        LM.UIDebug(self, "Control_OnTextChanged")
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

-- Note we don't set an OnShow per control, the panel handler takes care of
-- running the refresh for all the controls in its OnShow

function LiteMountOptionsPanel_RegisterControl(control, parent)
    control.GetOption = control.GetOption or function (control) end
    control.SetOption = control.SetOption or function (control, v, i) end
    control.GetControl = control.GetControl or LiteMountOptionsControl_GetControl
    control.SetControl = control.SetControl or LiteMountOptionsControl_SetControl

    control.tab = 1

    parent = parent or control:GetParent()
    parent.controls = parent.controls or { }
    tinsert(parent.controls, control)
end
