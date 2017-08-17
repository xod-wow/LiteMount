--[[----------------------------------------------------------------------------

  LiteMount/UIOptionsAdvanced.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

function LiteMountOptionsAdvanced_OnLoad(self)
    self.name = ADVANCED_OPTIONS
    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountOptionsAdvanced_OnTextChanged(self)
end

