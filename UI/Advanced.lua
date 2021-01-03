--[[----------------------------------------------------------------------------

  LiteMount/UI/Advanced.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local function BindingText(n)
    return format('%s %s', KEY_BINDING, n)
end

StaticPopupDialogs["LM_OPTIONS_NEW_FLAG"] = {
    text = format("LiteMount : %s", L.LM_NEW_FLAG),
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    maxLetters = 24,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1,
    OnAccept = function (self)
            local text = self.editBox:GetText()
            LM.Options:CreateFlag(text)
            LiteMountAdvancedPanel.FlagScroll.isDirty = true
        end,
    EditBoxOnEnterPressed = function (self)
            if self:GetParent().button1:IsEnabled() then
                StaticPopup_OnClick(self:GetParent(), 1)
            end
        end,
    EditBoxOnEscapePressed = function (self)
            self:GetParent():Hide()
        end,
    EditBoxOnTextChanged = function (self)
            local text = self:GetText()
            if text ~= "" and not LM.Options:IsActiveFlag(text) then
                self:GetParent().button1:Enable()
            else
                self:GetParent().button1:Disable()
            end
        end,
    OnShow = function (self)
        self.editBox:SetFocus()
    end,
}

StaticPopupDialogs["LM_OPTIONS_DELETE_FLAG"] = {
    text = format("LiteMount : %s", L.LM_DELETE_FLAG),
    button1 = ACCEPT,
    button2 = CANCEL,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1,
    OnAccept = function (self)
            LM.Options:DeleteFlag(self.data)
            LiteMountAdvancedPanel.FlagScroll.isDirty = true
        end,
    OnShow = function (self)
            self.text:SetText(format("LiteMount : %s : %s", L.LM_DELETE_FLAG, self.data))
    end
}

--[[--------------------------------------------------------------------------]]--

LiteMountFlagButtonMixin = {}

function LiteMountFlagButtonMixin:OnEnter()
    if self.flag then
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        if rawget(L, self.flag) == nil then
            GameTooltip:AddLine(self.flag)
        else
            GameTooltip:AddLine(format('%s (%s)', self.flag, L[self.flag]))
        end
        GameTooltip:Show()
    end
end

function LiteMountFlagButtonMixin:OnLeave()
    if GameTooltip:GetOwner() == self then
        GameTooltip:Hide()
    end
end

function LiteMountFlagButtonMixin:OnShow()
    self:SetWidth(self:GetParent():GetWidth())
end

--[[--------------------------------------------------------------------------]]--

LiteMountFlagScrollMixin = {}

function LiteMountFlagScrollMixin:Update()
    if not self.buttons then return end

    local offset = HybridScrollFrame_GetOffset(self)

    local allFlags = LM.Options:GetAllFlags()

    local totalHeight = (#allFlags + 1) * self.buttons[1]:GetHeight()
    local displayedHeight = #self.buttons * self.buttons[1]:GetHeight()

    local showAddButton, index, button

    for i = 1, #self.buttons do
        button = self.buttons[i]
        index = offset + i
        if index <= #allFlags then
            local flagText = allFlags[index]
            if LM.Options:IsPrimaryFlag(allFlags[index]) then
                flagText = ITEM_QUALITY_COLORS[2].hex .. flagText .. FONT_COLOR_CODE_CLOSE
                button.DeleteButton:Hide()
            else
                button.DeleteButton:Show()
            end
            button.Text:SetFormattedText(flagText)
            button.Text:Show()
            button:Show()
            button.flag = allFlags[index]
        elseif index == #allFlags + 1 then
            button.Text:Hide()
            button.DeleteButton:Hide()
            button:Show()
            button.flag = nil
            self.AddFlagButton:SetParent(button)
            self.AddFlagButton:ClearAllPoints()
            self.AddFlagButton:SetPoint("CENTER")
            self.AddFlagButton:SetWidth(self:GetWidth())
            button.DeleteButton:Hide()
            showAddButton = true
        else
            button:Hide()
            button.DeleteButton:Hide()
            button.flag = nil
        end
    end

    self.AddFlagButton:SetShown(showAddButton)

    HybridScrollFrame_Update(self, totalHeight, displayedHeight)
end

function LiteMountFlagScrollMixin:GetOption()
    return CopyTable(LM.Options:GetRawFlags())
end

function LiteMountFlagScrollMixin:SetOption(v)
    LM.Options:SetRawFlags(v)
end

function LiteMountFlagScrollMixin:OnLoad()
    local track = _G[self.scrollBar:GetName().."Track"]
    track:Hide()
    self.scrollBar.doNotHide = true

    self.update = self.Update
    self.SetControl = self.Update
end

--[[--------------------------------------------------------------------------]]--

local RevertOverrideMixin = {}

function RevertOverrideMixin:OnShow()
    local parent = self:GetParent()
    local editBox = parent.EditScroll.EditBox
    editBox:SetAlpha(0.5)
    editBox:Disable()
    parent.DefaultButton:Disable()
    self:SetText(UNLOCK)
end

function RevertOverrideMixin:OnClick()
    local parent = self:GetParent()
    local editBox = parent.EditScroll.EditBox
    if self:GetText() == UNLOCK then
        editBox:SetAlpha(1.0)
        editBox:Enable()
        parent.DefaultButton:Enable()
        self:SetText(REVERT)
    else
        LiteMountOptionsControl_Revert(editBox)
    end
end

--[[--------------------------------------------------------------------------]]--

local function BindingDropDown_Initialize(dropDown, level)
    local info = UIDropDownMenu_CreateInfo()
    local editBox = LiteMountAdvancedPanel.EditScroll.EditBox
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

--[[--------------------------------------------------------------------------]]--

LiteMountAdvancedEditScrollMixin = {}

function LiteMountAdvancedEditScrollMixin:OnLoad()
    self.scrollBarHideable = 1
    self.ScrollBar:Hide()
end

function LiteMountAdvancedEditScrollMixin:OnShow()
    self.EditBox:SetWidth(self:GetWidth() - 18)
end

--[[--------------------------------------------------------------------------]]--

LiteMountAdvancedEditBoxMixin = {}

function LiteMountAdvancedEditBoxMixin:SetOption(v, i)
    LM.Options:SetButtonAction(i, v)
end

function LiteMountAdvancedEditBoxMixin:GetOption(i)
    return LM.Options:GetButtonAction(i)
end

function LiteMountAdvancedEditBoxMixin:GetOptionDefault()
    return LM.Options:GetButtonAction('*')
end

function LiteMountAdvancedEditBoxMixin:OnLoad()
    self.ntabs = 4
end

--[[--------------------------------------------------------------------------]]--

LiteMountAdvancedPanelMixin = {}

function LiteMountAdvancedPanelMixin:OnSizeChanged(x, y)
    HybridScrollFrame_CreateButtons(
            self.FlagScroll,
            "LiteMountFlagButtonTemplate",
            0, 0, "TOPLEFT", "TOPLEFT",
            0, 0, "TOP", "BOTTOM"
        )
    self.FlagScroll:Update()
end

function LiteMountAdvancedPanelMixin:OnLoad()
    self.name = ADVANCED_OPTIONS

    LiteMountOptionsPanel_RegisterControl(self.EditScroll.EditBox, self)
    LiteMountOptionsPanel_RegisterControl(self.FlagScroll)

    UIDropDownMenu_Initialize(self.BindingDropDown, BindingDropDown_Initialize)
    UIDropDownMenu_SetText(self.BindingDropDown, BindingText(1))

    self.RevertButton:SetScript("OnShow", RevertOverrideMixin.OnShow)
    self.RevertButton:SetScript("OnClick", RevertOverrideMixin.OnClick)

    LiteMountOptionsPanel_OnLoad(self)
end
