
--[[----------------------------------------------------------------------------

  LiteMount/UIOptionsFrame.lua

  Options frame to plug in to the Blizzard interface menu.

----------------------------------------------------------------------------]]--

local PANEL_MARGIN = 16
local MIN_GAP = 5

function LiteMountOptions_CreateButton(panel, i)
    local b = CreateFrame("Button", panel:GetName().."Button"..i, panel, "LiteMountOptionsButtonTemplate")
    -- Dummy values for testing
    local n,_,i = GetSpellInfo(48025)
    b.name:SetText(n)
    b.icon:SetTexture(i)
end

function LiteMountOptions_CreateButtons(self)
    if not self.buttons then self.buttons = { } end

    if not self.buttons[1] then
        self.buttons[1] = LiteMountOptions_CreateButton(self, 1)
    end

    local panelwidth, panelheight = self:GetSize()
    local totalwidth = panelwidth - 2*PANEL_MARGIN
    local totalheight = panelheight - 2*PANEL_MARGIN
    local buttonwidth, buttonheight = self.buttons[1]:GetSize()

    local rows = floor((totalwidth + MIN_GAP) / (buttonwidth + MIN_GAP))
    local cols = floor((totalheight + MIN_GAP) / (buttonheight + MIN_GAP))

    local hgap = floor((totalwidth - rows*buttonwidth)/(rows-1))
    local vgap = floor((totalheight - cols*buttonheight)/(cols-1))

    for i = 1, cols do
        for j = 1, rows do
            local b = i * cols + j
            if not self.buttons[b] then
                self.buttons[b] = LiteMountOptions_CreateButton(self, b)
            end
            local y = -(PANEL_MARGIN + (i-1)*(buttonheight+vgap))
            local x = PANEL_MARGIN + (j-1)*(buttonwidth+hgap)
            self.buttons[i]:SetPoint("TOPLEFT", nil, "TOPLEFT", x, y)
        end
    end
    self.numButtons = #self.buttons
end

function LiteMountOptions_OnLoad(self)
    self.options = LM_Options

    self.name = "LiteMount " .. GetAddOnMetadata("LiteMount", "Version")
    self.okay = function (self) end
    self.cancel = function (self) end

    self.title:SetText(self.name)

    LiteMountOptions_CreateButtons(self)

    InterfaceOptions_AddCategory(self)
end
