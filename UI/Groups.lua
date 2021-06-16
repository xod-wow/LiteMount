--[[----------------------------------------------------------------------------

  LiteMount/UI/Groups.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

--[[--------------------------------------------------------------------------]]--

StaticPopupDialogs["LM_OPTIONS_NEW_GROUP"] = {
    text = format("LiteMount : %s", L.LM_NEW_GROUP),
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
            LiteMountGroupsPanel.selectedGroup = text
            LiteMountGroupsPanel.Groups.isDirty = true
            LiteMountGroupsPanel:Update()
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

StaticPopupDialogs["LM_OPTIONS_DELETE_GROUP"] = {
    text = format("LiteMount : %s", L.LM_DELETE_GROUP),
    button1 = ACCEPT,
    button2 = CANCEL,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1,
    OnAccept = function (self)
            LM.Options:DeleteFlag(self.data)
            LiteMountGroupsPanel.Groups.isDirty = true
        end,
    OnShow = function (self)
            self.text:SetText(format("LiteMount : %s : %s", L.LM_DELETE_GROUP, self.data))
    end
}


--[[--------------------------------------------------------------------------]]--

LiteMountGroupsPanelMixin = {}

function LiteMountGroupsPanelMixin:OnLoad()
    self.showAll = true
    LiteMountOptionsPanel_RegisterControl(self.Groups)
    LiteMountOptionsPanel_RegisterControl(self.Mounts)
    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountGroupsPanelMixin:OnShow()
    LiteMountFilter:Attach(self, 'BOTTOMLEFT', self.Mounts, 'TOPLEFT', 0, 15)
    LM.UIFilter.RegisterCallback(self, "OnFilterChanged", "refresh")
    self:Update()
    LiteMountOptionsPanel_OnShow(self)
end

function LiteMountGroupsPanelMixin:OnHide()
    LM.UIFilter.UnregisterAllCallbacks(self)
    LiteMountOptionsPanel_OnHide(self)
end

function LiteMountGroupsPanelMixin:Update()
    self.allGroups = table.wipe(self.allGroups or {})
    for f in pairs(LM.Options:GetRawFlags()) do
        table.insert(self.allGroups, f)
    end
    table.sort(self.allGroups)
    if not tContains(self.allGroups, self.selectedGroup) then
        self.selectedGroup = self.allGroups[1]
    end
    self.Groups:Update()
    self.Mounts:Update()
    self.ShowAll:SetChecked(self.showAll)
end

--[[--------------------------------------------------------------------------]]--

LiteMountGroupsPanelGroupMixin = {}

function LiteMountGroupsPanelGroupMixin:OnClick()
    if self.group then
        LiteMountGroupsPanel.selectedGroup = self.group
        LiteMountGroupsPanel:Update()
    end
end


--[[--------------------------------------------------------------------------]]--

LiteMountGroupsPanelGroupsMixin = {}

function LiteMountGroupsPanelGroupsMixin:Update()
    if not self.buttons then return end

    local offset = HybridScrollFrame_GetOffset(self)
    local allGroups = self:GetParent().allGroups

    local totalHeight = (#allGroups + 1) * (self.buttons[1]:GetHeight() + 1)
    local displayedHeight = #self.buttons * self.buttons[1]:GetHeight()

    local index, button

    self.AddGroupButton:SetParent(nil)
    self.AddGroupButton:Hide()

    for i = 1, #self.buttons do
        button = self.buttons[i]
        index = offset + i
        if index <= #allGroups then
            local groupText = allGroups[index]
            button.Text:SetFormattedText(groupText)
            button.Text:Show()
            button:Show()
            button.group = allGroups[index]
        elseif index == #allGroups + 1 then
            button.Text:Hide()
            button:Show()
            self.AddGroupButton:SetParent(button)
            self.AddGroupButton:ClearAllPoints()
            self.AddGroupButton:SetPoint("CENTER")
            self.AddGroupButton:Show()
            button.group = nil
        else
            button:Hide()
            button.group = nil
        end
        -- button:SetWidth(buttonWidth)
        button.SelectedTexture:SetShown(button.group and button.group == self:GetParent().selectedGroup)
        button.SelectedArrow:SetShown(button.group and button.group == self:GetParent().selectedGroup)
    end


    HybridScrollFrame_Update(self, totalHeight, displayedHeight)
    for i, button in ipairs(self.buttons) do
        if self.scrollBar:IsVisible() then
            button:SetWidth(self:GetWidth() - 22)
        else
            button:SetWidth(self:GetWidth())
        end
    end
end

function LiteMountGroupsPanelGroupsMixin:OnSizeChanged()
    HybridScrollFrame_CreateButtons(self, 'LiteMountGroupsPanelGroupTemplate', 0, -1, "TOPLEFT", "TOPLEFT", 0, -1, "TOPLEFT", "BOTTOMLEFT")
    for _, b in ipairs(self.buttons) do
        b:SetWidth(self:GetWidth())
    end
end

function LiteMountGroupsPanelGroupsMixin:OnLoad()
    self.scrollBar:ClearAllPoints()
    self.scrollBar:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -16)
    self.scrollBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 16)
    local track = _G[self.scrollBar:GetName().."Track"]
    track:Hide()
    -- self.scrollBar.doNotHide = true
    self.update = self.Update
end

function LiteMountGroupsPanelGroupsMixin:GetOption()
    return LM.Options:GetRawFlags()
end

function LiteMountGroupsPanelGroupsMixin:SetOption(v)
    LM.Options:SetRawFlags(v)
end

function LiteMountGroupsPanelGroupsMixin:SetControl(v)
    self:Update()
end


--[[--------------------------------------------------------------------------]]--

LiteMountGroupsPanelMountMixin = {}

function LiteMountGroupsPanelMountMixin:OnClick()
    local group = LiteMountGroupsPanel.selectedGroup
    if self.mount:MatchesFilters(group) then
        LM.Options:ClearMountFlag(self.mount, group)
    else
        LM.Options:SetMountFlag(self.mount, group)
    end
    LiteMountGroupsPanel.Mounts.isDirty = true
    LiteMountGroupsPanel.Mounts:Update()
end

function LiteMountGroupsPanelMountMixin:OnEnter()
    if self.mount then
        LM.ShowMountTooltip(self, self.mount)
    end
end

function LiteMountGroupsPanelMountMixin:OnLeave()
    LM.HideMountTooltip()
end

function LiteMountGroupsPanelMountMixin:SetMount(mount, group)
    self.mount = mount

    self.Name:SetText(mount.name)
    if group and mount:MatchesFilters(group) then
        self.Checked:Show()
    else
        self.Checked:Hide()
    end

    if not mount.isCollected then
        self.Name:SetFontObject("GameFontDisable")
    elseif mount.isUsable == false then
        self.Name:SetFontObject("GameFontNormal")
    else
        self.Name:SetFontObject("GameFontNormal")
    end
end


--[[--------------------------------------------------------------------------]]--

LiteMountGroupsPanelMountScrollMixin = {}

function LiteMountGroupsPanelMountScrollMixin:Update()
    if not self.buttons then return end

    local offset = HybridScrollFrame_GetOffset(self)

    local mounts = LM.UIFilter.GetFilteredMountList()

    local group = self:GetParent().selectedGroup

    if not group then
        for _, button in ipairs(self.buttons) do
            button:Hide()
        end
        HybridScrollFrame_Update(self, 0, 0)
        return
    end

    if not self:GetParent().showAll then
        mounts = mounts:Search(function (m) return m:GetFlags()[group] end)
    end

    for i, button in ipairs(self.buttons) do
        local index = ( offset + i - 1 ) * 2 + 1
        if index > #mounts then
            button:Hide()
        else
            button.mount1:SetMount(mounts[index], group)
            if button.mount1:IsMouseOver() then button.mount1:OnEnter() end
            if mounts[index+1] then
                button.mount2:SetMount(mounts[index+1], group)
                button.mount2:Show()
                if button.mount2:IsMouseOver() then button.mount2:OnEnter() end
            else
                button.mount2:Hide()
            end
            button:Show()
        end
    end

    local totalHeight = math.ceil(#mounts/2) * self.buttons[1]:GetHeight()
    local displayedHeight = #self.buttons * self.buttons[1]:GetHeight()

    HybridScrollFrame_Update(self, totalHeight, displayedHeight)
end

function LiteMountGroupsPanelMountScrollMixin:OnSizeChanged()
    HybridScrollFrame_CreateButtons(self, 'LiteMountGroupsPanelButtonTemplate')
    for _, b in ipairs(self.buttons) do
        b:SetWidth(self:GetWidth())
    end
end

function LiteMountGroupsPanelMountScrollMixin:OnLoad()
    local track = _G[self.scrollBar:GetName().."Track"]
    track:Hide()
    self.update = self.Update
end

-- XXX FIXME
-- XXX FIXME Why TF doesn't revert work until second click? XXX
-- XXX FIXME

function LiteMountGroupsPanelMountScrollMixin:GetOption()
    return LM.Options:GetRawFlagChanges()
end

function LiteMountGroupsPanelMountScrollMixin:SetOption(v)
    LM.Options:SetRawFlagChanges(v)
end

function LiteMountGroupsPanelMountScrollMixin:SetControl(v)
    self:Update()
end
