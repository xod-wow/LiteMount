--[[----------------------------------------------------------------------------

  LiteMount/UI/General.lua

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

local L = LM.Localize

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
        local keepSeconds = LM.Options:GetRandomPersistence()
        for _,opt in ipairs(persistOptions) do
            info.arg1 = opt[1]
            info.text = opt[2]
            info.checked = ( opt[1] == keepSeconds )
            info.func =
                function (_, seconds)
                    dropdown.isDirty = true
                    LM.Options:SetRandomPersistence(seconds)
                end
            LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end
end

--[[------------------------------------------------------------------------]]--

LiteMountGeneralPanelMixin = {}

function LiteMountGeneralPanelMixin:OnLoad()

    -- CopyTargetsMount --

    self.CopyTargetsMount.Text:SetWidth(500)
    self.CopyTargetsMount.Text:SetText(L.LM_COPY_TARGETS_MOUNT)
    self.CopyTargetsMount.SetOption =
        function (self, setting)
            if not setting or setting == "0" then
                LM.Options:SetCopyTargetsMount(false)
            else
                LM.Options:SetCopyTargetsMount(true)
            end
        end
    self.CopyTargetsMount.GetOption =
        function (self) return LM.Options:GetCopyTargetsMount() end
    self.CopyTargetsMount.GetOptionDefault =
        function (self) return true end
    LiteMountOptionsPanel_RegisterControl(self.CopyTargetsMount)

    -- DefaultPriority --

    self.DefaultPriority.Text:SetWidth(500)
    self.DefaultPriority.Text:SetText(L.LM_DISABLE_NEW_MOUNTS)
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
                LM.Options:SetDefaultPriority(1)
            else
                LM.Options:SetDefaultPriority(0)
            end
        end
    self.DefaultPriority.GetOptionDefault =
        function (self) return 1 end
    self.DefaultPriority.GetOption =
        function (self) return LM.Options:GetDefaultPriority() end
    self.DefaultPriority.SetControl =
        function (self, v) self:SetChecked(v == 0) end
    LiteMountOptionsPanel_RegisterControl(self.DefaultPriority)

    -- InstantOnlyMoving --

    self.InstantOnlyMoving.Text:SetWidth(500)
    self.InstantOnlyMoving.Text:SetText(L.LM_INSTANT_ONLY_MOVING)
    self.InstantOnlyMoving.SetOption =
        function (self, setting)
            if not setting or setting == "0" then
                LM.Options:SetInstantOnlyMoving(false)
            else
                LM.Options:SetInstantOnlyMoving(true)
            end
        end
    self.InstantOnlyMoving.GetOptionDefault =
        function (self) return false end
    self.InstantOnlyMoving.GetOption =
        function (self) return LM.Options:GetInstantOnlyMoving() end
    LiteMountOptionsPanel_RegisterControl(self.InstantOnlyMoving)

    -- RandomPersistDropDown --

    LibDD:Create_UIDropDownMenu(self.RandomPersistDropDown)
    LibDD:UIDropDownMenu_Initialize(self.RandomPersistDropDown, RandomPersistDropDown_Initialize)
    self.RandomPersistDropDown.GetOption =
        function () return LM.Options:GetRandomPersistence() end
    self.RandomPersistDropDown.GetOptionDefault =
        function () return 0 end
    self.RandomPersistDropDown.SetOption =
        function (self, v) LM.Options:SetRandomPersistence(v) end
    self.RandomPersistDropDown.SetControl = RandomPersistDropDown_UpdateText
    LiteMountOptionsPanel_RegisterControl(self.RandomPersistDropDown)

    -- Debugging --

    self.Debugging.Text:SetText(L.LM_ENABLE_DEBUGGING)
    self.Debugging.SetOption =
        function (self, setting)
            if not setting or setting == "0" then
                LM.Options:SetDebug(false)
            else
                LM.Options:SetDebug(true)
            end
        end
    self.Debugging.GetOptionDefault =
        function (self) return false end
    self.Debugging.GetOption =
        function (self) return LM.Options:GetDebug() end
    LiteMountOptionsPanel_RegisterControl(self.Debugging)

    LiteMountOptionsPanel_OnLoad(self)
end
