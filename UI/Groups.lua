--[[----------------------------------------------------------------------------

  LiteMount/UI/Groups.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.L

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
            LiteMountGroupsPanel:MarkDirty()
            local editBox = self.editBox or self:GetEditBox()
            local text = editBox:GetText()
            LiteMountGroupsPanel.selectedGroup = text
            LM.Options:CreateGroup(text)
        end,
    -- This is not "Cancel", it's "Global" == button2
    OnCancel = function (self)
            LiteMountGroupsPanel:MarkDirty()
            local editBox = self.editBox or self:GetEditBox()
            local text = editBox:GetText()
            LiteMountGroupsPanel.selectedGroup = text
            LM.Options:CreateGroup(text, true)
        end,
    -- This is cancel (button3)
    OnAlt = function (self) end,
    EditBoxOnEnterPressed = function (self)
            local parent = self:GetParent()
            local button1 = parent.button1 or parent:GetButton1()
            if button1:IsEnabled() then
                StaticPopup_OnClick(self:GetParent(), 1)
            end
        end,
    EditBoxOnEscapePressed = function (self)
            self:GetParent():Hide()
        end,
    EditBoxOnTextChanged = function (self)
            local text = self:GetText()
            local valid = IsValidGroupName(text)
            local parent = self:GetParent()
            if parent.button1 then
                parent.button1:SetEnabled(valid)
                parent.button2:SetEnabled(valid)
            else
                parent:GetButton1():SetEnabled(valid)
                parent:GetButton2():SetEnabled(valid)
            end
        end,
    OnShow = function (self)
        local editBox = self.editBox or self:GetEditBox()
        editBox:SetFocus()
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
            LiteMountGroupsPanel:MarkDirty()
            local editBox = self.editBox or self:GetEditBox()
            local text = editBox:GetText()
            LiteMountGroupsPanel.selectedGroup = text
            LM.Options:RenameGroup(self.data, text)
        end,
    EditBoxOnEnterPressed = function (self)
            local parent = self:GetParent()
            local button1 = parent.button1 or parent:GetButton1()
            if button1:IsEnabled() then
                StaticPopup_OnClick(self:GetParent(), 1)
            end
        end,
    EditBoxOnEscapePressed = function (self)
            self:GetParent():Hide()
        end,
    EditBoxOnTextChanged = function (self)
            local text = self:GetText()
            local valid = text ~= self.data and IsValidGroupName(text)
            local parent = self:GetParent()
            local button1 = parent.button1 or parent:GetButton1()
            button1:SetEnabled(valid)
        end,
    OnShow = function (self)
            local fs = self.text or self:GetTextFontString()
            fs:SetText(format("LiteMount : %s : %s", L.LM_RENAME_GROUP, self.data))
            local editBox = self.editBox or self:GetEditBox()
            editBox:SetText(self.data)
            editBox:SetFocus()
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
            LiteMountGroupsPanel:MarkDirty()
            LM.Options:DeleteGroup(self.data)
        end,
    OnShow = function (self)
            local fs = self.text or self:GetTextFontString()
            fs:SetText(format("LiteMount : %s : %s", L.LM_DELETE_GROUP, self.data))
    end
}


--[[------------------------------------------------------------------------]]--

LiteMountGroupsPanelMixin = {}

function LiteMountGroupsPanelMixin:SelectGroup(group)
    self.selectedGroup = group
    self:RefreshDisplay()
    LiteMountOptionsPanelMixin.RefreshDisplay(self)
end

function LiteMountGroupsPanelMixin:RefreshGroupList()
    local allGroups = LM.Options:GetGroupNames()

    if not tContains(allGroups, self.selectedGroup) then
        self.selectedGroup = allGroups[1]
    end

    self.AddGroupButton:SetParent(nil)
    self.AddGroupButton:ClearAllPoints()
    self.AddGroupButton:Hide()

    local dp = CreateDataProvider()
    for _, group in ipairs(allGroups) do
        dp:Insert(group)
    end
    dp:Insert(self.AddGroupButton)
    self.GroupScrollBox:SetDataProvider(dp, ScrollBoxConstants.RetainScrollPosition)
end

function LiteMountGroupsPanelMixin:SaveSettings()
    local profile, global = LM.Options:GetRawGroups()
    return { CopyTable(profile), CopyTable(global) }
end

function LiteMountGroupsPanelMixin:LoadSettings(v)
    local profile, global = unpack(v)
    local dontFire = true
    LM.Options:SetRawGroups(profile, global, dontFire)
end

--[[ this doesnt' seem like a good idea
function LiteMountGroupsPanelMixin:LoadDefaultSettings()
    local dontFire = true
    LM.Options:SetRawGroups({}, {}, dontFire)
end
]]

function LiteMountGroupsPanelMixin:RefreshDisplay()
    self:RefreshGroupList()
    self:RefreshMountList()
    self.ShowAll:SetChecked(self.showAll)
end

function LiteMountGroupsPanelMixin:GetDisplayedMountList(group)
    if not group then
        return LM.MountList:New()
    end

    local mounts = LM.UIFilter.GetFilteredMountList()

    if not self.showAll then
        return mounts:Search(function (m) return LM.Options:IsMountInGroup(m, group) end)
    else
        return mounts
    end
end

function LiteMountGroupsPanelMixin:RefreshMountList()
    local selectedGroup = LiteMountGroupsPanel.selectedGroup
    local mounts = self:GetDisplayedMountList(selectedGroup)

    local dp = CreateDataProvider()

    for i = 1, #mounts, 2 do
        dp:Insert({ mounts[i], mounts[i+1], selectedGroup=selectedGroup })
    end

    self.MountScrollBox:SetDataProvider(dp, ScrollBoxConstants.RetainScrollPosition)
end

function LiteMountGroupsPanelMixin:OnLoad()
    self.showAll = true

    self.AddGroupButton:SetScript('OnClick',
        function ()
            self:StaticPopupShow('LM_OPTIONS_NEW_GROUP')
        end)

    self.DeleteButton:SetScript('OnClick',
        function ()
            local f = self.selectedGroup
            if f then
                self:StaticPopupShow("LM_OPTIONS_DELETE_GROUP", f, nil, f)
            end
        end)

    self.RenameButton:SetScript('OnClick',
        function ()
            local f = self.selectedGroup
            if f then self:StaticPopupShow("LM_OPTIONS_RENAME_GROUP", f, nil, f) end
        end)

    local view = CreateScrollBoxListLinearView(0, 0, 0, 0, 2)
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

    view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("LiteMountGroupsPanelButtonTemplate", function (button, elementData) button:Initialize(elementData) end)
    view:SetPadding(0, 0, 0, 0, 0)
    ScrollUtil.InitScrollBoxListWithScrollBar(self.MountScrollBox, self.MountScrollBar, view)

    LiteMountOptionsPanelMixin.OnLoad(self)
end

function LiteMountGroupsPanelMixin:OnShow()
    LiteMountFilter:Attach(self, 'BOTTOMLEFT', self.MountScrollBox, 'TOPLEFT', 0, 15)
    LM.UIFilter.RegisterCallback(self, "OnFilterChanged", "RefreshDisplay")
    LM.MountRegistry:RefreshMounts(true)
    self:RefreshDisplay()
    LiteMountOptionsPanelMixin.OnShow(self)
end

function LiteMountGroupsPanelMixin:OnHide()
    LM.UIFilter.UnregisterAllCallbacks(self)
    LiteMountOptionsPanelMixin.OnHide(self)
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
        LiteMountGroupsPanel:SelectGroup(self.group)
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

    local selected = self.group and self.group == LiteMountGroupsPanel.selectedGroup
    self.SelectedTexture:SetShown(selected)
end


--[[------------------------------------------------------------------------]]--

LiteMountGroupsPanelMountMixin = {}

function LiteMountGroupsPanelMountMixin:OnClick()
    LiteMountGroupsPanel:MarkDirty()
    local group = LiteMountGroupsPanel.selectedGroup
    if LM.Options:IsMountInGroup(self.mount, group) then
        LM.Options:ClearMountGroup(self.mount, group)
    else
        LM.Options:SetMountGroup(self.mount, group)
    end
end

function LiteMountGroupsPanelMountMixin:OnEnter()
    if self.mount then
        LiteMountTooltip:SetOwner(self, "ANCHOR_RIGHT", -16, 0)
        LiteMountTooltip:SetMount(self.mount)
    end
end

function LiteMountGroupsPanelMountMixin:OnLeave()
    LiteMountTooltip:Hide()
end

function LiteMountGroupsPanelMountMixin:SetMount(mount, group)
    self.mount = mount

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
    self.Name:SetText(mount.name)
end


--[[------------------------------------------------------------------------]]--

-- This is the doublewide button with 2 mounts

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
