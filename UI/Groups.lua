--[[----------------------------------------------------------------------------

  LiteMount/UI/Groups.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

--[[------------------------------------------------------------------------]]--

-- Group names can't match anything that LM.Mount:MatchesOneFilter will parse
-- as something other than a group. Don't care about mount names though that
-- should be obvious to people as something that won't work.

local function IsValidGroupName(text)
    if not text or text == "" then return false end
    if LM.Options:IsFlag(text) then return false end
    if LM.Options:IsGroup(text) then return false end
    if tonumber(text) then return false end
    if text:find(':') then return false end
    if text:sub(1, 1) == '~' then return false end
    return true
end

StaticPopupDialogs["LM_OPTIONS_NEW_GROUP"] = {
    text = format("LiteMount : %s", L.LM_NEW_GROUP),
    button1 = L.LM_CREATE_PROFILE_GROUP,    -- Note: OnAccept
    button2 = L.LM_CREATE_GLOBAL_GROUP,     -- Note: OnCancel (ugh)
    button3 = CANCEL,                       -- Note: OnAlt
    hasEditBox = 1,
    maxLetters = 24,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1,
    OnAccept = function (self)
            LiteMountGroupsPanel.Groups.isDirty = true
            local text = self.editBox:GetText()
            LiteMountGroupsPanel.Groups.selectedGroup = text
            LM.Options:CreateGroup(text)
        end,
    -- This is not "Cancel", it's "Global" == button2
    OnCancel = function (self)
            LiteMountGroupsPanel.Groups.isDirty = true
            local text = self.editBox:GetText()
            LiteMountGroupsPanel.Groups.selectedGroup = text
            LM.Options:CreateGroup(text, true)
        end,
    -- This is cancel (button3)
    OnAlt = function (self) end,
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
            local valid = IsValidGroupName(text)
            self:GetParent().button1:SetEnabled(valid)
            self:GetParent().button2:SetEnabled(valid)
        end,
    OnShow = function (self)
        self.editBox:SetFocus()
    end,
}

StaticPopupDialogs["LM_OPTIONS_RENAME_GROUP"] = {
    text = format("LiteMount : %s", L.LM_RENAME_GROUP),
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    maxLetters = 24,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1,
    OnAccept = function (self)
            LiteMountGroupsPanel.Groups.isDirty = true
            local text = self.editBox:GetText()
            LiteMountGroupsPanel.Groups.selectedGroup = text
            LM.Options:RenameGroup(self.data, text)
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
            local valid = text ~= self.data and IsValidGroupName(text)
            self:GetParent().button1:SetEnabled(valid)
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
            LiteMountGroupsPanel.Groups.isDirty = true
            LM.Options:DeleteGroup(self.data)
        end,
    OnShow = function (self)
            self.text:SetText(format("LiteMount : %s : %s", L.LM_DELETE_GROUP, self.data))
    end
}


--[[------------------------------------------------------------------------]]--

LiteMountGroupsPanelMixin = {}

function LiteMountGroupsPanelMixin:OnLoad()
    self.showAll = true
    LiteMountOptionsPanel_RegisterControl(self.Groups)
    LiteMountOptionsPanel_RegisterControl(self.Mounts)
    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountGroupsPanelMixin:OnShow()
    LiteMountFilter:Attach(self, 'BOTTOMLEFT', self.Mounts, 'TOPLEFT', 0, 15)
    LM.UIFilter.RegisterCallback(self, "OnFilterChanged", "OnRefresh")
    self:Update()
    LiteMountOptionsPanel_OnShow(self)
end

function LiteMountGroupsPanelMixin:OnHide()
    LM.UIFilter.UnregisterAllCallbacks(self)
    LiteMountOptionsPanel_OnHide(self)
end

function LiteMountGroupsPanelMixin:Update()
    self.Groups:Update()
    self.Mounts:Update()
    self.ShowAll:SetChecked(self.showAll)
end

--[[------------------------------------------------------------------------]]--

LiteMountGroupsPanelGroupMixin = {}

function LiteMountGroupsPanelGroupMixin:OnClick()
    if self.group then
        LiteMountGroupsPanel.Groups.selectedGroup = self.group
        LiteMountGroupsPanel:Update()
    end
end


--[[------------------------------------------------------------------------]]--

LiteMountGroupsPanelGroupsMixin = {}

function LiteMountGroupsPanelGroupsMixin:Update()
    if not self.buttons then return end

    local offset = HybridScrollFrame_GetOffset(self)
    local allGroups = LM.Options:GetGroupNames()

    if not tContains(allGroups, self.selectedGroup) then
        self.selectedGroup = allGroups[1]
    end

    local totalHeight = (#allGroups + 1) * (self.buttons[1]:GetHeight() + 1)
    local displayedHeight = #self.buttons * self.buttons[1]:GetHeight()

    self.AddGroupButton:SetParent(nil)
    self.AddGroupButton:Hide()

    for i = 1, #self.buttons do
        local button = self.buttons[i]
        local index = offset + i
        if index <= #allGroups then
            local groupText = allGroups[index]
            if LM.Options:IsGlobalGroup(groupText) then
                groupText = BLUE_FONT_COLOR:WrapTextInColorCode(groupText)
            end
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
        button.SelectedTexture:SetShown(button.group and button.group == self.selectedGroup)
        button.SelectedArrow:SetShown(button.group and button.group == self.selectedGroup)
    end


    HybridScrollFrame_Update(self, totalHeight, displayedHeight)
    for _, button in ipairs(self.buttons) do
        if self.scrollBar:IsVisible() then
            button:SetWidth(self:GetWidth() - 22)
        else
            button:SetWidth(self:GetWidth())
        end
    end
end

function LiteMountGroupsPanelGroupsMixin:OnSizeChanged()
    HybridScrollFrame_CreateButtons(self, 'LiteMountGroupsPanelGroupTemplate')
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
    local profile, global = LM.Options:GetRawGroups()
    return { CopyTable(profile), CopyTable(global) }
end

function LiteMountGroupsPanelGroupsMixin:SetOption(v)
    LM.Options:SetRawGroups(unpack(v))
end

function LiteMountGroupsPanelGroupsMixin:SetControl(v)
    self:Update()
end


--[[------------------------------------------------------------------------]]--

LiteMountGroupsPanelMountMixin = {}

function LiteMountGroupsPanelMountMixin:OnClick()
    LiteMountGroupsPanel.Groups.isDirty = true
    local group = LiteMountGroupsPanel.Groups.selectedGroup
    if LM.Options:IsMountInGroup(self.mount, group) then
        LM.Options:ClearMountGroup(self.mount, group)
    else
        LM.Options:SetMountGroup(self.mount, group)
    end
    LiteMountGroupsPanel.Mounts:Update()
end

function LiteMountGroupsPanelMountMixin:OnEnter()
    if self.mount then
        -- GameTooltip_SetDefaultAnchor(LiteMountTooltip, UIParent)
        LiteMountTooltip:SetOwner(self, "ANCHOR_RIGHT", -16, 0)
        LiteMountTooltip:SetMount(self.mount)
    end
end

function LiteMountGroupsPanelMountMixin:OnLeave()
    LiteMountTooltip:Hide()
end

function LiteMountGroupsPanelMountMixin:SetMount(mount, group)
    self.mount = mount

    self.Name:SetText(mount.name)
    if group and LM.Options:IsMountInGroup(self.mount, group) then
        self.Checked:Show()
    else
        self.Checked:Hide()
    end

    if not mount:IsCollected() then
        self.Name:SetFontObject("GameFontDisableSmall")
    else
        self.Name:SetFontObject("GameFontNormalSmall")
    end
end


--[[------------------------------------------------------------------------]]--

LiteMountGroupsPanelMountScrollMixin = {}

function LiteMountGroupsPanelMountScrollMixin:GetDisplayedMountList(group)
    if not group then
        return LM.MountList:New()
    end

    local mounts = LM.UIFilter.GetFilteredMountList()

    if not LiteMountGroupsPanel.showAll then
        return mounts:Search(function (m) return LM.Options:IsMountInGroup(m, group) end)
    else
        return mounts
    end
end

function LiteMountGroupsPanelMountScrollMixin:Update()
    if not self.buttons then return end

    local offset = HybridScrollFrame_GetOffset(self)

    local group = LiteMountGroupsPanel.Groups.selectedGroup
    local mounts = self:GetDisplayedMountList(group)

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

function LiteMountGroupsPanelMountScrollMixin:SetControl(v)
    self:Update()
end
