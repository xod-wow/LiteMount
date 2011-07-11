
--[[----------------------------------------------------------------------------

  LiteMount/UIOptionsFrame.lua

  Options frame to plug in to the Blizzard interface menu.

----------------------------------------------------------------------------]]--

function LiteMountOptions_UpdateMountList(self)
    local scrollFrame = self.scrollFrame
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons
    local mounts = self.mountList

    for i = 1, #buttons do
        local button = buttons[i]
        local index = offset + i
        if index <= #mounts then
            button.icon:SetTexture()
            button.name:SetText()
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

    self.scrollFrame.update = LiteMountOptions_UpdateMountList
    self.scrollFrame.stepSize = 45
    self.scrollFrame.scrollBar.doNotHide = true

    HybridScrollFrame_CreateButtons(self.scrollFrame, "LiteMountOptionsButtonTemplate", 0, 0)

    self.options = LM_Options

    self.name = "LiteMount " .. GetAddOnMetadata("LiteMount", "Version")
    self.okay = function (self) end
    self.cancel = function (self) end

    self.title:SetText(self.name)

    LiteMountOptions_CreateButtons(self.scrollFrame)

    InterfaceOptions_AddCategory(self)
end

function LiteMountOptions_OnShow(self)
    self.mountList = LiteMount.ml:GetMounts()
    LiteMountOptions_UpdateMountList(self)
end

