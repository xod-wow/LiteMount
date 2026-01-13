--[[----------------------------------------------------------------------------

  LiteMount/UI/Falling.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize


--[[------------------------------------------------------------------------]]--

LiteMountItemSpellMixin = {}

function LiteMountItemSpellMixin:Initialize(elementData, DeleteCallback)
    self.DeleteButton:SetScript('OnClick', DeleteCallback)
    local type, id = string.split(':', elementData)
    if type == 'spell' then
        local spell = Spell:CreateFromSpellID(tonumber(id))
        if spell:IsSpellEmpty() then
            self.link = nil
        else
            spell:ContinueOnSpellLoad(
                function ()
                    -- SpellMixin is lacking in Classic
                    self.link = C_Spell.GetSpellLink(id)
                    local info = C_Spell.GetSpellInfo(id)
                    self.Icon:SetTexture(info.iconID)
                    self.Name:SetText(info.name)
                end)
        end
    elseif type == 'item' then
        local item = Item:CreateFromItemID(tonumber(id))
        if item:IsItemEmpty() then
            self.link = nil
        else
            item:ContinueOnItemLoad(
                function ()
                    self.link = item:GetItemLink()
                    self.Icon:SetTexture(item:GetItemIcon())
                    self.Name:SetText(item:GetItemName())
                end)
        end
    end
end

function LiteMountItemSpellMixin:OnEnter()
    if self.link then
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
        GameTooltip:SetHyperlink(self.link)
    end
end

function LiteMountItemSpellMixin:OnLeave()
    GameTooltip_Hide()
end


--[[------------------------------------------------------------------------]]--

LiteMountFallingAddMixin = {}

local addTypeOptions = { 'item', 'spell' }
local addTypeTexts = { item = HELPFRAME_ITEM_TITLE, spell = STAT_CATEGORY_SPELL }

local function BindingGenerator(owner, rootDescription)
    local parent = owner:GetParent()
    for _, v in ipairs(addTypeOptions) do
        local text = addTypeTexts[v]
        local function IsSelected() return parent.type == v end
        local function SetSelected() return parent:SetType(v) end
        rootDescription:CreateRadio(text, IsSelected, SetSelected)
    end
end

function LiteMountFallingAddMixin:Update()
    local text = self.EditBox:GetText()
    if text == '' then
        self.Name:SetText('')
        return self.AddButton:Disable()
    elseif self.type == 'item' then
        local itemID = C_Item.GetItemInfoInstant(text)
        if not itemID then
            self.Name:SetText(text or '')
            self.AddButton:Disable()
        else
            local isUsable = C_Item.IsUsableItem(itemID)
            local toyUsable = C_ToyBox.GetToyInfo(itemID) and C_ToyBox.IsToyUsable(itemID)
            local name = C_Item.GetItemNameByID(itemID)
            self.Name:SetText(name)
            self.AddButton:SetEnabled(isUsable or toyUsable)
        end
    elseif self.type == 'spell' then
        local name = C_Spell.GetSpellName(text)
        self.Name:SetText(name or '')
        self.AddButton:SetEnabled(name ~= nil)
    end
end

function LiteMountFallingAddMixin:Add()
    local falling = CopyTable(LM.Options:GetOption('falling'))
    local entry
    if self.type == 'item' then
        local itemID = C_Item.GetItemInfoInstant(self.EditBox:GetText())
        if itemID then
            entry = self.type .. ':' .. itemID
        end
    elseif self.type == 'spell' then
        local info = C_Spell.GetSpellInfo(self.EditBox:GetText())
        if info then
            entry = self.type .. ':' .. info.spellID
        end
    end
    if entry and not tContains(falling, entry) then
        table.insert(falling, entry)
        LM.Options:SetOption('falling', falling)
    end
    self:Hide()
end

function LiteMountFallingAddMixin:OnLoad()
    self.EditBox:SetScript('OnTextChanged', function () self:Update() end)
    self.AddButton:SetScript('OnClick', function () self:Add() end)
    self.CancelButton:SetScript('OnClick', function () self:Hide() end)
end

function LiteMountFallingAddMixin:SetType(v)
    if v ~= self.type then
        self.EditBox:SetText('')
    end
    self.type = v
end

function LiteMountFallingAddMixin:OnShow()
    self.type = addTypeOptions[1]
    self.EditBox:SetText('')
    self:Update()
    self.Dropdown:SetupMenu(BindingGenerator)
end

--[[------------------------------------------------------------------------]]--

LiteMountFallingPanelMixin = {}

function LiteMountFallingPanelMixin:OnLoad()
    local view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("LiteMountItemSpellTemplate",
        function (button, elementData)
            local function Delete()
                self.Scroll.isDirty = true
                local falling = LM.Options:GetOption('falling')
                tDeleteItem(falling, elementData)
                LM.Options:SetOption('falling', falling)
            end
            button:Initialize(elementData, Delete)
        end)
    ScrollUtil.InitScrollBoxListWithScrollBar(self.Scroll, self.ScrollBar, view)

    local dragBehavior = ScrollUtil.InitDefaultLinearDragBehavior(self.Scroll)
    dragBehavior:SetReorderable(true)
    dragBehavior:SetPostDrop(
        function (contextData)
            self.Scroll.isDirty = true
            local falling = {}
            for _, elementData in contextData.dataProvider:EnumerateEntireRange() do
                table.insert(falling, elementData)
            end
            LM.Options:SetOption('falling', falling)
        end)

    self.AddButton:SetScript('OnClick',
        function ()
            LiteMountOptionsPanel_PopOver(LiteMountFallingAdd, self)
        end)

    self.Scroll.GetOption =
        function ()
            return CopyTable(LM.Options:GetOption('falling'))
        end
    self.Scroll.GetOptionDefault =
        function ()
            return CopyTable(LM.Options:GetOptionDefault('falling'))
        end
    self.Scroll.SetOption =
        function (_, v)
            LM.Options:SetOption('falling', v)
        end
    self.Scroll.SetControl =
        function ()
            self:Refresh()
        end
    LiteMountOptionsPanel_RegisterControl(self.Scroll)
end

function LiteMountFallingPanelMixin:Refresh()
    local falling = LM.Options:GetOption('falling')
    local dp = CreateDataProvider(falling)
    self.Scroll:SetDataProvider(dp, ScrollBoxConstants.RetainScrollPosition)
end

function LiteMountFallingPanelMixin:OnShow()
    self:Refresh()
end

function LiteMountFallingPanelMixin:OnHide()
end
