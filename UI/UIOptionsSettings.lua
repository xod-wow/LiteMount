--[[----------------------------------------------------------------------------

  LiteMount/UIOptionsSettings.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2015 Mike Battersby

----------------------------------------------------------------------------]]--

function LiteMountOptionsSettings_OnLoad(self)
    LiteMount_Frame_AutoLocalize(self)

    self.parent = LiteMountOptions.name
    self.name = SETTINGS
    self.title:SetText("LiteMount : " .. self.name)
    self.default = function () return true end
    InterfaceOptions_AddCategory(self)
end

function LiteMountOptionsSettings_OnShow(self)
    LiteMountOptions.CurrentOptionsPanel = self
    LiteMountOptionsPanel_Refresh(self)
end
