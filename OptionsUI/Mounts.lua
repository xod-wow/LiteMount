--[[----------------------------------------------------------------------------

  LiteMount/UIOptionsMounts.lua

  Options frame for the mount list.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

function LiteMountOptionsBit_OnClick(self)
    local mount = self:GetParent().mount

    if self:GetChecked() then
        LM_Options:SetMountFlagBit(mount, self.flagbit)
    else
        LM_Options:ClearMountFlagBit(mount, self.flagbit)
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

    -- Note: the buttons are laid out right to left
    for _,b in ipairs(self.buttons) do
        b:SetWidth(b:GetParent():GetWidth())
        b.bit1.flagbit = LM_FLAG_BIT_RUN
        b.bit2.flagbit = LM_FLAG_BIT_FLY
        b.bit3.flagbit = LM_FLAG_BIT_SWIM
        b.bit4.flagbit = LM_FLAG_BIT_AQ
        b.bit5.flagbit = LM_FLAG_BIT_VASHJIR
        b.bit6.flagbit = LM_FLAG_BIT_CUSTOM2
        b.bit7.flagbit = LM_FLAG_BIT_CUSTOM1
    end
end

local function EnableDisableMount(mount, onoff)
    if onoff == "0" then
        LM_Options:AddExcludedMount(mount)
    else
        LM_Options:RemoveExcludedMount(mount)
    end
end

local function BitButtonUpdate(checkButton, mount)
    local flags = mount:CurrentFlags()
    local defflags = mount:Flags()

    local checked = bit.band(flags, checkButton.flagbit) == checkButton.flagbit
    checkButton:SetChecked(checked)

    checkButton.defflags = defflags

    -- If we changed this from the default then color the background
    if bit.band(flags, checkButton.flagbit) == bit.band(defflags, checkButton.flagbit) then
        checkButton.modified:Hide()
    else
        checkButton.modified:Show()
    end
end

local function GetFilteredMountList()
    LM_PlayerMounts:ScanMounts()
    local mounts = LM_PlayerMounts:GetAllMounts():Sort()

    local filtertext = LiteMountOptionsMounts.filter:GetText()
    if filtertext == SEARCH then
        filtertext = ""
    else
        filtertext = CaseAccentInsensitiveParse(filtertext)
    end

    local n

    filtertext, n = gsub(filtertext, "^+fly *", "", 1)
    if n == 1 then
        for i = #mounts, 1, -1 do
            if not mounts[i]:CurrentFlagsSet(LM_FLAG_BIT_FLY) then
                tremove(mounts, i)
            end
        end
    end

    filtertext, n = gsub(filtertext, "^+run *", "", 1)
    if n == 1 then
        for i = #mounts, 1, -1 do
            if not mounts[i]:CurrentFlagsSet(LM_FLAG_BIT_RUN) then
                tremove(mounts, i)
            end
        end
    end

    filtertext, n = gsub(filtertext, "^+swim *", "", 1)
    if n == 1 then
        for i = #mounts, 1, -1 do
            if not mounts[i]:CurrentFlagsSet(LM_FLAG_BIT_SWIM) then
                tremove(mounts, i)
            end
        end
    end

    filtertext, n = gsub(filtertext, "^+c1 *", "", 1)
    if n == 1 then
        for i = #mounts, 1, -1 do
            if not mounts[i]:CurrentFlagsSet(LM_FLAG_BIT_CUSTOM1) then
                tremove(mounts, i)
            end
        end
    end

    filtertext, n = gsub(filtertext, "^+c2 *", "", 1)
    if n == 1 then
        for i = #mounts, 1, -1 do
            if not mounts[i]:CurrentFlagsSet(LM_FLAG_BIT_CUSTOM2) then
                tremove(mounts, i)
            end
        end
    end

    filtertext, n = gsub(filtertext, "^+enabled *", "", 1)
    if n == 1 then
        for i = #mounts, 1, -1 do
            if LM_Options:IsExcludedMount(mounts[i]) then
                tremove(mounts, i)
            end
        end
    end

    filtertext, n = gsub(filtertext, "^+active *", "", 1)
    if n == 1 then
        for i = #mounts, 1, -1 do
            if not UnitAura("player", mounts[i]:SpellName()) then
                tremove(mounts, i)
            end
        end
    end

    if filtertext ~= "" then
        for i = #mounts, 1, -1 do
            local matchname = CaseAccentInsensitiveParse(mounts[i]:Name())
            if not strfind(matchname, filtertext, 1, true) then
                tremove(mounts, i)
            end
        end
    end

    return mounts
end

local function UpdateAllSelected(mounts)

    if not mounts then
        mounts = GetFilteredMountList()
    end

    local allEnabled = 1
    local allDisabled = 1

    for _,m in ipairs(mounts) do
        if LM_Options:IsExcludedMount(m) then
            allEnabled = 0
        else
            allDisabled = 0
        end
    end

    local checkedTexture = LiteMountOptionsMountsAllSelect:GetCheckedTexture()
    if allDisabled == 1 then
        LiteMountOptionsMountsAllSelect:SetChecked(false)
    else
        LiteMountOptionsMountsAllSelect:SetChecked(true)
        if allEnabled == 1 then
            checkedTexture:SetDesaturated(false)
        else
            checkedTexture:SetDesaturated(true)
        end
    end
end

local function UpdateMountButton(button, mount)
    button.mount = mount
    button.icon:SetNormalTexture(mount:Icon())
    button.name:SetText(mount:Name())

    if not InCombatLockdown() then
        mount:SetupActionButton(button.icon)
    end

    local i = 1
    while button["bit"..i] do
        BitButtonUpdate(button["bit"..i], mount)
        i = i + 1
    end

    if LM_Options:IsExcludedMount(mount) then
        button.enabled:SetChecked(false)
    else
        button.enabled:SetChecked(true)
    end

    -- if mount:IsUsable() then
    --     button.icon:Enable()
    --     button.icon.unusable:Hide()
    -- else
    --     button.icon:Disable()
    --     button.icon.unusable:SetBlendMode("ADD")
    --     button.icon.unusable:SetAlpha(0.25)
    --     button.icon.unusable:Show()
    -- end

    button.enabled.setFunc = function(setting)
                            EnableDisableMount(button.mount, setting)
                            button.enabled:GetScript("OnEnter")(button.enabled)
                            UpdateAllSelected()
                        end

    if GameTooltip:GetOwner() == button.enabled then
        button.enabled:GetScript("OnEnter")(button.enabled)
    end

end

function LiteMountOptions_AllSelect_OnClick(self)
    local mounts = GetFilteredMountList()

    local on

    if self:GetChecked() then
        on = "1"
    else
        on = "0"
    end

    for _,m in ipairs(mounts) do
        EnableDisableMount(m, on)
    end

    self:GetScript("OnEnter")(self)
    LiteMountOptions_UpdateMountList()

end

function LiteMountOptions_UpdateMountList()

    local scrollFrame = LiteMountOptionsMounts.scrollFrame
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons

    if not buttons then return end

    local mounts = GetFilteredMountList()

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

    UpdateAllSelected(mounts)

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

function LiteMountOptionsMounts_OnLoad(self)

    -- Because we're the wrong size at the moment we'll only have 1 button
    CreateMoreButtons(self.scrollFrame)

    self.name = MOUNTS
    self.default = function ()
            for m in LM_PlayerMounts:Iterate() do
                LM_Options:ResetMountFlags(m)
            end
            LM_Options:SetExcludedMounts({})
            LiteMountOptions_UpdateMountList()
        end

    LiteMountOptionsPanel_OnLoad(self)
end


function LiteMountOptionsMounts_OnShow(self)
    LiteMountOptions.CurrentOptionsPanel = self
    LiteMountOptions_UpdateMountList()
end

