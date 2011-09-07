
--[[----------------------------------------------------------------------------

  LiteMount/UIOptionsFrame.lua

  Options frame to plug in to the Blizzard interface menu.

----------------------------------------------------------------------------]]--

function LiteMountOptionsBit_OnClick(self)
    local spellid = self:GetParent().spellid

    if self:GetChecked() then
        LM_Options:SetSpellFlagBit(spellid, self.defflags, self.flagbit)
    else
        LM_Options:ClearSpellFlagBit(spellid, self.defflags, self.flagbit)
    end
    LiteMountOptions_UpdateMountList()
end

-- Because we get attached inside the blizzard options container, we
-- are size 0x0 on create and even after OnShow, we have to trap
-- OnSizeChanged on the scrollframe to make the buttons correctly.
local function CreateMoreButtons(self)
    HybridScrollFrame_CreateButtons(self, "LiteMountOptionsButtonTemplate",
                                    0, -1, "TOPLEFT", "TOPLEFT",
                                    0, -1, "TOP", "BOTTOM")

    for _,b in ipairs(self.buttons) do
        b:SetWidth(b:GetParent():GetWidth())
        b.bit1.flagbit = LM_FLAG_BIT_WALK
        b.bit2.flagbit = LM_FLAG_BIT_FLY
        b.bit3.flagbit = LM_FLAG_BIT_SWIM
        b.bit4.flagbit = LM_FLAG_BIT_AQ
        b.bit5.flagbit = LM_FLAG_BIT_VASHJIR
        b.enabled.dependentControls = { b.bit1, b.bit2, b.bit3, b.bit4, b.bit5 }
    end
end

local function EnableDisableSpell(spellid, onoff)
    if onoff == "0" then
        LM_Options:AddExcludedSpell(spellid)
    else
        LM_Options:RemoveExcludedSpell(spellid)
    end
end

local function BitButtonUpdate(checkButton, mount)
    local flags = mount:Flags()
    local defflags = mount:DefaultFlags()

    local checked = bit.band(flags, checkButton.flagbit) == checkButton.flagbit
    checkButton:SetChecked(checked)

    checkButton.defflags = defflags

    -- If we changed this from the default then color the background
    if bit.band(flags, checkButton.flagbit) == bit.band(defflags, checkButton.flagbit) then
        checkButton:SetBackdropColor(1.0, 0.5, 0.0)
    else
        checkButton:SetBackdropColor(1.0, 1.0, 1.0)
    end
end

local function UpdateMountButton(button, mount)
    button.icon:SetTexture(mount:Icon())
    button.name:SetText(mount:Name())
    button.spellid = mount:SpellId()

    BitButtonUpdate(button.bit1, mount)
    BitButtonUpdate(button.bit2, mount)
    BitButtonUpdate(button.bit3, mount)
    BitButtonUpdate(button.bit4, mount)
    BitButtonUpdate(button.bit5, mount)

    if LM_Options:IsExcludedSpell(button.spellid) then
        button.enabled:SetChecked(false)
    else
        button.enabled:SetChecked(true)
    end
    button.enabled.setFunc = function(setting)
                            EnableDisableSpell(button.spellid, setting)
                            button.enabled:GetScript("OnEnter")(button.enabled)
                        end

    if GameTooltip:GetOwner() == button.enabled then
        button.enabled:GetScript("OnEnter")(button.enabled)
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
            UpdateMountButton(button, mounts[index])
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

    self.stepSize = self.buttonHeight
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
    LiteMountOptions_UpdateMountList()
end

