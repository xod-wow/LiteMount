--[[----------------------------------------------------------------------------

  LiteMount/UI/Mounts.lua

  Options frame for the mount list.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local NUM_FLAG_BUTTONS = 5

local function tslice(t, first, last)
    local out = { }
    for i = first or 1, last or #t do
        tinsert(out, t[i])
    end
    return out
end

--[[--------------------------------------------------------------------------]]--

LiteMountPriorityMixin = {}

LiteMountPriorityMixin.PriorityColors = {
    [''] = COMMON_GRAY_COLOR,
    [0] =  RED_FONT_COLOR,
    [1] =  RARE_BLUE_COLOR,
    [2] =  EPIC_PURPLE_COLOR,
    [3] =  LEGENDARY_ORANGE_COLOR,
}

function LiteMountPriorityMixin:Update()
    local value = self:Get()
    if value then
        self.Minus:SetShown(value > LM.Options.MIN_PRIORITY)
        self.Plus:SetShown(value < LM.Options.MAX_PRIORITY)
        self.Priority:SetText(value)
    else
        self.Minus:Show()
        self.Plus:Show()
        self.Priority:SetText('')
    end
    local r, g, b = self.PriorityColors[value or '']:GetRGB()
    self.Background:SetColorTexture(r, g, b, 0.25)
end

function LiteMountPriorityMixin:Get()
    local mount = self:GetParent().mount
    if mount then
        return LM.Options:GetPriority(mount)
    end
end

function LiteMountPriorityMixin:Set(v)
    local mount = self:GetParent().mount
    if mount then
        LM.Options:SetPriority(mount, v or LM.Options.DEFAULT_PRIORITY)
        LiteMountMountsPanel.MountScroll.isDirty = true
    end
end

function LiteMountPriorityMixin:Increment()
    local v = self:Get()
    if v then
        self:Set(v + 1)
    else
        self:Set(LM.Options.DEFAULT_PRIORITY)
    end
end

function LiteMountPriorityMixin:Decrement()
    local v = self:Get() or LM.Options.DEFAULT_PRIORITY
    self:Set(v - 1)
end

function LiteMountPriorityMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine(L.LM_PRIORITY)
    for _,p in ipairs(LM.UIFilter.GetPriorities()) do
        local t, d = LM.UIFilter.GetPriorityText(p)
        GameTooltip:AddLine(t .. ' - ' .. d)
    end
    GameTooltip:Show()
end

function LiteMountPriorityMixin:OnLeave()
    GameTooltip:Hide()
end

--[[--------------------------------------------------------------------------]]--

LiteMountAllPriorityMixin = {}

function LiteMountAllPriorityMixin:Set(v)
    local mounts = LM.UIFilter.GetFilteredMountList()
    LM.Options:SetPriorities(mounts, v or LM.Options.DEFAULT_PRIORITY)
    LiteMountMountsPanel.MountScroll.isDirty = true
end

function LiteMountAllPriorityMixin:Get()
    local mounts = LM.UIFilter.GetFilteredMountList()

    local allValue

    for _,mount in ipairs(mounts) do
        local v = LM.Options:GetPriority(mount)
        if (allValue or v) ~= v then
            allValue = nil
            break
        else
            allValue = v
        end
    end

    return allValue
end

--[[--------------------------------------------------------------------------]]--

LiteMountFlagBitMixin = {}

function LiteMountFlagBitMixin:OnClick()
    local mount = self:GetParent().mount

    if self:GetChecked() then
        LM.Options:SetMountFlag(mount, self.flag)
    else
        LM.Options:ClearMountFlag(mount, self.flag)
    end
    LiteMountMountsPanel.MountScroll.isDirty = true
end

function LiteMountFlagBitMixin:OnEnter()
    if self.flag then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if self.flag == "FAVORITES" then
            GameTooltip:SetText("Blizzard " .. L[self.flag])
        else
            GameTooltip:SetText(L[self.flag])
        end
        GameTooltip:Show()
    end
end

function LiteMountFlagBitMixin:OnLeave()
    if GameTooltip:GetOwner() == self then
        GameTooltip:Hide()
    end
end

function LiteMountFlagBitMixin:Update(flag, mount)
    self.flag = flag

    if not flag then
        self:Hide()
        return
    else
        self:Show()
    end

    local cur = mount:CurrentFlags()

    self:SetChecked(cur[flag] or false)

    if flag == "FAVORITES" then
        self.Modified:Show()
        self.Modified:SetDesaturated(true)
        self:Disable()
    else
        -- If we changed this from the default then color the background
        self.Modified:SetShown(mount.flags[flag] ~= cur[flag])
        self.Modified:SetDesaturated(false)
        self:Enable()
    end
end

--[[--------------------------------------------------------------------------]]--

LiteMountMountIconMixin = {}

function LiteMountMountIconMixin:OnEnter()
    local m = self:GetParent().mount
    LM.ShowMountTooltip(self, m)
end

function LiteMountMountIconMixin:OnLeave()
    LM.HideMountTooltip()
    LiteMountPreview:Hide()
    GameTooltip:Hide()
end

function LiteMountMountIconMixin:PreClick(mouseButton)
    if mouseButton == 'LeftButton' and IsModifiedClick("CHATLINK") then
        local mount = self:GetParent().mount
        ChatEdit_InsertLink(GetSpellLink(mount.spellID))
    end
end

function LiteMountMountIconMixin:OnLoad()
    self:SetAttribute("unit", "player")
    self:RegisterForClicks("AnyUp")
    self:RegisterForDrag("LeftButton")
    self:SetScript('PreClick', self.PreClick)
end

function LiteMountMountIconMixin:OnDragStart()
    local mount = self:GetParent().mount
    if mount.spellID then
        PickupSpell(mount.spellID)
    elseif mount.itemID then
        PickupItem(mount.itemID)
    end
end


--[[--------------------------------------------------------------------------]]--

LiteMountMountButtonMixin = {}

function LiteMountMountButtonMixin:Update(pageFlags, mount)
    self.mount = mount
    self.Icon:SetNormalTexture(mount.icon)
    self.Name:SetText(mount.name)

    if not InCombatLockdown() then
        mount:GetCastAction():SetupActionButton(self.Icon, 2)
    end

    local i = 1
    while self["Bit"..i] do
        self["Bit"..i]:Update(pageFlags[i], mount)
        i = i + 1
    end

    if not mount.isCollected then
        self.Name:SetFontObject("GameFontDisable")
        self.Icon:GetNormalTexture():SetVertexColor(1, 1, 1)
        self.Icon:GetNormalTexture():SetDesaturated(true)
    elseif mount.isUsable == false then
        self.Name:SetFontObject("GameFontNormal")
        self.Icon:GetNormalTexture():SetDesaturated(true)
        self.Icon:GetNormalTexture():SetVertexColor(0.6, 0.2, 0.2)
    else
        self.Name:SetFontObject("GameFontNormal")
        self.Icon:GetNormalTexture():SetVertexColor(1, 1, 1)
        self.Icon:GetNormalTexture():SetDesaturated(false)
    end

    self.Priority:Update()
end

function LiteMountMountButtonMixin:OnShow()
    self:SetWidth(self:GetParent():GetWidth())
end

--[[--------------------------------------------------------------------------]]--

LiteMountMountScrollMixin = {}

-- Because we get attached inside the blizzard options container, we
-- are size 0x0 on create and even after OnShow, we have to trap
-- OnSizeChanged on the scrollframe to make the buttons correctly.
function LiteMountMountScrollMixin:CreateMoreButtons()
    HybridScrollFrame_CreateButtons(self, "LiteMountMountButtonTemplate",
                                    0, -1, "TOPLEFT", "TOPLEFT",
                                    0, -1, "TOP", "BOTTOM")
end

function LiteMountMountScrollMixin:OnLoad()
    local track = _G[self.scrollBar:GetName().."Track"]
    track:Hide()
    self.update = self.Update
end

function LiteMountMountScrollMixin:OnSizeChanged()
    self:CreateMoreButtons()
    self:Update()
    self.stepSize = self.buttonHeight
end

function LiteMountMountScrollMixin:Update()
    if not self.buttons then return end

    -- Because the Icon is a SecureActionButton and a child of the scroll
    -- buttons, we can't show or hide them in combat. Rather than throw a
    -- LUA error, it's better just not to do anything at all.

    if InCombatLockdown() then return end

    local offset = HybridScrollFrame_GetOffset(self)


    local mounts = LM.UIFilter.GetFilteredMountList()

    for i = 1, #self.buttons do
        local button = self.buttons[i]
        local index = offset + i
        if index <= #mounts then
            button:Update(LiteMountMountsPanel.pageFlags, mounts[index])
            button:Show()
            if button.Icon:IsMouseOver() then button.Icon:OnEnter() end
        else
            button:Hide()
        end
    end

    local totalHeight = self.buttonHeight * #mounts
    local shownHeight = self.buttonHeight * #self.buttons

    HybridScrollFrame_Update(self, totalHeight, shownHeight)
end

function LiteMountMountScrollMixin:GetOption()
    return {
        LM.Options:GetRawFlagChanges(),
        LM.Options:GetRawMountPriorities()
    }
end

function LiteMountMountScrollMixin:SetOption(v)
    LM.Options:SetRawFlagChanges(v[1])
    LM.Options:SetRawMountPriorities(v[2])
end

-- The only control: does all the triggered updating for the entire panel
function LiteMountMountScrollMixin:SetControl(v)
    self:GetParent():Update()
end

--[[--------------------------------------------------------------------------]]--

LiteMountMountsPanelMixin = {}

function LiteMountMountsPanelMixin:UpdateFlagPaging()
    local allFlags = LM.Options:GetAllFlags()

    self.maxFlagPages = math.ceil(#allFlags / NUM_FLAG_BUTTONS)

    -- If you change profiles the new one might have fewer pages
    self.currentFlagPage = Clamp(self.currentFlagPage, 1, self.maxFlagPages)

    self.PrevPageButton:SetEnabled(self.currentFlagPage ~= 1)
    self.NextPageButton:SetEnabled(self.currentFlagPage ~= self.maxFlagPages)

    local pageOffset = (self.currentFlagPage - 1 ) * NUM_FLAG_BUTTONS + 1
    self.pageFlags = tslice(allFlags, pageOffset, pageOffset+NUM_FLAG_BUTTONS-1)

    local label
    for i = 1, NUM_FLAG_BUTTONS do
        label = self["BitLabel"..i]
        if self.pageFlags[i] then
            label:SetText(L[self.pageFlags[i]])
            label:Show()
        else
            label:Hide()
        end
    end
end

function LiteMountMountsPanelMixin:Update()
    LM.UIFilter.ClearCache()
    self:UpdateFlagPaging()
    self.MountScroll:Update()
    self.AllPriority:Update()
end

function LiteMountMountsPanelMixin:default()
    LM.UIDebug(self, 'Custom_Default')
    LM.Options:ResetAllMountFlags()
    LM.Options:SetPriorities(LM.PlayerMounts.mounts, LM.Options.DEFAULT_PRIORITY)
    self.MountScroll.isDirty = true
end

function LiteMountMountsPanelMixin:NextFlagPage()
    self.currentFlagPage = self.currentFlagPage + 1
    LiteMountMountsPanel:Update()
end

function LiteMountMountsPanelMixin:PrevFlagPage()
    self.currentFlagPage = self.currentFlagPage - 1
    LiteMountMountsPanel:Update()
end

function LiteMountMountsPanelMixin:OnLoad()

    -- Because we're the wrong size at the moment we'll only have 1 button after
    -- this but that's enough to stop everything crapping out.
    self.MountScroll:CreateMoreButtons()

    self.name = MOUNTS

    -- We are using the MountScroll SetControl to do ALL the updating.

    LiteMountOptionsPanel_RegisterControl(self.MountScroll)

    self.currentFlagPage = 1
    self.maxFlagPages = 1
    self.pageFlags = { }

    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountMountsPanelMixin:OnShow()
    LiteMountFilter:Attach(self, 'BOTTOMLEFT', self.MountScroll, 'TOPLEFT', 0, 15)
    LM.UIFilter.RegisterCallback(self, "OnFilterChanged", "refresh")
    LM.PlayerMounts:RefreshMounts()
    LiteMountOptionsPanel_OnShow(self)
end

function LiteMountMountsPanelMixin:OnHide()
    LM.UIFilter.UnregisterAllCallbacks(self)
    LiteMountOptionsPanel_OnHide(self)
end

