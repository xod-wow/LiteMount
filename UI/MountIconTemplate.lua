--[[----------------------------------------------------------------------------

  LiteMount/UI/MountIconTemplate.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

local L = LM.Localize

--[[------------------------------------------------------------------------]]--

-- This is a minimal emulation of LM.ActionButton

LiteMountMountIconMixin = {}

function LiteMountMountIconMixin.MenuGenerator(owner, rootDescription)
    rootDescription:CreateTitle(owner.mount.name)

    local mountGroups = owner.mount:GetGroups()
    local allGroups = LM.Options:GetGroupNames()

    local groupMenu = rootDescription:CreateButton(L.LM_GROUPS)
    for _, g in pairs(allGroups) do
        local function IsSelected() return mountGroups[g] end
        local function SetSelected(...)
            if mountGroups[g] then
                LM.Options:ClearMountGroup(owner.mount, g)
            else
                LM.Options:SetMountGroup(owner.mount, g)
            end
        end
        if LM.Options:IsGlobalGroup(g) then
            g = BLUE_FONT_COLOR:WrapTextInColorCode(g)
        end
        groupMenu:CreateRadio(g, IsSelected, SetSelected)
    end

    local priorityMenu = rootDescription:CreateButton(L.LM_PRIORITY)
    for _,p in ipairs(LM.UIFilter.GetPriorities()) do
        local t, d = LM.UIFilter.GetPriorityColorTexts(p)
        local function IsSelected() return owner.mount:GetPriority() == p end
        local function SetSelected() LM.Options:SetPriority(owner.mount, p) end
        priorityMenu:CreateRadio(t..' - '..d, IsSelected, SetSelected)
    end

    if owner.mount.flags.FLY then
        local function IsSelected()
            return LM.Options:GetUseOnGround(owner.mount)
        end
        local function SetSelected()
            local wasEnabled = IsSelected()
            LM.Options:SetUseOnGround(owner.mount, not wasEnabled)
        end
        local button = rootDescription:CreateCheckbox(L.RUN, IsSelected, SetSelected)
        button:SetTooltip(function (tooltip) tooltip:AddLine(L.LM_USE_FLYING_AS_GROUND) end)
    end
end

function LiteMountMountIconMixin:SetMount(mount, hasMenu)
    self.mount = mount
    self.hasMenu = hasMenu

    self:SetNormalTexture(mount.icon)

    local count = mount:GetSummonCount()
    if count > 0 then
        self.Count:SetText(count)
        self.Count:Show()
    else
        self.Count:Hide()
    end

    if not InCombatLockdown() then
        local action = mount:GetCastAction()
        action:SetupActionButton(self, 1)
    end
end

function LiteMountMountIconMixin:OnEnter()
    LiteMountTooltip:SetOwner(self, "ANCHOR_RIGHT", 8)
    LiteMountTooltip:SetMount(self.mount, self.hasMenu)
end

function LiteMountMountIconMixin:OnLeave()
    LiteMountTooltip:Hide()
end

function LiteMountMountIconMixin:OnClickHook(mouseButton, isDown)
    if mouseButton == 'LeftButton' and self.clickHookFunction then
        self.clickHookFunction()
    end
end

function LiteMountMountIconMixin:PreClick(mouseButton, isDown)
    if mouseButton == 'LeftButton' and IsModifiedClick("CHATLINK") then
        ChatEdit_InsertLink(C_Spell.GetSpellLink(self.mount.spellID))
    elseif mouseButton == 'RightButton' then
        if self.hasMenu then
            MenuUtil.CreateContextMenu(self, self.MenuGenerator)
        end
    end
end

function LiteMountMountIconMixin:OnLoad()
    self:SetAttribute("unit", "player")
    self:RegisterForClicks("AnyUp")
    self:RegisterForDrag("LeftButton")
    self:SetScript('PreClick', self.PreClick)
    self:HookScript('OnClick', self.OnClickHook)
end

function LiteMountMountIconMixin:OnDragStart()
    if self.mount.spellID then
        C_Spell.PickupSpell(self.mount.spellID)
    elseif self.mount.itemID then
        C_Item.PickupItem(self.mount.itemID)
    end
end
