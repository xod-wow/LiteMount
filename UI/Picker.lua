--[[----------------------------------------------------------------------------

  LiteMount/UI/Picker.lua

  A pop-over for picking a thing from a list.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

--[[------------------------------------------------------------------------]]--

LiteMountPickerMixin = {}

local function UpdateScroll(self)
    if not self.buttons then return end

    if not LM.MountRegistry.mounts then
        HybridScrollFrame_Update(self, 0, 0)
        return
    end

    local offset = HybridScrollFrame_GetOffset(self)
    local mounts = LM.UIFilter.GetFilteredMountList()

    for buttonIndex, button in ipairs(self.buttons) do
        local index = ( offset + buttonIndex - 1 ) * #button.mount + 1
        if not mounts[index] then
            button:Hide()
        else
            for i = 1, #button.mount do
                local m = mounts[index+i-1]
                local b = button.mount[i]
                if m then
                    b.mount = m
                    b:SetText(m.name)
                    b:Show()
                    if not m:IsCollected() then
                        b:SetNormalFontObject("GameFontDisable")
                    else
                        b:SetNormalFontObject("GameFontNormal")
                    end
                else
                    b:Hide()
                end
            end
            button:Show()
        end
    end

    local numPerButton = #self.buttons[1].mount
    local buttonHeight = self.buttons[1]:GetHeight()
    local totalHeight = math.ceil(#mounts/numPerButton) * buttonHeight
    local displayedHeight = #self.buttons * buttonHeight
    HybridScrollFrame_Update(self, totalHeight, displayedHeight)
end

function LiteMountPickerMixin:Update()
    UpdateScroll(self.Scroll)
end

local function OnClick(button)
    LiteMountPicker:RunCallback(button.mount)
    LiteMountPicker:Hide()
end

function LiteMountPickerMixin:OnSizeChanged()
    HybridScrollFrame_CreateButtons(self.Scroll, "LiteMountPickerButtonTemplate")
    for _, b in ipairs(self.Scroll.buttons) do
        b:SetWidth(self.Scroll:GetWidth())
        local subW = ( b:GetWidth() - 12 ) / #b.mount - 4
        for i = 1, #b.mount do
            b.mount[i]:SetWidth(subW)
            b.mount[i]:SetPoint("LEFT", b, "LEFT", 8+(i-1)*(subW+4), 0)
            b.mount[i]:SetScript('OnClick', OnClick)
        end
    end
    UpdateScroll(self.Scroll)
end

function LiteMountPickerMixin:OnShow()
    LiteMountFilter:Attach(self, "BOTTOM", self.Scroll, "TOP", 0, 8)
    LM.UIFilter.RegisterCallback(self, "OnFilterChanged", "Update")
    self:Update()
end

function LiteMountPickerMixin:OnHide()
    self.callback = nil
    self.callbackFrame = nil
    LM.UIFilter.UnregisterAllCallbacks(self)
end

function LiteMountPickerMixin:OnLoad()
    self.Scroll.scrollBar.doNotHide = false
    self.Scroll.update = UpdateScroll
end

function LiteMountPickerMixin:SetCallback(callback, frame)
    self.callback = callback
    self.callbackFrame = frame
end

function LiteMountPickerMixin:RunCallback(mount)
    if self.callback then
        self.callback(self.callbackFrame, mount)
    end
end
