--[[----------------------------------------------------------------------------

  LiteMount/AdvancedActions.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

local function BindingText(n)
    return format('%s %s', KEY_BINDING, n)
end

function LiteMountOptionsActions_OnLoad(self)
    self.name = format('%s : %s', ADVANCED, LM_ACTION_LISTS)

    self.EditBox.ntabs = 4

    UIDropDownMenu_Initialize(self.BindingDropDown, LiteMountOptionsActionsBindingDropDown_Initialize)
    UIDropDownMenu_SetText(self.BindingDropDown, BindingText(1))
    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountOptionsActions_OnShow(self)
    self.EditBox:Disable()
    self.EditBox:SetAlpha(0.5)
    self.UnlockButton:Show()
    LiteMountOptionsPanel_OnShow(self)
end

function LiteMountOptionsActionsUnlock_OnClick(self)
    local parent = self:GetParent()
    parent.EditBox:SetAlpha(1.0)
    parent.EditBox:Enable()
    self:Hide()
end

function LiteMountOptionsActionsBindingDropDown_Initialize(dropDown, level)
    local info = UIDropDownMenu_CreateInfo()

    if level == 1 then
        for i = 1,4 do
            info.text = BindingText(i)
            info.arg1 = i
            info.arg2 = BindingText(i)
            info.func = function (button, v, t)
                    LiteMountOptionsControl_SetTab(LiteMountOptionsActions.EditBox, v)
                    UIDropDownMenu_SetText(dropDown, t)
                end
            info.checked = (LiteMountOptionsActions.currentButtonIndex == i)
            UIDropDownMenu_AddButton(info, level)
        end
    end
end
