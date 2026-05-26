--[[----------------------------------------------------------------------------
  LiteMount/UI/Picker.lua

  A pop-over for picking a thing from a list.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.L

--[[------------------------------------------------------------------------]]--


local function PickerButtonInitializer(button, elementData)
    local w = button:GetParent():GetWidth()
    local subW = ( w - 12 ) / #button.mount - 4
    button:SetWidth(w)
    for i, b in ipairs(button.mount) do
        local m = elementData[i]
        if m then
            b:SetText(m.name)
            b:SetWidth(subW)
            b:ClearAllPoints()
            b:SetPoint("LEFT", button, "LEFT", 8+(i-1)*(subW+4), 0)
            b:SetScript('OnClick',
                function ()
                    LiteMountPicker:RunCallback(m)
                    LiteMountPicker:Hide()
                end)
            if not m:IsCollected() then
                b:SetNormalFontObject("GameFontDisable")
            else
                b:SetNormalFontObject("GameFontNormal")
            end
            b:Show()
        else
            b:Hide()
        end
    end
end


--[[------------------------------------------------------------------------]]--

LiteMountPickerMixin = {}

function LiteMountPickerMixin:RefreshDisplay()
    LM.MountRegistry:RefreshMounts(true)
    local mounts = LM.UIFilter.GetFilteredMountList()
    local mountTriples = {}

    for i, m in ipairs(mounts) do
        local index = math.ceil(i/3)
        local offset = (i % 3) + 1
        mountTriples[index] = mountTriples[index] or {}
        mountTriples[index][offset] = m
    end

    local dp = CreateDataProvider(mountTriples)
    self.Scroll:SetDataProvider(dp, ScrollBoxConstants.RetainScrollPosition)

    LiteMountPopOverPanelMixin.RefreshDisplay(self)
end

function LiteMountPickerMixin:OnShow()
    LiteMountFilter:Attach(self, "BOTTOM", self.Scroll, "TOP", 0, 8)
    LM.UIFilter.RegisterCallback(self, "OnFilterChanged", "RefreshDisplay")
    LiteMountPopOverPanelMixin.OnShow(self)
end

function LiteMountPickerMixin:OnHide()
    self.callback = nil
    LM.UIFilter.UnregisterAllCallbacks(self)
    LiteMountPopOverPanelMixin.OnHide(self)
end

function LiteMountPickerMixin:OnLoad()
    local view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("LiteMountPickerButtonTemplate", PickerButtonInitializer)
    ScrollUtil.InitScrollBoxListWithScrollBar(self.Scroll, self.ScrollBar, view)

    LiteMountPopOverPanelMixin.OnLoad(self)
end

function LiteMountPickerMixin:SetCallback(callback)
    self.callback = callback
end

function LiteMountPickerMixin:RunCallback(mount)
    if self.callback then
        self.callback(mount)
    end
end
