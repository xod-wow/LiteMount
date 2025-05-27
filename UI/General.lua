--[[----------------------------------------------------------------------------

  LiteMount/UI/General.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local persistOptions = {
    { 0,    string.format("%s (%s)", L.LM_EVERY_TIME, DEFAULT) },
    { 30,   format(L.LM_EVERY_D_SECONDS, 30) },
    { 120,  format(L.LM_EVERY_D_MINUTES, 2) },
    { 300,  format(L.LM_EVERY_D_MINUTES, 5) },
    { 1800, format(L.LM_EVERY_D_MINUTES, 30) },
}

local function RandomPersistGenerator(owner, rootDescription)
    local IsSelected = function (v) return v == LM.Options:GetOption('randomKeepSeconds') end
    local SetSelected = function (v) LM.Options:SetOption('randomKeepSeconds', v) end
    for _, info in ipairs(persistOptions) do
        rootDescription:CreateRadio(info[2], IsSelected, SetSelected, info[1])
    end
end

local styleOptions = {
    { 'Priority', string.format("%s (%s)", L.LM_SUMMON_STYLE_PRIORITY, DEFAULT)  },
    { 'Rarity', L.LM_SUMMON_STYLE_RARITY, disabled=(WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE) },
    { 'LeastUsed', L.LM_SUMMON_STYLE_LEASTUSED },
}

local function SummonStyleGenerator(owner, rootDescription)
    local IsSelected = function (v) return v == LM.Options:GetOption('randomWeightStyle') end
    local SetSelected = function (v) LM.Options:SetOption('randomWeightStyle', v) end
    for _, info in ipairs(styleOptions) do
        if not info.disabled then
            rootDescription:CreateRadio(info[2], IsSelected, SetSelected, info[1])
        end
    end
end

--[[------------------------------------------------------------------------]]--

LiteMountGeneralPanelMixin = {}

function LiteMountGeneralPanelMixin:OnShow()
    self.RandomPersistDropDown:SetupMenu(RandomPersistGenerator)
    self.SummonStyleDropDown:SetupMenu(SummonStyleGenerator)
end

function LiteMountGeneralPanelMixin:OnLoad()

    -- Announce options L-R anchoring. Can't do this in the XML because we
    -- want to anchor to the .Text region.
    self.AnnounceUI:SetPoint("LEFT", self.AnnounceChat.Text, "RIGHT", 28, 0)
    self.AnnounceColors:SetPoint("LEFT", self.AnnounceUI.Text, "RIGHT", 28, 0)

    -- CopyTargetsMount --

    self.CopyTargetsMount.Text:SetText(L.LM_COPY_TARGETS_MOUNT)
    self.CopyTargetsMount.SetOption =
        function (self, setting)
            if not setting or setting == "0" then
                LM.Options:SetOption('copyTargetsMount', false)
            else
                LM.Options:SetOption('copyTargetsMount', true)
            end
        end
    self.CopyTargetsMount.GetOption =
        function (self) return LM.Options:GetOption('copyTargetsMount') end
    self.CopyTargetsMount.GetOptionDefault =
        function (self) return true end
    LiteMountOptionsPanel_RegisterControl(self.CopyTargetsMount)

    -- DefaultPriority --

    self.DefaultPriority.Text:SetText(L.LM_ADD_MOUNTS_AT_PRIORITY_0)
--[[
    self.DefaultPriority.Text:SetText(
        string.format(L.LM_SET_DEFAULT_MOUNT_PRIORITY_TO,
                        LM.Options.DISABLED_PRIORITY,
                        L.LM_PRIORITY_DESC0,
                        LM.Options.DEFAULT_PRIORITY,
                        L.LM_PRIORITY_DESC1
                        )
        )
]]
    self.DefaultPriority.SetOption =
        function (self, setting)
            if not setting or setting == "0" then
                LM.Options:SetOption('defaultPriority', 1)
            else
                LM.Options:SetOption('defaultPriority', 0)
            end
        end
    self.DefaultPriority.GetOptionDefault =
        function (self) return LM.Options:GetOptionDefault('defaultPriority') end
    self.DefaultPriority.GetOption =
        function (self) return LM.Options:GetOption('defaultPriority') end
    self.DefaultPriority.SetControl =
        function (self, v) self:SetChecked(v == 0) end
    LiteMountOptionsPanel_RegisterControl(self.DefaultPriority)

    -- AnnounceChat --
    self.AnnounceChat.Text:SetText(CHAT)
    self.AnnounceChat.SetOption =
        function (self, setting)
            if not setting or setting == "0" then
                LM.Options:SetOption('announceViaChat', false)
            else
                LM.Options:SetOption('announceViaChat', true)
            end
        end
    self.AnnounceChat.GetOption =
        function (self) return LM.Options:GetOption('announceViaChat') end
    self.AnnounceChat.GetOptionDefault =
        function (self) return LM.Options:GetOptionDefault('announceViaChat') end
    LiteMountOptionsPanel_RegisterControl(self.AnnounceChat)

    -- AnnounceUI --
    self.AnnounceUI.Text:SetText(L.LM_ON_SCREEN_DISPLAY)
    self.AnnounceUI.SetOption =
        function (self, setting)
            if not setting or setting == "0" then
                LM.Options:SetOption('announceViaUI', false)
            else
                LM.Options:SetOption('announceViaUI', true)
            end
        end
    self.AnnounceUI.GetOption =
        function (self) return LM.Options:GetOption('announceViaUI') end
    self.AnnounceUI.GetOptionDefault =
        function (self) return LM.Options:GetOptionDefault('announceViaUI') end
    LiteMountOptionsPanel_RegisterControl(self.AnnounceUI)

    -- AnnounceColors --
    self.AnnounceColors.Text:SetText(L.LM_COLOR_BY_PRIORITY)
    self.AnnounceColors.SetOption =
        function (self, setting)
            if not setting or setting == "0" then
                LM.Options:SetOption('announceColors', false)
            else
                LM.Options:SetOption('announceColors', true)
            end
        end
    self.AnnounceColors.GetOption =
        function (self) return LM.Options:GetOption('announceColors') end
    self.AnnounceColors.GetOptionDefault =
        function (self) return LM.Options:GetOptionDefault('announceColors') end
    LiteMountOptionsPanel_RegisterControl(self.AnnounceColors)

    -- InstantOnlyMoving --

    self.InstantOnlyMoving.Text:SetText(L.LM_INSTANT_ONLY_MOVING)
    self.InstantOnlyMoving.SetOption =
        function (self, setting)
            if not setting or setting == "0" then
                LM.Options:SetOption('instantOnlyMoving', false)
            else
                LM.Options:SetOption('instantOnlyMoving', true)
            end
        end
    self.InstantOnlyMoving.GetOptionDefault =
        function (self) return LM.Options:GetOptionDefault('instantOnlyMoving') end
    self.InstantOnlyMoving.GetOption =
        function (self) return LM.Options:GetOption('instantOnlyMoving') end
    LiteMountOptionsPanel_RegisterControl(self.InstantOnlyMoving)

    -- RestoreForms --

    self.RestoreForms.Text:SetText(L.LM_RESTORE_FORMS)
    self.RestoreForms.SetOption =
        function (self, setting)
            if not setting or setting == "0" then
                LM.Options:SetOption('restoreForms', false)
            else
                LM.Options:SetOption('restoreForms', true)
            end
        end
    self.RestoreForms.GetOptionDefault =
        function (self) return LM.Options:GetOptionDefault('restoreForms') end
    self.RestoreForms.GetOption =
        function (self) return LM.Options:GetOption('restoreForms') end
    LiteMountOptionsPanel_RegisterControl(self.RestoreForms)

    -- AnnounceFlightStyle (only on retail) --

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        self.AnnounceFlightStyle.Text:SetText(L.LM_ANNOUNCE_FLIGHT_STYLE)
        self.AnnounceFlightStyle.SetOption =
            function (self, setting)
                if not setting or setting == "0" then
                    LM.Options:SetOption('announceFlightStyle', false)
                else
                    LM.Options:SetOption('announceFlightStyle', true)
                end
            end
        self.AnnounceFlightStyle.GetOptionDefault =
            function (self) return LM.Options:GetOptionDefault('announceFlightStyle') end
        self.AnnounceFlightStyle.GetOption =
            function (self) return LM.Options:GetOption('announceFlightStyle') end
        LiteMountOptionsPanel_RegisterControl(self.AnnounceFlightStyle)
    else
        self.AnnounceFlightStyle:Hide()
    end

    -- Debugging --

    self.Debugging.Text:SetText(L.LM_ENABLE_DEBUGGING)
    self.Debugging.SetOption =
        function (self, setting)
            if not setting or setting == "0" then
                LM.Options:SetOption('debugEnabled', false)
            else
                LM.Options:SetOption('debugEnabled', true)
            end
        end
    self.Debugging.GetOptionDefault =
        function (self) return false end
    self.Debugging.GetOption =
        function (self) return LM.Options:GetOption('debugEnabled') end
    LiteMountOptionsPanel_RegisterControl(self.Debugging)

    LiteMountOptionsPanel_OnLoad(self)
end
