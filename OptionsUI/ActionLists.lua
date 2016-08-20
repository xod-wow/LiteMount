--[[----------------------------------------------------------------------------

  LiteMount/OptionsUI/ActionLists.lua

  Options frame for the action list.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

function LM_OptionsUIActionLists_OnLoad(self)

    self.name = "Action Lists"

    PanelTemplates_SetNumTabs(self, 4)
    LM_OptionsUIActionLists_SetTab(self, 1)

    LM_OptionsUIPanel_OnLoad(self)
end

function LM_OptionsUIActionLists_SetTab(self, n)

    if type(n) == "number" then
        self.selectedTab = 1
    else
        self.selectedTab = n:GetID()
    end

    local spacerL = self.EditBoxContainer.TabTopL
    local spacerR = self.EditBoxContainer.TabTopR
    local tab = _G[self:GetName() .. "Tab" .. self.selectedTab]

    spacerL:SetPoint("RIGHT", tab, "LEFT", 9, 0)
    spacerR:SetPoint("LEFT", tab, "RIGHT", -9, 0)

    PanelTemplates_UpdateTabs(self)
end
