--[[----------------------------------------------------------------------------

  LiteMount/AdvancedActions.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

local function BindingText(n)
    return format('%s %s', KEY_BINDING, n)
end

function LiteMountOptionsFlagButton_OnEnter(self)
    if self.flag then
        local mounts = LM_PlayerMounts:Filter(self.flag)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:AddLine(format('%s (%d)', L[self.flag], #mounts))
        GameTooltip:Show()
    end
end

function LiteMountOptionsFlagButton_OnLeave(self)
    if GameTooltip:GetOwner() == self then
        GameTooltip:Hide()
    end
end

function LiteMountOptionsAdvanced_Update(self)
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
            local flagText = L[allFlags[index]]
            if LM_Options:IsPrimaryFlag(allFlags[index]) then
                flagText = ITEM_QUALITY_COLORS[2].hex .. flagText .. FONT_COLOR_CODE_CLOSE
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

function LiteMountOptionsAdvanced_OnSizeChanged(self)
    HybridScrollFrame_CreateButtons(self.ScrollFrame, "LiteMountOptionsFlagButtonTemplate", 0, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")
    for _,b in ipairs(self.ScrollFrame.buttons) do
        b:SetWidth(self.ScrollFrame:GetWidth())
    end
end

function LiteMountOptionsAdvanced_OnLoad(self)
    self.name = ADVANCED_OPTIONS

    self.EditBox.ntabs = 4

    UIDropDownMenu_Initialize(self.BindingDropDown, LiteMountOptionsAdvancedBindingDropDown_Initialize)
    UIDropDownMenu_SetText(self.BindingDropDown, BindingText(1))

    self.ScrollFrame.update = function () LiteMountOptionsAdvanced_Update(self) end
    LiteMountOptionsAdvanced_OnSizeChanged(self)

    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountOptionsAdvanced_OnShow(self)
    self.EditBox:Disable()
    self.EditBox:SetAlpha(0.5)
    self.UnlockButton:Show()
    LiteMountOptionsAdvanced_Update(self)
    LiteMountOptionsPanel_OnShow(self)
end

function LiteMountOptionsAdvancedUnlock_OnClick(self)
    local parent = self:GetParent()
    parent.EditBox:SetAlpha(1.0)
    parent.EditBox:Enable()
    self:Hide()
end

function LiteMountOptionsAdvancedBindingDropDown_Initialize(dropDown, level)
    local info = UIDropDownMenu_CreateInfo()

    if level == 1 then
        for i = 1,4 do
            info.text = BindingText(i)
            info.arg1 = i
            info.arg2 = BindingText(i)
            info.func = function (button, v, t)
                    LiteMountOptionsControl_SetTab(LiteMountOptionsAdvanced.EditBox, v)
                    UIDropDownMenu_SetText(dropDown, t)
                end
            info.checked = (LiteMountOptionsAdvanced.currentButtonIndex == i)
            UIDropDownMenu_AddButton(info, level)
        end
    end
end
