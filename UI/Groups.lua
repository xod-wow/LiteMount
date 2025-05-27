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
            LiteMountGroupsPanel.GroupScrollBox.isDirty = true
            local text = self.editBox:GetText()
            LiteMountGroupsPanel.GroupScrollBox.selectedGroup = text
            LM.Options:CreateGroup(text)
        end,
    -- This is not "Cancel", it's "Global" == button2
    OnCancel = function (self)
            LiteMountGroupsPanel.GroupScrollBox.isDirty = true
            local text = self.editBox:GetText()
            LiteMountGroupsPanel.GroupScrollBox.selectedGroup = text
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
            LiteMountGroupsPanel.GroupScrollBox.isDirty = true
            local text = self.editBox:GetText()
            LiteMountGroupsPanel.GroupScrollBox.selectedGroup = text
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
            LiteMountGroupsPanel.GroupScrollBox.isDirty = true
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

    local view = CreateScrollBoxListLinearView()
    view:SetElementFactory(
        function (factory, elementData)
            if type(elementData) == 'string' then
                factory("LiteMountGroupsPanelGroupTemplate", function (button) button:Initialize(elementData) end)
            else
                factory("LiteMountGroupsPanelBlankTemplate", function (button) button:Initialize(elementData) end)
            end
        end)

    -- view:SetElementInitializer("LiteMountGroupsPanelGroupTemplate", function (button, elementData) button:Initialize(elementData) end)
    view:SetPadding(0, 0, 0, 0, 0)
    ScrollUtil.InitScrollBoxListWithScrollBar(self.GroupScrollBox, self.GroupScrollBar, view)
    self.GroupScrollBox.update = self.GroupScrollBox.RefreshGroupList

    view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("LiteMountGroupsPanelButtonTemplate", function (button, elementData) button:Initialize(elementData) end)
    view:SetPadding(0, 0, 0, 0, 0)
    ScrollUtil.InitScrollBoxListWithScrollBar(self.MountScrollBox, self.MountScrollBar, view)
    self.MountScrollBox.update = self.MountScrollBox.RefreshMountList

    LiteMountOptionsPanel_RegisterControl(self.GroupScrollBox)
    LiteMountOptionsPanel_RegisterControl(self.MountScrollBox)
    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountGroupsPanelMixin:OnShow()
    LiteMountFilter:Attach(self, 'BOTTOMLEFT', self.MountScrollBox, 'TOPLEFT', 0, 15)
    LM.UIFilter.RegisterCallback(self, "OnFilterChanged", "OnRefresh")
    self:Update()
    LiteMountOptionsPanel_OnShow(self)
end

function LiteMountGroupsPanelMixin:OnHide()
    LM.UIFilter.UnregisterAllCallbacks(self)
    LiteMountOptionsPanel_OnHide(self)
end

function LiteMountGroupsPanelMixin:Update()
    self.GroupScrollBox:RefreshGroupList()
    self.MountScrollBox:RefreshMountList()
    self.ShowAll:SetChecked(self.showAll)
end


--[[------------------------------------------------------------------------]]--

LiteMountGroupsPanelBlankMixin = {}

function LiteMountGroupsPanelBlankMixin:Initialize(elementData)
    local addButton = elementData
    addButton:SetParent(self)
    addButton:ClearAllPoints()
    addButton:SetPoint("CENTER")
    addButton:Show()
end

--[[------------------------------------------------------------------------]]--

LiteMountGroupsPanelGroupMixin = {}

function LiteMountGroupsPanelGroupMixin:OnClick()
    if self.group then
        LiteMountGroupsPanel.GroupScrollBox.selectedGroup = self.group
        LiteMountGroupsPanel:Update()
    end
end

function LiteMountGroupsPanelGroupMixin:Initialize(elementData)
    local groupText = elementData
    if LM.Options:IsGlobalGroup(groupText) then
        groupText = BLUE_FONT_COLOR:WrapTextInColorCode(groupText)
    end
    self.Text:SetFormattedText(groupText)
    self.Text:Show()
    self.group = elementData

    local selected = self.group and self.group == LiteMountGroupsPanel.GroupScrollBox.selectedGroup
    self.SelectedTexture:SetShown(selected)
    self.SelectedArrow:SetShown(selected)
end


--[[------------------------------------------------------------------------]]--

LiteMountGroupsPanelGroupScrollBoxMixin = {}

function LiteMountGroupsPanelGroupScrollBoxMixin:RefreshGroupList()
    local allGroups = LM.Options:GetGroupNames()

    if not tContains(allGroups, self.selectedGroup) then
        self.selectedGroup = allGroups[1]
    end

    self.AddGroupButton:SetParent(nil)
    self.AddGroupButton:ClearAllPoints()
    self.AddGroupButton:Hide()

    local dp = CreateDataProvider()
    for i, group in ipairs(allGroups) do
        dp:Insert(group)
    end
    dp:Insert(self.AddGroupButton)
    self:SetDataProvider(dp, ScrollBoxConstants.RetainScrollPosition)
end

function LiteMountGroupsPanelGroupScrollBoxMixin:GetOption()
    local profile, global = LM.Options:GetRawGroups()
    return { CopyTable(profile), CopyTable(global) }
end

function LiteMountGroupsPanelGroupScrollBoxMixin:SetOption(v)
    LM.Options:SetRawGroups(unpack(v))
end

function LiteMountGroupsPanelGroupScrollBoxMixin:SetControl(v)
    self:RefreshGroupList()
end


--[[------------------------------------------------------------------------]]--

LiteMountGroupsPanelMountMixin = {}

function LiteMountGroupsPanelMountMixin:OnClick()
    LiteMountGroupsPanel.GroupScrollBox.isDirty = true
    local group = LiteMountGroupsPanel.GroupScrollBox.selectedGroup
    if LM.Options:IsMountInGroup(self.mount, group) then
        LM.Options:ClearMountGroup(self.mount, group)
    else
        LM.Options:SetMountGroup(self.mount, group)
    end
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

LiteMountGroupsPanelButtonMixin = {}

function LiteMountGroupsPanelButtonMixin:Initialize(elementData)
    self.mount1:SetMount(elementData[1], elementData.selectedGroup)
    if elementData[2] then
        self.mount2:SetMount(elementData[2], elementData.selectedGroup)
        self.mount2:Show()
    else
        self.mount2:Hide()
    end
end


--[[------------------------------------------------------------------------]]--

LiteMountGroupsPanelMountScrollBoxMixin = {}

function LiteMountGroupsPanelMountScrollBoxMixin:GetDisplayedMountList(group)
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

function LiteMountGroupsPanelMountScrollBoxMixin:RefreshMountList()
    local selectedGroup = LiteMountGroupsPanel.GroupScrollBox.selectedGroup
    local mounts = self:GetDisplayedMountList(selectedGroup)

    local dp = CreateDataProvider()

    for i = 1, #mounts, 2 do
        dp:Insert({ mounts[i], mounts[i+1], selectedGroup=selectedGroup })
    end

    self:SetDataProvider(dp, ScrollBoxConstants.RetainScrollPosition)
end

function LiteMountGroupsPanelMountScrollBoxMixin:SetControl(v)
    self:RefreshMountList()
end
