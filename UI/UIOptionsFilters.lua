--[[----------------------------------------------------------------------------

  LiteMount/UIOptionsFilters.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

function LiteMountOptionsFilters_OnLoad(self)
    self.name = FILTERS
    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountOptionsFilters_OnTextChanged(self)
end

