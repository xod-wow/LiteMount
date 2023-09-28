--[[----------------------------------------------------------------------------

  LiteMount/UI/General.lua

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local LibDD = LibStub("LibUIDropDownMenu-4.0")

local persistOptions = {
    { 0,    L.LM_EVERY_TIME },
    { 30,   format(L.LM_EVERY_D_SECONDS, 30) },
    { 120,  format(L.LM_EVERY_D_MINUTES, 2) },
    { 300,  format(L.LM_EVERY_D_MINUTES, 5) },
    { 1800, format(L.LM_EVERY_D_MINUTES, 30) },
}

local function RandomPersistDropDown_UpdateText(dropdown, keepSeconds)
    for _,opt in ipairs(persistOptions) do
        if opt[1] == keepSeconds then
            LibDD:UIDropDownMenu_SetText(dropdown, opt[2])
            return
        end
    end
    LibDD:UIDropDownMenu_SetText(dropdown, '????')
end

local function RandomPersistDropDown_Initialize(dropdown, level)
    local info = LibDD:UIDropDownMenu_CreateInfo()
    if level == 1 then
        local keepSeconds = LM.Options:GetOption('randomKeepSeconds')
        for _,opt in ipairs(persistOptions) do
            info.arg1 = opt[1]
            info.text = opt[2]
            info.checked = ( opt[1] == keepSeconds )
            info.func =
                function (_, seconds)
                    dropdown.isDirty = true
                    LM.Options:SetOption('randomKeepSeconds', seconds)
                end
            LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end
end

--[[------------------------------------------------------------------------]]--

LiteMountGeneralPanelMixin = {}

function LiteMountGeneralPanelMixin:OnShow()
    LibDD:UIDropDownMenu_Initialize(self.RandomPersistDropDown, RandomPersistDropDown_Initialize)
end

function LiteMountGeneralPanelMixin:OnLoad()

    LibDD:Create_UIDropDownMenu(self.RandomPersistDropDown)

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

    -- UseRarityWeight --

    self.UseRarityWeight.Text:SetText(L.LM_USE_RARITY_WEIGHTS)
    self.UseRarityWeight.SetOption =
        function (self, setting)
            if not setting or setting == "0" then
                LM.Options:SetOption('randomWeightStyle', 'Priority')
            else
                LM.Options:SetOption('randomWeightStyle', 'Rarity')
            end
        end
    if not IsAddOnLoaded('MountsRarity') then
        self.UseRarityWeight.Text:SetScript('OnEnter',
                function (self)
                    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                    GameTooltip:AddLine(L.LM_RARITY_DATA_INFO, 1, 1, 1, true)
                    GameTooltip:Show()
                end)
        self.UseRarityWeight.Text:SetScript('OnLeave', GameTooltip_Hide)
        self.UseRarityWeight.Text:EnableMouse(true)
    end
    self.UseRarityWeight.GetOptionDefault =
        function (self) return LM.Options:GetOptionDefault('randomWeightStyle') == 'Rarity' end
    self.UseRarityWeight.GetOption =
        function (self) return LM.Options:GetOption('randomWeightStyle') == 'Rarity' end
    LiteMountOptionsPanel_RegisterControl(self.UseRarityWeight)

    -- RandomPersistDropDown --

    self.RandomPersistDropDown.GetOption =
        function () return LM.Options:GetOption('randomKeepSeconds') end
    self.RandomPersistDropDown.GetOptionDefault =
        function () return LM.Options:GetOptionDefault('randomKeepSeconds') end
    self.RandomPersistDropDown.SetOption =
        function (self, v) LM.Options:SetOption('randomKeepSeconds', v) end
    self.RandomPersistDropDown.SetControl = RandomPersistDropDown_UpdateText
    LiteMountOptionsPanel_RegisterControl(self.RandomPersistDropDown)

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
