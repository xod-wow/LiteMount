--[[----------------------------------------------------------------------------

  LiteMount/UI/KeyBindings.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

LiteMountKeyBindingsPanelMixin = {}

-- GetBindingIndex doesn't work in OnLoad, have to let the Settings handle it
-- with a callback.
function LiteMountKeyBindingsPanelMixin:Register()
    for i = 1, 4 do
        local bindingName = string.format("CLICK LM_B%d:LeftButton", i)
        local bindingIndex = C_KeyBindings.GetBindingIndex(bindingName)
        local initializer = CreateKeybindingEntryInitializer(bindingIndex, true)
        self.layout:AddInitializer(initializer)
    end
end

function LiteMountKeyBindingsPanelMixin:OnLoad()
    local topCategory = LiteMountOptions.category
    self.category, self.layout = Settings.RegisterVerticalLayoutSubcategory(topCategory, self.name)
    SettingsRegistrar:AddRegistrant(function () self:Register() end)
end
