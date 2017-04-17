--[[----------------------------------------------------------------------------

  LiteMount/UIOptionsMounts.lua

  Options frame for the mount list.

  Copyright 2011-2017 Mike Battersby

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
        b.bit1.flagbit = LM_FLAG.RUN
        b.bit2.flagbit = LM_FLAG.FLY
        b.bit3.flagbit = LM_FLAG.SWIM
        b.bit4.flagbit = LM_FLAG.AQ
        b.bit5.flagbit = LM_FLAG.VASHJIR
        b.bit6.flagbit = LM_FLAG.CUSTOM2
        b.bit7.flagbit = LM_FLAG.CUSTOM1
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

function LiteMountOptionsMountsFilterDropDown_Initialize(self, level)
    local info = UIDropDownMenu_CreateInfo()
    info.keepShownOnClick = true

    local function flagFunc(self, arg1, arg2, v)
        LM_Options.db.uiMountFilterList[arg1] = (not v or nil)
        LiteMountOptions_UpdateMountList()
    end

    if level == 1 then

        info.func = flagFunc
        info.isNotRadio = true

        info.text = VIDEO_OPTIONS_ENABLED
        info.arg1 = "ENABLED"
        info.checked = not LM_Options.db.uiMountFilterList.ENABLED
        UIDropDownMenu_AddButton(info, level)

        info.text = VIDEO_OPTIONS_DISABLED
        info.arg1 = "DISABLED"
        info.checked = not LM_Options.db.uiMountFilterList.DISABLED
        UIDropDownMenu_AddButton(info, level)

        info.text = NOT_COLLECTED
        info.arg1 = "NOT_COLLECTED"
        info.checked = not LM_Options.db.uiMountFilterList.NOT_COLLECTED
        UIDropDownMenu_AddButton(info, level)

        info.text = MOUNT_JOURNAL_FILTER_UNUSABLE
        info.arg1 = "UNUSABLE"
        info.checked = not LM_Options.db.uiMountFilterList.UNUSABLE
        UIDropDownMenu_AddButton(info, level)

        info.text = "Flags"
        info.checked = nil
        info.func = nil
        info.isNotRadio = nil
        info.hasArrow = true
        info.notCheckable = true
        info.value = 1
        UIDropDownMenu_AddButton(info, level)
    elseif level == 2 then
        info.isNotRadio = true
        info.notCheckable = true

        info.text = CHECK_ALL
        info.func = function () 
                for k in pairs(LM_FLAG) do 
                    LM_Options.db.uiMountFilterList[k] = nil
                end
                UIDropDownMenu_Refresh(LiteMountOptionsMountsFilterDropDown, 1, 2)
                LiteMountOptions_UpdateMountList()
            end
        UIDropDownMenu_AddButton(info, level)

        info.text = UNCHECK_ALL
        info.func = function ()
                for k in pairs(LM_FLAG) do 
                    LM_Options.db.uiMountFilterList[k] = true
                end
                UIDropDownMenu_Refresh(LiteMountOptionsMountsFilterDropDown, 1, 2)
                LiteMountOptions_UpdateMountList()
            end
        UIDropDownMenu_AddButton(info, level)

        info.notCheckable = false
        info.func = flagFunc

        local allFlags = { }
        for flagName in pairs(LM_FLAG) do tinsert(allFlags, flagName) end
        sort(allFlags, function(a,b) return LM_FLAG[a] < LM_FLAG[b] end)

        for _, flagName in ipairs(allFlags) do 
            info.text = flagName
            info.arg1 = flagName
            info.checked = function ()
                    return not LM_Options.db.uiMountFilterList[flagName]
                end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

function LiteMountOptionsMountsFilterDropDown_OnLoad(self)
    UIDropDownMenu_Initialize(self, LiteMountOptionsMountsFilterDropDown_Initialize, "MENU")
end

local function FilterSort(a, b)
    if a.isCollected and not b.isCollected then return true end
    if not a.isCollected and b.isCollected then return false end
    return a.name < b.name
end

local function GetFilteredMountList()

    local filters = LM_Options.db.uiMountFilterList

    local mounts = LM_PlayerMounts:GetAllMounts():Sort(FilterSort)

    local filtertext = LiteMountOptionsMounts.Search:GetText()
    if filtertext == SEARCH then
        filtertext = ""
    else
        filtertext = strlower(filtertext)
    end

    for i = #mounts, 1, -1 do
        local m = mounts[i]

        local remove = false

        if m.isFiltered then
            remove = true
        end

        if LM_Options:IsExcludedMount(m) and filters.DISABLED then
            remove = true
        end

        if not LM_Options:IsExcludedMount(m) and filters.ENABLED then
            remove = true
        end

        if not m.isCollected and filters.NOT_COLLECTED then
            remove = true
        end

        local filterFlags = 0
        for flagName, flagBit in pairs(LM_FLAG) do
            if filters[flagName] then
                filterFlags = bit.bor(filterFlags, flagBit)
            end
        end

        if bit.band(m:CurrentFlags(), filterFlags) == m:CurrentFlags() then
            remove = true
        end

        -- strfind is expensive, avoid if possible
        if not remove and filtertext ~= "" then
            local matchname = strlower(m:Name())
            if not strfind(matchname, filtertext, 1, true) then
                remove = true
            end
        end


        if remove then
            tremove(mounts, i)
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

    if not mount.isCollected then
        button.name:SetFontObject("GameFontDisable")
        button.icon:GetNormalTexture():SetDesaturated(true)
    else
        button.name:SetFontObject("GameFontNormal")
        button.icon:GetNormalTexture():SetDesaturated(false)
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

