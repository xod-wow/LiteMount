
--[[----------------------------------------------------------------------------

  LiteMount/UIOptionsFrame.lua

  Options frame to plug in to the Blizzard interface menu.

----------------------------------------------------------------------------]]--


function LiteMountOptions_CreateButtons(self)
end

function LiteMountOptions_PlaceButtons(self)
end

function LiteMountOptions_OnLoad(self)
    self.options = LM_Options

    self.name = "LiteMount " .. GetAddOnMetadata("LiteMount", "Version")
    self.okay = function (self) end
    self.cancel = function (self) end

    self.title:SetText(self.name)

    InterfaceOptions_AddCategory(self)
end
