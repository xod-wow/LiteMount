--[[----------------------------------------------------------------------------

  LiteMount/UI/Picker.lua

  A pop-over for picking a thing from a list.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

--[[------------------------------------------------------------------------]]--

LiteMountPickerButtonMixin = {}

function LiteMountPickerButtonMixin:Set(object)
    self.object = object
    if object.icon then
        self.Icon:SetTexture(object.icon)
    else
        self.Icon:Hide()
    end
    self.Text:SetText(object.name)
end

function LiteMountPickerButtonMixin:OnClick()
    LiteMountPicker.selected = self.object
    LiteMountPicker:Hide()
end

--[[------------------------------------------------------------------------]]--

LiteMountPickerMixin = {}

local function UpdateScroll(self)
    if not self.buttons then return end

    if not LM.PlayerMounts.mounts then
        HybridScrollFrame_Update(self, 0, 0)
        return
    end

    local offset = HybridScrollFrame_GetOffset(self)

    local mounts = LM.PlayerMounts.mounts:Copy()
    table.sort(mounts, function (a,b) return a.name < b.name end)

    local totalHeight = #mounts * self.buttons[1]:GetHeight()
    local displayedHeight = #self.buttons * self.buttons[1]:GetHeight()

    for i = 1, #self.buttons do
        local button = self.buttons[i]
        local index = offset + i
        if index <= #mounts then
            local mount = mounts[index]
            button:Set(mount)
            button:Show()
        else
            button:Hide()
        end
    end
    HybridScrollFrame_Update(self, totalHeight, displayedHeight)
end

function LiteMountPickerMixin:Update()
    UpdateScroll(self.Scroll)
end

function LiteMountPickerMixin:OnSizeChanged()
    HybridScrollFrame_CreateButtons(self.Scroll, "LiteMountPickerButtonTemplate")
    for _, b in ipairs(self.Scroll.buttons) do
        b:SetWidth(self.Scroll:GetWidth())
    end
    UpdateScroll(self.Scroll)
end

function LiteMountPickerMixin:OnShow()
    self.selected = nil
    self:Update()
end

function LiteMountPickerMixin:OnLoad()
    self.Scroll.scrollBar.doNotHide = false

    local track = _G[self.Scroll.scrollBar:GetName().."Track"]
    track:Hide()

    self.Scroll.update = UpdateScroll
end
