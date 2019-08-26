--[[----------------------------------------------------------------------------

  LiteMount/UI/Advanced.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2019 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

local function BindingText(n)
    return format('%s %s', KEY_BINDING, n)
end

function LiteMountAdvanced_OnLoad(self)
    self.name = ADVANCED_OPTIONS

    self.EditScroll.EditBox.ntabs = 4

    UIDropDownMenu_Initialize(self.BindingDropDown, LiteMountAdvancedBindingDropDown_Initialize)
    UIDropDownMenu_SetText(self.BindingDropDown, BindingText(1))

    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountAdvancedRevert_OnShow(self)
    local parent = self:GetParent()
    local editBox = parent.EditScroll.EditBox
    editBox:SetAlpha(0.5)
    editBox:Disable()
    parent.DefaultButton:Disable()
    self:SetText(UNLOCK)
end

function LiteMountAdvancedRevert_OnClick(self)
    local parent = self:GetParent()
    local editBox = parent.EditScroll.EditBox
    if self:GetText() == UNLOCK then
        editBox:SetAlpha(1.0)
        editBox:Enable()
        parent.DefaultButton:Enable()
        self:SetText(REVERT)
    else
        LiteMountOptionsControl_Revert(editBox)
        LiteMountOptionsControl_Refresh(editBox)
    end
end

function LiteMountAdvancedBindingDropDown_Initialize(dropDown, level)
    local info = UIDropDownMenu_CreateInfo()
    local editBox = LiteMountAdvanced.EditScroll.EditBox
    if level == 1 then
        for i = 1,4 do
            info.text = BindingText(i)
            info.arg1 = i
            info.arg2 = BindingText(i)
            info.func = function (button, v, t)
                    LiteMountOptionsControl_SetTab(editBox, v)
                    UIDropDownMenu_SetText(dropDown, t)
                end
            info.checked = (editBox.tab == i)
            UIDropDownMenu_AddButton(info, level)
        end
    end
end
