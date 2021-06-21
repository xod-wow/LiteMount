--[[----------------------------------------------------------------------------

  LiteMount/UI/Picker.lua

  A pop-over for picking a thing from a list.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

--[[------------------------------------------------------------------------]]--

LiteMountPickerMixin = {}

local function UpdateScroll(self)
    if not self.buttons then return end

    if not LM.PlayerMounts.mounts then
        HybridScrollFrame_Update(self, 0, 0)
        return
    end

    local offset = HybridScrollFrame_GetOffset(self)
    local mounts = LM.UIFilter.GetFilteredMountList()

    for i, button in ipairs(self.buttons) do
        local index = ( offset + i - 1 ) * 3 + 1
        local m1, m2, m3 = mounts[index], mounts[index+1], mounts[index+2]

        if not m1 and not m2 then
            button:Hide()
        else
            button.mount1.mount = m1
            button.mount1:SetText(m1.name)
            if m2 then
                button.mount2.mount = m2
                button.mount2:SetText(m2.name)
                button.mount2:Show()
            else
                button.mount2:Hide()
            end
            if m3 then
                button.mount3.mount = m3
                button.mount3:SetText(m3.name)
                button.mount3:Show()
            else
                button.mount3:Hide()
            end
            button:Show()
        end
    end

    local totalHeight = math.ceil(#mounts/3) * self.buttons[1]:GetHeight()
    local displayedHeight = #self.buttons * self.buttons[1]:GetHeight()
    HybridScrollFrame_Update(self, totalHeight, displayedHeight)
end

function LiteMountPickerMixin:Update()
    UpdateScroll(self.Scroll)
end

function LiteMountPickerMixin:OnSizeChanged()
    HybridScrollFrame_CreateButtons(self.Scroll, "LiteMountPickerButtonTemplate")
    for _, b in ipairs(self.Scroll.buttons) do
        b:SetWidth(self.Scroll:GetWidth())
        b.mount2:SetWidth( (b:GetWidth() - 16 ) / 3)
    end
    UpdateScroll(self.Scroll)
end

function LiteMountPickerMixin:OnShow()
    LiteMountFilter:Attach(self, "BOTTOM", self.Scroll, "TOP", 0, 8)
    LM.UIFilter.RegisterCallback(self, "OnFilterChanged", "Update")
    self:Update()
end

function LiteMountPickerMixin:OnHide()
    LM.UIFilter.UnregisterAllCallbacks(self)
end

function LiteMountPickerMixin:OnLoad()
    self.Scroll.scrollBar.doNotHide = false
    self.Scroll.update = UpdateScroll
end
