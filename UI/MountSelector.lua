--[[----------------------------------------------------------------------------

  LiteMount/UI/MountSelector.lua

  This a a mount grouping selector frame, with a left scroll with mounts that
  are "Out" and a right scroll with mounts that are "In", and the ability to
  move mounts from one to the other.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

--[[------------------------------------------------------------------------]]--

LiteMountSelectorButtonMixin = {}

function LiteMountSelectorButtonMixin:SetMount(mount)
    self.mount = mount
    if self.mount then
        self.Icon:SetTexture(mount.icon)
        self.Name:SetText(mount.name)
    end
end

function LiteMountSelectorButtonMixin:OnClick()
    local scroll = self:GetParent():GetParent()
    if scroll.selected[self.mount] then
        scroll.selected[self.mount] = nil
    else
        scroll.selected[self.mount] = true
    end
    scroll:Update()
end

--[[------------------------------------------------------------------------]]--

LiteMountSelectorMoveButtonMixin = {}

function LiteMountSelectorMoveButtonMixin:OnClick(mouseButton)
    local parent = self:GetParent()
    local from, to

    if self.direction == 'In' then
        from = parent.Out
        to = parent.In
    else
        from = parent.In
        to = parent.Out
    end

    for m in pairs(from.selected) do
        tDeleteItem(from.mounts, m)
        table.insert(to.mounts, m)
    end
    Mixin(to.selected, from.selected)
    table.wipe(from.selected)
    to.mounts:Sort()

    from:Update()
    to:Update()
end

--[[------------------------------------------------------------------------]]--

LiteMountSelectorScrollMixin = {}

function LiteMountSelectorScrollMixin:OnSizeChanged()
    HybridScrollFrame_CreateButtons(self, "LiteMountSelectorButtonTemplate")
    for _, b in ipairs(self.buttons) do
        b:SetWidth(self:GetWidth() - self.scrollBar:GetWidth())
    end
    self:Update()
end

function LiteMountSelectorScrollMixin:OnLoad()
    -- Move the scrollbar fully inside the frame
    self.scrollBar:ClearAllPoints()
    local topYOff = self.scrollUp:GetHeight()
    local bottomYOff = self.scrollDown:GetHeight()
    self.scrollBar:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -topYOff)
    self.scrollBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, bottomYOff)

    _G[self.scrollBar:GetName().."Track"]:SetVertexColor(0.4, 0.4, 0.4, 0.1)
    self.scrollBar.doNotHide = false
    self.update = self.Update
end

function LiteMountSelectorScrollMixin:Update()
    if not self.buttons then return end

    local offset = HybridScrollFrame_GetOffset(self)

    local mounts = self.mounts or {}

    local totalHeight = #mounts * self.buttons[1]:GetHeight()
    local displayedHeight = #self.buttons * self.buttons[1]:GetHeight()

    for i = 1, #self.buttons do
        local button = self.buttons[i]
        local index = offset + i
        if index <= #mounts then
            local mount = mounts[index]
            button:SetMount(mount)
            button.SelectedTexture:SetShown(self.selected[mount])
            button:Show()
        else
            button:SetMount(nil)
            button:Hide()
        end
    end
    HybridScrollFrame_Update(self, totalHeight, displayedHeight)
end

--[[------------------------------------------------------------------------]]--

LiteMountSelectorMixin = {}

function LiteMountSelectorMixin:OnLoad()
end

function LiteMountSelectorMixin:SetFlag(flag)
    if flag then
        self.Out.mounts = LM.PlayerMounts:FilterSearch('~'..flag)
        self.Out.mounts:Sort()
        self.In.mounts = LM.PlayerMounts:FilterSearch(flag)
        self.In.mounts:Sort()
    else
        self.Out.mounts = nil
        self.In.mounts = nil
    end
    self.Out.selected = table.wipe(self.Out.selected or {})
    self.Out:Update()
    self.In.selected = table.wipe(self.In.selected or {})
    self.In:Update()
end
