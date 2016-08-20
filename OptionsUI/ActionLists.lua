--[[----------------------------------------------------------------------------

  LiteMount/OptionsUI/ActionLists.lua

  Options frame for the action list.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--


local displayedElements = {
    "x",
    "y",
    "z",
}

function LM_OptionsUIActionListsSelection_Update(self)
    local list = self.scrollFrame
    local offset = FauxScrollFrame_GetOffset(list)
    local buttons = self.buttons

    local numButtons = #buttons
    local numElements = #displayedElements
    local buttonHeight = buttons[1]:GetHeight()

    if numElements > numButtons then
        OptionsList_DisplayScrollBar(self)
    else
        OptionsList_HideScrollBar(self)
    end

    FauxScrollFrame_Update(list, numElements, numButtons, buttonHeight)

    if self.selection then
        OptionsList_ClearSelection(self, buttons)
    end

    for i = 1, numButtons do
        local e = displayedElements[i + offset]
        if not e then
            buttons[i]:Hide()
        else
            buttons[i].Text:SetText(e)
            buttons[i]:Show()
        end
    end

    LM_Print(self:GetName())
    LM_Print(tostring(offset))
    LM_Print(numButtons)
    LM_Print(tostring(buttons))
end

function LM_OptionsUIActionLists_OnLoad(self)

    self.name = "Action Lists"

    LM_OptionsUIPanel_OnLoad(self)
end

function LM_OptionsUIActionListsEditBox_OnLoad(self)

    self.GetOption = function (self)
            local b = LiteMountActionButton1
            return b:GetActionList()
        end
    self.SetOption = function (self, v)
        end
    self.GetOptionDefault = function (self)
            return ""
        end
    LM_OptionsUIControl_OnLoad(self, LM_OptionsUIActionLists)
end
