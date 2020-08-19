--[[----------------------------------------------------------------------------

  LiteMount/UI/General.lua

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

local persistOptions = {
    { 0,    L.LM_EVERY_TIME },
    { 30,   format(L.LM_EVERY_D_SECONDS, 30) },
    { 120,  format(L.LM_EVERY_D_MINUTES, 2) },
    { 300,  format(L.LM_EVERY_D_MINUTES, 5) },
    { 1800, format(L.LM_EVERY_D_MINUTES, 30) },
}

local function RandomPersistDropDown_UpdateText(dropdown)
    local keepSeconds = LM_Options:GetRandomPersistence()
    for _,opt in ipairs(persistOptions) do
        if opt[1] == keepSeconds then
            UIDropDownMenu_SetText(dropdown, opt[2])
            return
        end
    end
    UIDropDownMenu_SetText(dropdown, '????')
end

local function RandomPersistDropDown_Initialize(dropdown, level)
    local info = UIDropDownMenu_CreateInfo()
    if level == 1 then
        local keepSeconds = LM_Options:GetRandomPersistence()
        for _,opt in ipairs(persistOptions) do
            info.arg1 = opt[1]
            info.text = opt[2]
            info.checked = ( opt[1] == keepSeconds )
            info.func =
                function (_, seconds)
                    LM_Options:SetRandomPersistence(seconds)
                    RandomPersistDropDown_UpdateText(dropdown)
                end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

function LiteMountOptionsGeneral_OnLoad(self)

    -- CopyTargetsMount --

    self.CopyTargetsMount.Text:SetText(L.LM_COPY_TARGETS_MOUNT)
    self.CopyTargetsMount.SetOption =
        function (self, setting)
            if not setting or setting == "0" then
                LM_Options.db.profile.copyTargetsMount = false
            else
                LM_Options.db.profile.copyTargetsMount = true
            end
        end
    self.CopyTargetsMount.GetOption =
        function (self) return LM_Options.db.profile.copyTargetsMount end
    self.CopyTargetsMount.GetOptionDefault =
        function (self) return true end
    LiteMountOptionsControl_OnLoad(self.CopyTargetsMount)

    -- ExcludeNewMounts --

    self.ExcludeNewMounts.Text:SetText(L.LM_DISABLE_NEW_MOUNTS)
    self.ExcludeNewMounts.SetOption =
        function (self, setting)
            if not setting or setting == "0" then
                LM_Options.db.profile.excludeNewMounts = false
            else
                LM_Options.db.profile.excludeNewMounts = true
            end
        end
    self.ExcludeNewMounts.GetOptionDefault =
        function (self) return false end
    self.ExcludeNewMounts.GetOption =
        function (self) return LM_Options.db.profile.excludeNewMounts end
    LiteMountOptionsControl_OnLoad(self.ExcludeNewMounts)

    -- RandomPersistDropDown --

    UIDropDownMenu_Initialize(self.RandomPersistDropDown, RandomPersistDropDown_Initialize)

    -- Debugging --

    self.Debugging.Text:SetText(L.LM_ENABLE_DEBUGGING)
    self.Debugging.SetOption =
        function (self, setting)
            if not setting or setting == "0" then
                LM_Options:SetDebug(false)
            else
                LM_Options:SetDebug(true)
            end
        end
    self.Debugging.GetOptionDefault =
        function (self) return false end
    self.Debugging.GetOption =
        function (self) return LM_Options:GetDebug() end
    LiteMountOptionsControl_OnLoad(self.Debugging)

    -- Hook in --

    self.refresh =
        function (self, isProfileChange)
            RandomPersistDropDown_UpdateText(self.RandomPersistDropDown)
            LiteMountOptionsPanel_Refresh(self, isProfileChange)
        end

    LiteMountOptionsPanel_OnLoad(self)
end

