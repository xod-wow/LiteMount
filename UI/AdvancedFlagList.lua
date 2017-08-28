--[[----------------------------------------------------------------------------

  LiteMount/AdvancedFlagList.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

function LiteMountOptionsFlagList_OnLoad(self)
    self.name = format('%s : %s', ADVANCED, LM_FLAGS)
    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountOptionsFlagList_OnShow(self)
    LiteMountOptionsPanel_OnShow(self)
end
