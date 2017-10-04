--[[----------------------------------------------------------------------------

  LiteMount/Mounts.lua

  Options frame for the mount list.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

local NUM_FLAG_BUTTONS = 6

function LiteMountOptionsBit_OnClick(self)
    local mount = self:GetParent().mount

    if self:GetChecked() then
        LM_Options:SetMountFlag(mount, self.flag)
    else
        LM_Options:ClearMountFlag(mount, self.flag)
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
    end
end

local function EnableDisableMount(mount, onoff)
    if onoff == "0" then
        LM_Options:AddExcludedMount(mount)
    else
        LM_Options:RemoveExcludedMount(mount)
    end
end

local function BitButtonUpdate(checkButton, flag, mount)
    checkButton.flag = flag

    if not flag then
        checkButton:Hide()
        return
    else
        checkButton:Show()
    end

    local cur = mount:CurrentFlags()

    checkButton:SetChecked(cur[flag] or false)

    -- If we changed this from the default then color the background
    checkButton.Modified:SetShown(mount.flags[flag] ~= cur[flag])
end

function LiteMountOptionsMountsFilterDropDown_Initialize(self, level)
    local info = UIDropDownMenu_CreateInfo()
    info.keepShownOnClick = true

    local function flagFunc(self, arg1, arg2, v)
        LM_Options.db.char.uiMountFilterList[arg1] = (not v or nil)
        LiteMountOptions_UpdateMountList()
    end

    if level == 1 then
        info.func = flagFunc
        info.isNotRadio = true

        info.text = VIDEO_OPTIONS_ENABLED
        info.arg1 = "ENABLED"
        info.checked = not LM_Options.db.char.uiMountFilterList.ENABLED
        UIDropDownMenu_AddButton(info, level)

        info.text = VIDEO_OPTIONS_DISABLED
        info.arg1 = "DISABLED"
        info.checked = not LM_Options.db.char.uiMountFilterList.DISABLED
        UIDropDownMenu_AddButton(info, level)

        info.text = COLLECTED
        info.arg1 = "COLLECTED"
        info.checked = not LM_Options.db.char.uiMountFilterList.COLLECTED
        UIDropDownMenu_AddButton(info, level)

        info.text = NOT_COLLECTED
        info.arg1 = "NOT_COLLECTED"
        info.checked = not LM_Options.db.char.uiMountFilterList.NOT_COLLECTED
        UIDropDownMenu_AddButton(info, level)

        info.text = MOUNT_JOURNAL_FILTER_UNUSABLE
        info.arg1 = "UNUSABLE"
        info.checked = not LM_Options.db.char.uiMountFilterList.UNUSABLE
        UIDropDownMenu_AddButton(info, level)

        info.text = L.LM_FLAGS
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
                for _,k in ipairs(LM_Options:GetAllFlags()) do 
                    LM_Options.db.char.uiMountFilterList[k] = nil
                end
                UIDropDownMenu_Refresh(LiteMountOptionsMountsFilterDropDown, 1, 2)
                LiteMountOptions_UpdateMountList()
            end
        UIDropDownMenu_AddButton(info, level)

        info.text = UNCHECK_ALL
        info.func = function ()
                for _,k in ipairs(LM_Options:GetAllFlags()) do 
                    if LM_Options:IsFilterFlag(k) then
                        LM_Options.db.char.uiMountFilterList[k] = true
                    end
                end
                UIDropDownMenu_Refresh(LiteMountOptionsMountsFilterDropDown, 1, 2)
                LiteMountOptions_UpdateMountList()
            end
        UIDropDownMenu_AddButton(info, level)

        info.notCheckable = false
        info.func = flagFunc

        local allFlags = LM_Options:GetAllFlags()
        for _,flagName in ipairs(allFlags) do
            if LM_Options:IsFilterFlag(flagName) then
                if LM_Options:IsPrimaryFlag(flagName) then
                    info.text = ITEM_QUALITY_COLORS[2].hex .. L[flagName] .. FONT_COLOR_CODE_CLOSE
                else
                    info.text = L[flagName]
                end
                info.arg1 = flagName
                info.checked = function ()
                        return not LM_Options.db.char.uiMountFilterList[flagName]
                    end
                UIDropDownMenu_AddButton(info, level)
            end
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

    local filters = LM_Options.db.char.uiMountFilterList

    local mounts = LM_PlayerMounts:GetAllMounts()
    sort(mounts, FilterSort)

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
        elseif filters.DISABLED and LM_Options:IsExcludedMount(m) then
            remove = true
        elseif filters.ENABLED and not LM_Options:IsExcludedMount(m) then
            remove = true
        elseif filters.COLLECTED and m.isCollected then
            remove = true
        elseif filters.NOT_COLLECTED and not m.isCollected then
            remove = true
        elseif filters.UNUSABLE and m.needsFaction and m.needsFaction ~= UnitFactionGroup("player") then
            remove = true
        else
            local okflags = m:CurrentFlags()
            local noFilters = true
            for _,flagName in ipairs(LM_Options:GetAllFlags()) do
                if filters[flagName] then
                    okflags[flagName] = nil
                    noFilters = false
                end
            end
            if noFilters == false and next(okflags) == nil then
                remove = true
            end
        end

        -- strfind is expensive, avoid if possible
        if not remove then
            if filtertext == "=" then
                local spellName = GetSpellInfo(m.spellID)
                if UnitAura("player", spellName) == nil then
                    remove = true
                end
            elseif filtertext ~= "" then
                local matchname = strlower(m.name)
                if not strfind(matchname, filtertext, 1, true) then
                    remove = true
                end
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

    local checkedTexture = LiteMountOptionsMounts.AllSelect:GetCheckedTexture()
    if allDisabled == 1 then
        LiteMountOptionsMounts.AllSelect:SetChecked(false)
    else
        LiteMountOptionsMounts.AllSelect:SetChecked(true)
        if allEnabled == 1 then
            checkedTexture:SetDesaturated(false)
        else
            checkedTexture:SetDesaturated(true)
        end
    end
end

local function UpdateMountButton(button, pageFlags, mount)
    button.mount = mount
    button.Icon:SetNormalTexture(mount.icon)
    button.Name:SetText(mount.name)

    if not InCombatLockdown() then
        for k,v in pairs(mount:GetSecureAttributes()) do
            button.Icon:SetAttribute(k, v)
        end
    end

    local i = 1
    while button["Bit"..i] do
        BitButtonUpdate(button["Bit"..i], pageFlags[i], mount)
        i = i + 1
    end

    if not mount.isCollected then
        button.Name:SetFontObject("GameFontDisable")
        button.Icon:GetNormalTexture():SetDesaturated(true)
    else
        button.Name:SetFontObject("GameFontNormal")
        button.Icon:GetNormalTexture():SetDesaturated(false)
    end

    if LM_Options:IsExcludedMount(mount) then
        button.Enabled:SetChecked(false)
    else
        button.Enabled:SetChecked(true)
    end

    button.Enabled.setFunc = function(setting)
                            EnableDisableMount(button.mount, setting)
                            button.Enabled:GetScript("OnEnter")(button.Enabled)
                            UpdateAllSelected()
                        end

    if GameTooltip:GetOwner() == button.Enabled then
        button.Enabled:GetScript("OnEnter")(button.Enabled)
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


function LiteMountOptions_UpdateFlagPaging()
    local self = LiteMountOptionsMounts
    local allFlags = LM_Options:GetAllFlags()

    self.maxFlagPages = math.ceil(#allFlags / NUM_FLAG_BUTTONS)
    self.PrevPageButton:SetEnabled(self.currentFlagPage ~= 1)
    self.NextPageButton:SetEnabled(self.currentFlagPage ~= self.maxFlagPages)

    local pageOffset = (self.currentFlagPage - 1 ) * NUM_FLAG_BUTTONS + 1
    self.pageFlags = LM_tSlice(allFlags, pageOffset, pageOffset+NUM_FLAG_BUTTONS-1)

    local bt
    for i = 1, NUM_FLAG_BUTTONS do
        bt = self["BitText"..i]
        if self.pageFlags[i] then
            bt:SetText(L[self.pageFlags[i]])
            bt:Show()
        else
            bt:Hide()
        end
    end
end

function LiteMountOptions_UpdateMountList()

    local scrollFrame = LiteMountOptionsMounts.ScrollFrame
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons

    if not buttons then return end

    local mounts = GetFilteredMountList()

    for i = 1, #buttons do
        local button = buttons[i]
        local index = offset + i
        if index <= #mounts then
            UpdateMountButton(button, LiteMountOptionsMounts.pageFlags, mounts[index])
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
    CreateMoreButtons(self.ScrollFrame)

    self.name = MOUNTS
    self.default = function ()
            for m in LM_PlayerMounts:Iterate() do
                LM_Options:ResetMountFlags(m)
            end
            LM_Options:SetExcludedMounts({})
            LiteMountOptions_UpdateMountList()
        end

    self.currentFlagPage = 1
    self.maxFlagPages = 1
    self.pageFlags = { }
    self.NextFlagPage = function (self)
        self.currentFlagPage = Clamp(self.currentFlagPage + 1, 1, self.maxFlagPages)
        LiteMountOptions_UpdateFlagPaging(self)
        LiteMountOptions_UpdateMountList()
    end
    self.PrevFlagPage = function (self)
        self.currentFlagPage = Clamp(self.currentFlagPage - 1, 1, self.maxFlagPages)
        LiteMountOptions_UpdateFlagPaging()
        LiteMountOptions_UpdateMountList()
    end

    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountOptionsMounts_OnShow(self)
    -- This is specifically to catch the "Currently Active Mount" filter
    self:SetScript("OnEvent", LiteMountOptions_UpdateMountList)
    self:RegisterUnitEvent("UNIT_AURA", "player")

    LM_Options.db.RegisterCallback(self, "OnProfileCopied", LiteMountOptions_UpdateMountList)
    LM_Options.db.RegisterCallback(self, "OnProfileChanged", LiteMountOptions_UpdateMountList)
    LM_Options.db.RegisterCallback(self, "OnProfileReset", LiteMountOptions_UpdateMountList)

    LiteMountOptions_UpdateFlagPaging()
    LiteMountOptions_UpdateMountList()
    LiteMountOptionsPanel_OnShow(self)
end

function LiteMountOptionsMounts_OnHide(self)
    self:UnregisterEvent("UNIT_AURA", "player")
    LM_Options.db.UnregisterAllCallbacks(self)
end
