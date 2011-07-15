
--[[----------------------------------------------------------------------------

  LiteMount/UIOptionsFrame.lua

  Options frame to plug in to the Blizzard interface menu.

----------------------------------------------------------------------------]]--

local function CreateMoreButtons(self)
    LM_Print("CREATEBUTTONS " .. string.format("%dx%d", self:GetSize()))
    HybridScrollFrame_CreateButtons(self, "LiteMountOptionsButtonTemplate",
                                    0, -1, "TOPLEFT", "TOPLEFT",
                                    0, -1, "TOP", "BOTTOM")

    for _,b in ipairs(self.buttons) do
        b:SetWidth(b:GetParent():GetWidth())
    end
end

function LiteMountOptions_UpdateMountList()
    local self = LiteMountOptions

    local scrollFrame = self.scrollFrame
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons

    if not buttons then return end

    local mounts
    if LiteMount then
        mounts = LiteMount:GetAllMounts()
    else
        mounts = { }
    end

    for i = 1, #buttons do
        local button = buttons[i]
        local index = offset + i
        if index <= #mounts then
            local m = mounts[index]
            button.icon:SetTexture(m:Icon())
            button.name:SetText(m:Name())
            button:Show()
        else
            button:Hide()
        end
    end

    local totalHeight = scrollFrame.buttonHeight * #mounts
    local shownHeight = scrollFrame.buttonHeight * #buttons

    HybridScrollFrame_Update(scrollFrame, totalHeight, shownHeight)
end

function LiteMountOptions_OnLoad(self)

    local name = self:GetName()

    -- Because we're the wrong size at the moment we'll only have 1 button
    CreateMoreButtons(self.scrollFrame)

    self.scrollFrame.stepSize = 45
    self.scrollFrame.scrollBar.doNotHide = true
    self.scrollFrame.update = LiteMountOptions_UpdateMountList

    self.options = LM_Options

    self.name = "LiteMount " .. GetAddOnMetadata("LiteMount", "Version")
    self.okay = function (self) end
    self.cancel = function (self) end

    self.title:SetText(self.name)

    InterfaceOptions_AddCategory(self)
end


function LiteMountOptions_OnShow(self)
    CreateMoreButtons(self.scrollFrame)
    LiteMountOptions_UpdateMountList()
end

