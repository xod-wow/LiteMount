--[[----------------------------------------------------------------------------

  LiteMount/AdvancedActions.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

local function BindingText(n)
    return format('%s %s', KEY_BINDING, n)
end

function LiteMountOptionsFlagList_Update(self)
    local scrollFrame = self.ScrollFrame
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons

    local allFlags = LM_Options:GetAllFlags()

    local totalHeight = #allFlags * buttons[1]:GetHeight()
    local displayedHeight = #buttons * buttons[1]:GetHeight()

    for i = 1, #buttons do
        button = buttons[i]
        index = offset + i
        if index <= #allFlags then
            local flagText = allFlags[index]
            if LM_Options:IsPrimaryFlag(allFlags[index]) then
                flagText = ITEM_QUALITY_COLORS[5].hex .. flagText .. FONT_COLOR_CODE_CLOSE
            end
            button.Text:SetFormattedText(flagText)
            button:Show()
            button.flag = allFlags[index]
        else
            button:Hide()
            button.flag = nil
        end
    end

    HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight)
end

function LiteMountOptionsActions_OnSizeChanged(self)
    HybridScrollFrame_CreateButtons(self.ScrollFrame, "LiteMountOptionsFlagButtonTemplate", 0, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")
    for _,b in ipairs(self.ScrollFrame.buttons) do
        b:SetWidth(self:GetWidth())
    end
end

function LiteMountOptionsActions_OnLoad(self)
    self.name = format('%s : %s', ADVANCED_LABEL, L.LM_ACTION_LISTS)

    self.EditBox.ntabs = 4

    UIDropDownMenu_Initialize(self.BindingDropDown, LiteMountOptionsActionsBindingDropDown_Initialize)
    UIDropDownMenu_SetText(self.BindingDropDown, BindingText(1))

    self.ScrollFrame.update = function () LiteMountOptionsFlagList_Update(self) end
    LiteMountOptionsActions_OnSizeChanged(self)

    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountOptionsActions_OnShow(self)
    self.EditBox:Disable()
    self.EditBox:SetAlpha(0.5)
    self.UnlockButton:Show()
    LiteMountOptionsFlagList_Update(self)
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
