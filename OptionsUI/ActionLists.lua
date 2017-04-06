--[[----------------------------------------------------------------------------

  LiteMount/OptionsUI/ActionLists.lua

  Options frame for the action list.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--


-- Always the same. You start out trying to re-use the Blizzard scroll frame
-- functions but you just end up in a mess that's hard to undertand and do
-- it all yourself. I'm sure if I made LiteScrollFrame I'd understand why
-- it's so hard.

local function CreateButtons(self)
    HybridScrollFrame_CreateButtons(
        self, "LM_OptionsUISelectionButtonTemplate",
        0, -1, "TOPLEFT", "TOPLEFT",
        0, -1, "TOP", "BOTTOM")
end

local function SetButtonWidths(self, w)
    for _, b in ipairs(self.buttons) do
        b:SetWidth(w)
    end
end

local function SelectButton(button, isSelected)
    if isSelected then
        button:GetHighlightTexture():SetVertexColor(1, 1, 0)
        button:LockHighlight()
    else
        button:GetHighlightTexture():SetVertexColor(.196, .388, .8)
        button:UnlockHighlight()
    end
end

function LM_OptionsUIActionListSelection_OnLoad(self)
    local name = self:GetName()

    CreateButtons(self)

    self:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    self:SetBackdropColor(0, 0, 0, 0.5)

    self.scrollBar:ClearAllPoints()
    self.scrollBar:SetPoint("TOPRIGHT", self, "TOPRIGHT", -3, -17)
    self.scrollBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -3, 17)

    local track = _G[self.scrollBar:GetName().."Track"]
    track:Hide()

    self.stepSize = self.buttonHeight
    self.update = LM_OptionsUIActionListsSelection_Update
    self.selected = "Default"
end

function LM_OptionsUIActionListSelection_OnShow(self)
    CreateButtons(self)
    self:update()
end

local displayedElements = {}
function LM_OptionsUIActionListsSelection_Update(self)
    local buttons = self.buttons

    wipe(displayedElements)
    -- XXX FIXME XXX
    for name, _ in pairs({}) do
        tinsert(displayedElements, name)
    end
    sort(displayedElements)
    tinsert(displayedElements, 1, "Default")

    local numButtons = #buttons
    local numElements = #displayedElements
    local buttonHeight = buttons[1]:GetHeight()

    if numElements > numButtons then
        self.scrollBar:Show()
        SetButtonWidths(self, self:GetWidth() - self.scrollBar:GetWidth())
    else
        self.scrollBar:Hide()
        self.scrollBar:Show()
        SetButtonWidths(self, self:GetWidth())
    end

    local offset = HybridScrollFrame_GetOffset(self)

    for i = 1, numButtons do
        local n = i + offset
        local e = displayedElements[n]
        if not e then
            buttons[i]:Hide()
        else
            buttons[i].Text:SetText(e)
            buttons[i]:Show()
            buttons[i]:SetID(n)
            SelectButton(buttons[i], e == self.selected)
        end
    end

    local totalHeight = self.buttonHeight * numElements
    local shownHeight = self.buttonHeight * numButtons

    HybridScrollFrame_Update(self, totalHeight, shownHeight)

end

function LM_OptionsUIActionLists_OnLoad(self)

    self.name = "Action Lists"

    LM_OptionsUIPanel_OnLoad(self)
end

function LM_OptionsUIActionListsEditBox_OnLoad(self)

    self.GetOption = function (self)
            return ""
            -- return LM_Options:ActionList(self.actionName) or ""
        end
    self.SetOption = function (self, v)
        end
    self.GetOptionDefault = function (self)
            return ""
        end
    LM_OptionsUIControl_OnLoad(self, LM_OptionsUIActionLists)
end

function LM_OptionsUISelectionButton_OnClick(button)
    LM_OptionsUIActionListsSelection.selected = button.actionName
    LM_OptionsUIActionListsSelection_Update(LM_OptionsUIActionListsSelection)
end
