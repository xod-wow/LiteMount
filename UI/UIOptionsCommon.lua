--[[----------------------------------------------------------------------------

  LiteMount/UIOptionsCommon.lua

  Common utils for the UI options panels.

  Copyright 2011-2015 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

-- Recurse all children finding any FontStrings and replacing their texts
-- with localized copies.
function LiteMount_Frame_AutoLocalize(f)
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
            LiteMount_Frame_AutoLocalize(c)
            c.autoLocalized = true
        end
    end
end

function LiteMount_OpenOptionsPanel()
    local f = LiteMountOptions
    if not f.CurrentOptionsPanel then
        f.CurrentOptionsPanel = LiteMountOptionsMounts
    end
    InterfaceOptionsFrame:Show()
    InterfaceOptionsFrame_OpenToCategory(f.CurrentOptionsPanel)
end

function LiteMount_UpdateOptionsListIfShown()
    if LiteMountOptionsMounts:IsShown() then
        LiteMountOptions_UpdateMountList()
    end
end

function LiteMountOptionsPanel_RegisterControl(control, parent)
    parent = parent or control:GetParent()
    parent.controls = parent.controls or { }
    tinsert(parent.controls, control)
end

function LiteMountOptionsPanel_Refresh(self)
    for _, control in next, self.controls do
        if control.refresh then control.refresh(control) end
    end
end

function LiteMountOptionsPanel_Default(self)
    for _, control in next, self.controls do
        if control.default then control.default(control) end
    end
end

function LiteMountOptionsPanel_Okay(self)
    for _, control in next, self.controls do
        if control.okay then control.okay(control) end
    end
end

function LiteMountOptionsPanel_Cancel(self)
    for _, control in next, self.controls do
        if control.okay then control.okay(control) end
    end
end
