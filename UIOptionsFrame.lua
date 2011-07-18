
--[[----------------------------------------------------------------------------

  LiteMount/UIOptionsFrame.lua

  Options frame to plug in to the Blizzard interface menu.

----------------------------------------------------------------------------]]--


-- Because we get attached inside the blizzard options container, we
-- are size 0x0 on create and even after OnShow, we have to trap
-- OnSizeChanged on the scrollframe to make the buttons correctly.
local function CreateMoreButtons(self)
    HybridScrollFrame_CreateButtons(self, "LiteMountOptionsButtonTemplate",
                                    0, -1, "TOPLEFT", "TOPLEFT",
                                    0, -1, "TOP", "BOTTOM")

    for _,b in ipairs(self.buttons) do
        b:SetWidth(b:GetParent():GetWidth())
    end
end

local function EnableDisableSpell(spellid, onoff)
    if onoff then
        LiteMount:AddExcludedSpell(spellid)
    else
        LiteMount:RemoveExcludedSpell(spellid)
    end
end

function LiteMountOptions_UpdateMountList()
    local self = LiteMountOptions

    local scrollFrame = self.scrollFrame
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons

    if not buttons then return end

    mounts = LiteMount:GetAllMounts()

    for i = 1, #buttons do
        local button = buttons[i]
        local index = offset + i
        if index <= #mounts then
            local m = mounts[index]
            button.icon:SetTexture(m:Icon())
            button.name:SetText(m:Name())
            button.spellid = m:SpellId()
            if LiteMount:IsExcludedSpell(button.spellid) then
                button.enabled:SetChecked(false)
            else
                button.enabled:SetChecked(true)
            end
            button.setFunc = function(setting)
                                    EnableDisableSpell(self.spellid, setting)
                                end
            button:Show()
        else
            button:Hide()
        end
    end

    local totalHeight = scrollFrame.buttonHeight * #mounts
    local shownHeight = scrollFrame.buttonHeight * #buttons

    HybridScrollFrame_Update(scrollFrame, totalHeight, shownHeight)
end

function LiteMountOptionsScrollFrame_OnSizeChanged(self, w, h)
    CreateMoreButtons(self)
    LiteMountOptions_UpdateMountList()

    self.stepSize = 45
    -- self.scrollBar.doNotHide = true
    self.update = LiteMountOptions_UpdateMountList

end

function LiteMountOptions_OnLoad(self)

    local name = self:GetName()

    -- Because we're the wrong size at the moment we'll only have 1 button
    CreateMoreButtons(self.scrollFrame)

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

