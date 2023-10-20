--[[----------------------------------------------------------------------------

  LiteMount/UI/Mounts.lua

  Options frame for the mount list.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

--[[------------------------------------------------------------------------]]--

LiteMountPriorityMixin = {}

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
    if LM.Options:GetOption('randomWeightStyle') == 'Rarity' and value ~= 0 then
        local r, g, b = LM.UIFilter.GetPriorityColor(''):GetRGB()
        self.Background:SetColorTexture(r, g, b, 0.33)
    else
        local r, g, b = LM.UIFilter.GetPriorityColor(value):GetRGB()
        self.Background:SetColorTexture(r, g, b, 0.33)
    end
end

function LiteMountPriorityMixin:Get()
    local mount = self:GetParent().mount
    if mount then
        return mount:GetPriority()
    end
end

function LiteMountPriorityMixin:Set(v)
    local mount = self:GetParent().mount
    if mount then
        LiteMountMountsPanel.MountScroll.isDirty = true
        LM.Options:SetPriority(mount, v or LM.Options.DEFAULT_PRIORITY)
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

    if LM.Options:GetOption('randomWeightStyle') == 'Rarity' then
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(L.LM_RARITY_DISABLES_PRIORITY, 1, 1, 1, true)
        GameTooltip:AddLine(' ')
    end

    for _,p in ipairs(LM.UIFilter.GetPriorities()) do
        local t, d = LM.UIFilter.GetPriorityText(p)
        GameTooltip:AddLine(t .. ' - ' .. d)
    end
    GameTooltip:Show()
end

function LiteMountPriorityMixin:OnLeave()
    GameTooltip:Hide()
end

--[[------------------------------------------------------------------------]]--

LiteMountAllPriorityMixin = {}

function LiteMountAllPriorityMixin:Set(v)
    local mounts = LM.UIFilter.GetFilteredMountList()
    LiteMountMountsPanel.MountScroll.isDirty = true
    LM.Options:SetPriorities(mounts, v or LM.Options.DEFAULT_PRIORITY)
end

function LiteMountAllPriorityMixin:Get()
    local mounts = LM.UIFilter.GetFilteredMountList()

    local allValue

    for _,mount in ipairs(mounts) do
        local v = mount:GetPriority()
        if (allValue or v) ~= v then
            allValue = nil
            break
        else
            allValue = v
        end
    end

    return allValue
end

--[[------------------------------------------------------------------------]]--

LiteMountFlagBitMixin = {}

function LiteMountFlagBitMixin:OnClick()
    local mount = self:GetParent().mount

    LiteMountMountsPanel.MountScroll.isDirty = true
    if self:GetChecked() then
        LM.Options:SetMountFlag(mount, self.flag)
    else
        LM.Options:ClearMountFlag(mount, self.flag)
    end
end

function LiteMountFlagBitMixin:OnEnter()
    if self.flag then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L[self.flag])
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

    local cur = mount:GetFlags()

    self:SetChecked(cur[flag] or false)

    -- If we changed this from the default then color the background
    self.Modified:SetShown(mount.flags[flag] ~= cur[flag])

    -- You can turn off any flag, but the only ones you can turn on when they
    -- were originally off are RUN for flying and dragonriding mounts and
    -- SWIM for any mount.

    if cur[flag] or mount.flags[flag] then
        self:Enable()
        self:Show()
    elseif flag == "SWIM" then
        self:Enable()
        self:Show()
    elseif flag == "RUN" and ( mount.flags.FLY or mount.flags.DRAGONRIDING ) then
        self:Enable()
        self:Show()
    else
        self:Hide()
        self:Disable()
    end

end

--[[------------------------------------------------------------------------]]--

LiteMountMountIconMixin = {}

function LiteMountMountIconMixin:OnEnter()
    local m = self:GetParent().mount
    LiteMountTooltip:SetOwner(self, "ANCHOR_RIGHT", 8)
    LiteMountTooltip:SetMount(m, true)
end

function LiteMountMountIconMixin:OnLeave()
    LiteMountTooltip:Hide()
end

function LiteMountMountIconMixin:PreClick(mouseButton)
    if mouseButton == 'LeftButton' and IsModifiedClick("CHATLINK") then
        local mount = self:GetParent().mount
        ChatEdit_InsertLink(GetSpellLink(mount.spellID))
    end
end

function LiteMountMountIconMixin:OnLoad()
    self:SetAttribute("unit", "player")
    self:RegisterForClicks("AnyUp", "AnyDown")
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


--[[------------------------------------------------------------------------]]--

LiteMountMountButtonMixin = {}

function LiteMountMountButtonMixin:Update(bitFlags, mount)
    self.mount = mount
    self.Icon:SetNormalTexture(mount.icon)
    self.Name:SetText(mount.name)

    local count = mount:GetSummonCount()
    if count > 0 then
        self.Icon.Count:SetText(count)
        self.Icon.Count:Show()
    else
        self.Icon.Count:Hide()
    end

    if not InCombatLockdown() then
        mount:GetCastAction():SetupActionButton(self.Icon, 2)
    end

    local i = 1
    while self["Bit"..i] do
        self["Bit"..i]:Update(bitFlags[i], mount)
        i = i + 1
    end

    local flagTexts = { }

    for _, flag in ipairs(LM.Options:GetFlags()) do
        if mount.flags[flag] then
            table.insert(flagTexts, L[flag])
        end
        self.Types:SetText(strjoin(' ', unpack(flagTexts)))
    end

    local rarity = mount:GetRarity()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and rarity then
        self.Rarity:SetFormattedText(L.LM_RARITY_FORMAT, rarity)
        self.Rarity.toolTip = format(L.LM_RARITY_FORMAT_LONG, rarity)
    else
        self.Rarity:SetText('')
        self.Rarity.toolTip = nil
    end

    if not mount.isCollected then
        self.Name:SetFontObject("GameFontDisable")
        self.Icon:GetNormalTexture():SetVertexColor(1, 1, 1)
        self.Icon:GetNormalTexture():SetDesaturated(true)
    elseif not mount:IsUsable() then
        -- In retail mounts are made red if you can't use them ever
        self.Name:SetFontObject("GameFontNormal")
        self.Icon:GetNormalTexture():SetDesaturated(true)
        self.Icon:GetNormalTexture():SetVertexColor(0.6, 0.2, 0.2)
    elseif WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC and not mount:IsMountable() then
        -- In classic mounts are made red if you can't use them right now
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

--[[------------------------------------------------------------------------]]--

LiteMountMountScrollMixin = {}

-- Because we get attached inside the blizzard options container, we
-- are size 0x0 on create and even after OnShow, we have to trap
-- OnSizeChanged on the scrollframe to make the buttons correctly.
function LiteMountMountScrollMixin:CreateMoreButtons()
    HybridScrollFrame_CreateButtons(self, "LiteMountMountButtonTemplate")
end

function LiteMountMountScrollMixin:OnLoad()
    local track = _G[self.scrollBar:GetName().."Track"]
    track:Hide()
    self.update = self.Update
end

function LiteMountMountScrollMixin:OnSizeChanged()
    self:CreateMoreButtons()
    self:Update()
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
            button:Update(LiteMountMountsPanel.allFlags, mounts[index])
            button:Show()
            if button.Icon:IsMouseOver() then button.Icon:OnEnter() end
        else
            button:Hide()
        end
    end

    -- It's really not clear exactly what these should be, and as far as I can
    -- tell even the Blizzard usages are not consistent. I think it should probably
    -- include the inter-button gaps from HybridScrollFrame_CreateButtons, so in
    -- the end it was easier not to have gaps so this was right either way.

    local totalHeight = #mounts * self.buttonHeight
    local shownHeight = self:GetHeight()

    HybridScrollFrame_Update(self, totalHeight, shownHeight)
end

function LiteMountMountScrollMixin:GetOption()
    return {
        LM.tCopyShallow(LM.Options:GetRawFlagChanges()),
        LM.tCopyShallow(LM.Options:GetRawMountPriorities())
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

--[[------------------------------------------------------------------------]]--

LiteMountMountsPanelMixin = {}

function LiteMountMountsPanelMixin:Update()
    LM.UIFilter.ClearCache()
    self.MountScroll:Update()
    self.AllPriority:Update()
end

function LiteMountMountsPanelMixin:OnDefault()
    LM.UIDebug(self, 'Custom_Default')
    self.MountScroll.isDirty = true
    LM.Options:ResetAllMountFlags()
    LM.Options:SetPriorities(LM.MountRegistry.mounts, nil)
end

function LiteMountMountsPanelMixin:OnLoad()

    -- Because we're the wrong size at the moment we'll only have 1 button after
    -- this but that's enough to stop everything crapping out.
    self.MountScroll:CreateMoreButtons()

    self.name = MOUNTS

    self.allFlags = LM.Options:GetFlags()

    for i = 1, 4 do
        local label = self["BitLabel"..i]
        if self.allFlags[i] then
            label:SetText(L[self.allFlags[i]])
        end
    end

    self:SetScript('OnEvent', function () self.MountScroll:Update() end)

    -- We are using the MountScroll SetControl to do ALL the updating.

    LiteMountOptionsPanel_RegisterControl(self.MountScroll)

    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountMountsPanelMixin:OnShow()
    LiteMountFilter:Attach(self, 'BOTTOMLEFT', self.MountScroll, 'TOPLEFT', 0, 15)
    LM.UIFilter.RegisterCallback(self, "OnFilterChanged", "OnRefresh")
    LM.MountRegistry:RefreshMounts()
    LM.MountRegistry.RegisterCallback(self, "OnMountSummoned", "OnRefresh")

    -- Update the counts, Journal-only
    local counts = LM.MountRegistry:GetJournalTotals()
    self.Counts:SetText(
            string.format(
                '%s: %s %s: %s %s: %s',
                TOTAL,
                WHITE_FONT_COLOR:WrapTextInColorCode(counts.total),
                COLLECTED,
                WHITE_FONT_COLOR:WrapTextInColorCode(counts.collected),
                L.LM_USABLE,
                WHITE_FONT_COLOR:WrapTextInColorCode(counts.usable)
            )
        )

    self:RegisterEvent('MOUNT_JOURNAL_USABILITY_CHANGED')

    LiteMountOptionsPanel_OnShow(self)
end

function LiteMountMountsPanelMixin:OnHide()
    LM.UIFilter.UnregisterAllCallbacks(self)
    LM.MountRegistry.UnregisterAllCallbacks(self)
    self:UnregisterAllEvents()
    LiteMountOptionsPanel_OnHide(self)
end

