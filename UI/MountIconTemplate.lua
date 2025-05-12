--[[----------------------------------------------------------------------------

  LiteMount/UI/MountIconTemplate.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

local L = LM.Localize

local allTypeFlags = LM.Options:GetFlags()

--[[------------------------------------------------------------------------]]--

-- This is a minimal emulation of LM.ActionButton

LiteMountMountIconMixin = {}

function LiteMountMountIconMixin.MenuGenerator(owner, rootDescription)
    rootDescription:CreateTitle(owner.mount.name)
    local priorityMenu = rootDescription:CreateButton(L.LM_PRIORITY)
    for _,p in ipairs(LM.UIFilter.GetPriorities()) do
        local t, d = LM.UIFilter.GetPriorityText(p)
        local function IsSelected() return owner.mount:GetPriority() == p end
        local function SetSelected() LM.Options:SetPriority(owner.mount, p) end
        priorityMenu:CreateRadio(t..' - '..d, IsSelected, SetSelected)
    end
    for _, flag in ipairs(allTypeFlags) do
        local function IsSelected()
            local mountFlags = owner.mount:GetFlags()
            return mountFlags[flag]
        end
        local function SetSelected()
            if IsSelected() then
                LM.Options:ClearMountFlag(owner.mount, flag)
            else
                LM.Options:SetMountFlag(owner.mount, flag)
            end
        end
        rootDescription:CreateCheckbox(L[flag], IsSelected, SetSelected)
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
    if self.ount.spellID then
        C_Spell.PickupSpell(mount.spellID)
    elseif self.ount.itemID then
        C_Item.PickupItem(mount.itemID)
    end
end
