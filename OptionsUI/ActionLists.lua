--[[----------------------------------------------------------------------------

  LiteMount/OptionsUI/ActionLists.lua

  Options frame for the action list.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

function LM_OptionsUIActionLists_OnLoad(self)

    self.name = "Action Lists"

    PanelTemplates_SetNumTabs(self, 4)
    LM_OptionsUIActionLists_SetTab(self, 1)
    PanelTemplates_UpdateTabs(self)

    LM_OptionsUIPanel_OnLoad(self)
end

function LM_OptionsUIActionLists_SetTab(self, id)
    self.selectedTab = id

    if self.selectedTab == 1 then
        self.EditBox:SetTextColor(1, 0.7, 0.4)
        self.EditBox:Disable()
        self.Revert:Disable()
        self.Delete:Disable()
    else
        self.EditBox:SetTextColor(1, 1, 1)
        self.EditBox:Enable()
        self.Revert:Enable()
        self.Delete:Enable()
    end

    local spacerL = self.EditBoxContainer.TabTopL
    local spacerR = self.EditBoxContainer.TabTopR
    local tab = _G[self:GetName() .. "Tab" .. self.selectedTab]

    spacerL:SetPoint("RIGHT", tab, "LEFT", 9, 0)
    spacerR:SetPoint("LEFT", tab, "RIGHT", -9, 0)

    PanelTemplates_UpdateTabs(self)
end

function LM_OptionsUIActionLists_Tab_OnClick(self)
    LM_OptionsUIActionLists_SetTab(self:GetParent(), self:GetID())
    LM_OptionsUIPanel_Refresh(self:GetParent())
end

function LM_OptionsUIActionListsEditBox_OnLoad(self)

    self.GetOption = function (self)
            local n = LM_OptionsUIActionLists.selectedTab or 1
            local b = _G["LiteMountActionButton"..n]
            return b:GetActionList()
        end
    self.SetOption = function (self, v)
        end
    self.GetOptionDefault = function (self)
            return ""
        end
    LM_OptionsUIControl_OnLoad(self, LM_OptionsUIActionLists)
end
