--[[----------------------------------------------------------------------------

  LiteMount/UI/Groups.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--[[--------------------------------------------------------------------------]]--

LiteMountGroupsPanelMixin = {}

function LiteMountGroupsPanelMixin:OnLoad()
    self.showAll = true
    self.refresh = self.Update
    self.reset = self.Update
end

function LiteMountGroupsPanelMixin:OnShow()
    LiteMountFilter:Attach(self, 'BOTTOMLEFT', self.Mounts, 'TOPLEFT', 0, 15)
    LM.UIFilter.RegisterCallback(self, "OnFilterChanged", "refresh")
    self:Update()
end

function LiteMountGroupsPanelMixin:OnHide()
    LM.UIFilter.UnregisterAllCallbacks(self)
end

function LiteMountGroupsPanelMixin:Update()
    self.allFlags = table.wipe(self.allFlags or {})
    for f in pairs(LM.Options:GetRawFlags()) do
        table.insert(self.allFlags, f)
    end
    table.sort(self.allFlags)
    if not tContains(self.allFlags, self.selectedFlag) then
        self.selectedFlag = self.allFlags[1]
    end
    self.Groups:Update()
    self.Mounts:Update()
    self.ShowAll:SetChecked(self.showAll)
end

--[[--------------------------------------------------------------------------]]--

LiteMountGroupsPanelGroupMixin = {}

function LiteMountGroupsPanelGroupMixin:OnClick()
    if self.flag then
        LiteMountGroupsPanel.selectedFlag = self.flag
        LiteMountGroupsPanel:Update()
    end
end

--[[--------------------------------------------------------------------------]]--

LiteMountGroupsPanelGroupsMixin = {}

function LiteMountGroupsPanelGroupsMixin:Update()
    if not self.buttons then return end

    local offset = HybridScrollFrame_GetOffset(self)
    local allFlags = self:GetParent().allFlags

    local totalHeight = (#allFlags + 1) * (self.buttons[1]:GetHeight() + 1)
    local displayedHeight = #self.buttons * self.buttons[1]:GetHeight()

    local showAddButton, index, button

    for i = 1, #self.buttons do
        button = self.buttons[i]
        index = offset + i
        if index <= #allFlags then
            local flagText = allFlags[index]
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
            button.DeleteButton:Hide()
            showAddButton = true
            button.flag = false
        else
            button:Hide()
            button.flag = nil
        end
        -- button:SetWidth(buttonWidth)
        button.SelectedTexture:SetShown(button.flag == self:GetParent().selectedFlag)
        button.SelectedArrow:SetShown(button.flag == self:GetParent().selectedFlag)
    end

    self.AddFlagButton:SetShown(showAddButton)

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

--[[--------------------------------------------------------------------------]]--

LiteMountGroupsPanelMountMixin = {}

function LiteMountGroupsPanelMountMixin:OnClick()
    local flag = LiteMountGroupsPanel.selectedFlag
    if self.mount:MatchesFilters(flag) then
        LM.Options:ClearMountFlag(self.mount, flag)
    else
        LM.Options:SetMountFlag(self.mount, flag)
    end
end

function LiteMountGroupsPanelMountMixin:OnEnter()
    if self.mount then
        LM.ShowMountTooltip(self, self.mount)
    end
end

function LiteMountGroupsPanelMountMixin:OnLeave()
    LM.HideMountTooltip()
end

function LiteMountGroupsPanelMountMixin:SetMount(mount, flag)
    self.mount = mount

    self.Name:SetText(mount.name)
    if flag and mount:MatchesFilters(flag) then
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

LiteMountGroupsPanelMountsMixin = {}

function LiteMountGroupsPanelMountsMixin:Update()
    if not self.buttons then return end

    local offset = HybridScrollFrame_GetOffset(self)

    local mounts = LM.UIFilter.GetFilteredMountList()

    local flag = self:GetParent().selectedFlag

    if not flag then
        for _, button in ipairs(self.buttons) do
            button:Hide()
        end
        HybridScrollFrame_Update(self, 0, 0)
        return
    end

    if not self:GetParent().showAll then
        mounts = mounts:Search(function (m) return m:CurrentFlags()[flag] end)
    end

    local col2offset

    if #mounts < #self.buttons then
        col2offset = #self.buttons
    else
        col2offset = math.ceil(#mounts/2)
    end

    for i, button in ipairs(self.buttons) do
        local index = offset + i
        local index2 = offset + col2offset + i
        if not flag or index > #mounts then
            button:Hide()
        else
            button.mount1:SetMount(mounts[index], flag)
            if button.mount1:IsMouseOver() then button.mount1:OnEnter() end
            if mounts[index2] then
                button.mount2:SetMount(mounts[index2], flag)
                button.mount2:Show()
                if button.mount2:IsMouseOver() then button.mount2:OnEnter() end
            else
                button.mount2:Hide()
            end
            button:Show()
        end
    end

    local totalHeight = col2offset * self.buttons[1]:GetHeight()
    local displayedHeight = #self.buttons * self.buttons[1]:GetHeight()

    HybridScrollFrame_Update(self, totalHeight, displayedHeight)
end

function LiteMountGroupsPanelMountsMixin:OnSizeChanged()
    HybridScrollFrame_CreateButtons(self, 'LiteMountGroupsPanelButtonTemplate')
    for _, b in ipairs(self.buttons) do
        b:SetWidth(self:GetWidth())
    end
end

function LiteMountGroupsPanelMountsMixin:OnLoad()
    local track = _G[self.scrollBar:GetName().."Track"]
    track:Hide()
    self.update = self.Update
end
