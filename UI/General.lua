--[[----------------------------------------------------------------------------

  LiteMount/UI/General.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

--[[------------------------------------------------------------------------]]--

--[[------------------------------------------------------------------------]]--

LiteMountGeneralPanelMixin = {}

-- GetBindingIndex doesn't work in OnLoad, have to let the Settings handle it
-- with a callback.
function LiteMountGeneralPanelMixin:Register()

    -- Section : Key Bindings --
    self.layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(KEY_BINDINGS))

    for i = 1, 4 do
        local bindingName = string.format("CLICK LM_B%d:LeftButton", i)
        local bindingIndex = C_KeyBindings.GetBindingIndex(bindingName)
        local initializer = CreateKeybindingEntryInitializer(bindingIndex, true)
        self.layout:AddInitializer(initializer)
    end

    do
        local bindingName = "LM_FORCE_NEW_RANDOM"
        local bindingIndex = C_KeyBindings.GetBindingIndex(bindingName)
        local initializer = CreateKeybindingEntryInitializer(bindingIndex, true)
        self.layout:AddInitializer(initializer)
    end

    -- Section : Settings --
    self.layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(SETTINGS))

    local checkboxTemplate = "LiteMountCheckboxControlTemplate"
    local dropdownTemplate = "LiteMountDropdownControlTemplate"

    -- Copy Targets Mount --
    do
        local setting = Settings.RegisterProxySetting(
            self.category,
            "LiteMountCopyTargetsMount",
            Settings.VarType.Boolean,
            L.LM_COPY_TARGETS_MOUNT,
            LM.Options:GetOptionDefault("copyTargetsMount"),
            function () return LM.Options:GetOption("copyTargetsMount") end,
            function (v) LM.Options:SetOption("copyTargetsMount", v) end
        )
        local initializer = Settings.CreateControlInitializer(checkboxTemplate, setting)
        self.layout:AddInitializer(initializer)
    end

    -- Default Priority --
    do
        local setting = Settings.RegisterProxySetting(
            self.category,
            "LiteMountDefaultPriority",
            Settings.VarType.Boolean,
            L.LM_ADD_MOUNTS_AT_PRIORITY_0,
            LM.Options:GetOptionDefault("defaultPriority") == 0,
            function () return LM.Options:GetOption("defaultPriority") == 0 end,
            function (v) LM.Options:SetOption("defaultPriority", v and 0 or 1) end
        )
        local initializer = Settings.CreateControlInitializer(checkboxTemplate, setting)
        self.layout:AddInitializer(initializer)
    end

    -- Instant Only Moving --
    do
        local setting = Settings.RegisterProxySetting(
            self.category,
            "LiteMountInstantOnlyMoving",
            Settings.VarType.Boolean,
            L.LM_INSTANT_ONLY_MOVING,
            LM.Options:GetOptionDefault("instantOnlyMoving"),
            function () return LM.Options:GetOption("instantOnlyMoving") end,
            function (v) LM.Options:SetOption("instantOnlyMoving", v) end
        )
        local initializer = Settings.CreateControlInitializer(checkboxTemplate, setting)
        self.layout:AddInitializer(initializer)
    end

    -- Restore Forms --
    do
        local setting = Settings.RegisterProxySetting(
            self.category,
            "LiteMountRestoreForms",
            Settings.VarType.Boolean,
            L.LM_RESTORE_FORMS,
            LM.Options:GetOptionDefault("restoreForms"),
            function () return LM.Options:GetOption("restoreForms") end,
            function (v) LM.Options:SetOption("restoreForms", v) end
        )
        local initializer = Settings.CreateControlInitializer(checkboxTemplate, setting)
        self.layout:AddInitializer(initializer)
    end

    -- Random Style --
    do
        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            container:Add('Priority', string.format("%s (%s)", L.LM_SUMMON_STYLE_PRIORITY, DEFAULT))
            if WOW_PROJECT_ID == 1 then
                container:Add('Rarity', L.LM_SUMMON_STYLE_RARITY)
            end
            container:Add('LeastUsed', L.LM_SUMMON_STYLE_LEASTUSED)
            return container:GetData()
        end

        local function GetValueDefault() return LM.Options:GetOptionDefault("randomWeightStyle") end
        local function GetValue() return LM.Options:GetOption("randomWeightStyle") end
        local function SetValue(v) LM.Options:SetOption("randomWeightStyle", v) end

        local setting = Settings.RegisterProxySetting(
            self.category,
            "LiteMountRandomWeightStyle",
            Settings.VarType.String,
            L.LM_SUMMON_STYLE,
            GetValueDefault(),
            GetValue,
            SetValue
        )
        local initializer = Settings.CreateControlInitializer(dropdownTemplate, setting, GetOptions)
        self.layout:AddInitializer(initializer)
    end

    -- Random Persistence --
    do
        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            container:Add(0,    string.format("%s (%s)", L.LM_EVERY_TIME, DEFAULT))
            container:Add(30,   string.format(L.LM_EVERY_D_SECONDS, 30))
            container:Add(120,  string.format(L.LM_EVERY_D_MINUTES, 2))
            container:Add(300,  string.format(L.LM_EVERY_D_MINUTES, 5))
            container:Add(1800, string.format(L.LM_EVERY_D_MINUTES, 30))
            return container:GetData()
        end

        local function GetValueDefault() return LM.Options:GetOptionDefault("randomKeepSeconds") end
        local function GetValue() return LM.Options:GetOption("randomKeepSeconds") end
        local function SetValue(v) LM.Options:SetOption("randomKeepSeconds", v) end

        local setting = Settings.RegisterProxySetting(
            self.category,
            "LiteMountRandomKeepSeconds",
            Settings.VarType.Number,
            L.LM_RANDOM_PERSISTENCE,
            GetValueDefault(),
            GetValue,
            SetValue
        )
        local initializer = Settings.CreateControlInitializer(dropdownTemplate, setting, GetOptions)
        self.layout:AddInitializer(initializer)
    end

    -- Force New Random Resummon --
    do
        local setting = Settings.RegisterProxySetting(
            self.category,
            "LiteMountForceRandomResummon",
            Settings.VarType.Boolean,
            L.LM_FORCE_NEW_RANDOM_RESUMMON,
            LM.Options:GetOptionDefault("forceRandomResummon"),
            function () return LM.Options:GetOption("forceRandomResummon") end,
            function (v) LM.Options:SetOption("forceRandomResummon", v) end
        )
        local initializer = Settings.CreateControlInitializer(checkboxTemplate, setting)
        self.layout:AddInitializer(initializer)
    end

    -- Mountspecial Timer --
    do
        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            container:Add(0,    NEVER)
            container:Add(20,   string.format(L.LM_EVERY_D_SECONDS, 20))
            container:Add(30,   string.format(L.LM_EVERY_D_SECONDS, 30))
            container:Add(45,   string.format(L.LM_EVERY_D_SECONDS, 45))
            container:Add(120,  string.format(L.LM_EVERY_D_MINUTES, 2))
            return container:GetData()
        end

        local function GetValueDefault() return LM.Options:GetOptionDefault("mountSpecialTimer") end
        local function GetValue() return LM.Options:GetOption("mountSpecialTimer") end
        local function SetValue(v) LM.Options:SetOption("mountSpecialTimer", v) end

        local setting = Settings.RegisterProxySetting(
            self.category,
            "LiteMountMountSpecialTimer",
            Settings.VarType.Number,
            string.format(L.LM_MOUNTSPECIAL_TIMER, EMOTE171_CMD1),
            GetValueDefault(),
            GetValue,
            SetValue
        )
        local initializer = Settings.CreateControlInitializer(dropdownTemplate, setting, GetOptions)
        self.layout:AddInitializer(initializer)
    end

    -- Section : Announce --
    self.layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(CHAT_ANNOUNCE))

    -- Announce Via --
    do
        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            container:Add(0, NONE)
            container:Add(1, CHAT)
            container:Add(2, L.LM_ON_SCREEN_DISPLAY)
            container:Add(3, CHAT .. ' + ' .. L.LM_ON_SCREEN_DISPLAY)
            return container:GetData()
        end

        local function GetValue()
            local chatV = LM.Options:GetOption("announceViaChat") and 1 or 0
            local uiV = LM.Options:GetOption("announceViaUI") and 2 or 0
            return chatV + uiV
        end

        local function GetValueDefault()
            local chatV = LM.Options:GetOptionDefault("announceViaChat") and 1 or 0
            local uiV = LM.Options:GetOptionDefault("announceViaUI") and 2 or 0
            return chatV + uiV
        end

        local function SetValue(v)
            LM.Options:SetOption("announceViaChat", v == 1 or v == 3)
            LM.Options:SetOption("announceViaUI", v == 2 or v == 3)
        end

        local setting = Settings.RegisterProxySetting(
            self.category,
            "LiteMountAnnounceVia",
            Settings.VarType.Number,
            L.LM_ANNOUNCE_MOUNTS,
            GetValueDefault(),
            GetValue,
            SetValue
        )
        Settings.CreateDropdown(self.category, setting, GetOptions)
    end

    -- Color By Priority --
    do
        local setting = Settings.RegisterProxySetting(
            self.category,
            "LiteMountAnnounceColors",
            Settings.VarType.Boolean,
            L.LM_COLOR_BY_PRIORITY,
            LM.Options:GetOptionDefault("announceColors"),
            function () return LM.Options:GetOption("announceColors") end,
            function (v) LM.Options:SetOption("announceColors", v) end
        )
        Settings.CreateCheckbox(self.category, setting)
    end

    -- Announce Flight Style --
    if WOW_PROJECT_ID == 1 then
        local setting = Settings.RegisterProxySetting(
            self.category,
            "LiteMountAnnounceFlightStyle",
            Settings.VarType.Boolean,
            L.LM_ANNOUNCE_FLIGHT_STYLE,
            LM.Options:GetOptionDefault("announceFlightStyle"),
            function () return LM.Options:GetOption("announceFlightStyle") end,
            function (v) LM.Options:SetOption("announceFlightStyle", v) end
        )
        Settings.CreateCheckbox(self.category, setting)
    end
end

function LiteMountGeneralPanelMixin:OnLoad()
    local topCategory = LiteMountOptions.category
    self.category, self.layout = Settings.RegisterVerticalLayoutSubcategory(topCategory, self.name)
    SettingsRegistrar:AddRegistrant(function () self:Register() end)
end
