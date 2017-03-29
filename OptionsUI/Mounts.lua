--[[----------------------------------------------------------------------------

  LiteMount/OptionsUI/Mounts.lua

  Options frame for the mount list.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

function LM_OptionsUIMountsFlag_OnClick(self)
    local mount = self:GetParent().mount

    if self:GetChecked() then
        LM_Options:SetMountFlag(mount, self.flag)
    else
        LM_Options:ClearMountFlag(mount, self.flag)
    end
    LM_OptionsUIMounts_UpdateMountList()
end

-- Because we get attached inside the blizzard options container, we
-- are size 0x0 on create and even after OnShow, we have to trap
-- OnSizeChanged on the scrollframe to make the buttons correctly.
local function CreateMoreButtons(self)
    HybridScrollFrame_CreateButtons(self, "LM_OptionsUIMountsButtonTemplate",
                                    0, -1, "TOPLEFT", "TOPLEFT",
                                    0, -1, "TOP", "BOTTOM")

    -- Note: the buttons are laid out right to left
    for _,b in ipairs(self.buttons) do
        b:SetWidth(b:GetParent():GetWidth())
        b.flag1.flag = LM_FLAG.RUN
        b.flag2.flag = LM_FLAG.FLY
        b.flag3.flag = LM_FLAG.SWIM
        b.flag4.flag = LM_FLAG.AQ
        b.flag5.flag = LM_FLAG.VASHJIR
        b.flag6.flag = LM_FLAG.CUSTOM2
        b.flag7.flag = LM_FLAG.CUSTOM1
    end
end

local function EnableDisableMount(mount, onoff)
    if onoff == "0" then
        LM_Options:AddExcludedMount(mount)
    else
        LM_Options:RemoveExcludedMount(mount)
    end
end

local function FlagButtonUpdate(checkButton, mount)
    local flags = mount:CurrentFlags()

    checkButton:SetChecked(flags[checkButton.flag])

    -- If we changed this from the default then color the background
    if flags[checkButton.flag] == mount.flags[checkButton.flag] then
        checkButton.modified:Hide()
    else
        checkButton.modified:Show()
    end
end

local function GetFilteredMountList()
    local function notBlizFiltered(m)
        return m.isFiltered ~= true
    end

    local mounts = LM_PlayerMounts:Search(notBlizFiltered)

    local function cmp(a,b)
        if a.isCollected == b.isCollected then
            return a.name < b.name
        elseif a.isCollected then
            return true
        else
            return false
        end
    end

    sort(mounts, cmp)

    local filtertext = LM_OptionsUIMounts.filter:GetText()
    if filtertext == SEARCH then
        filtertext = ""
    else
        filtertext = CaseAccentInsensitiveParse(filtertext)
    end

    local n

    filtertext, n = gsub(filtertext, "^+fly *", "", 1)
    if n == 1 then
        for i = #mounts, 1, -1 do
            if not tContains(mounts[i]:CurrentFlags(), LM_FLAG.FLY) then
                tremove(mounts, i)
            end
        end
    end

    filtertext, n = gsub(filtertext, "^+run *", "", 1)
    if n == 1 then
        for i = #mounts, 1, -1 do
            if not tContains(mounts[i]:CurrentFlags(), LM_FLAG.RUN) then
                tremove(mounts, i)
            end
        end
    end

    filtertext, n = gsub(filtertext, "^+swim *", "", 1)
    if n == 1 then
        for i = #mounts, 1, -1 do
            if not tContains(mounts[i]:CurrentFlags(), LM_FLAG.SWIM) then
                tremove(mounts, i)
            end
        end
    end

    filtertext, n = gsub(filtertext, "^+c1 *", "", 1)
    if n == 1 then
        for i = #mounts, 1, -1 do
            if not tContains(mounts[i]:CurrentFlags(), LM_FLAG.CUSTOM1) then
                tremove(mounts, i)
            end
        end
    end

    filtertext, n = gsub(filtertext, "^+c2 *", "", 1)
    if n == 1 then
        for i = #mounts, 1, -1 do
            if not tContains(mounts[i]:CurrentFlags(), LM_FLAG.CUSTOM2) then
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
            if not UnitAura("player", mounts[i].spellName) then
                tremove(mounts, i)
            end
        end
    end

    if filtertext ~= "" then
        for i = #mounts, 1, -1 do
            local matchname = CaseAccentInsensitiveParse(mounts[i].name)
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

    local checkedTexture = LM_OptionsUIMountsAllSelect:GetCheckedTexture()
    if allDisabled == 1 then
        LM_OptionsUIMountsAllSelect:SetChecked(false)
    else
        LM_OptionsUIMountsAllSelect:SetChecked(true)
        if allEnabled == 1 then
            checkedTexture:SetDesaturated(false)
        else
            checkedTexture:SetDesaturated(true)
        end
    end
end

local function StyleCollected(button, torf)
    if torf then
        button.name:SetFontObject("GameFontNormal")
        button.icon:GetNormalTexture():SetDesaturated(false)
        button.icon:GetNormalTexture():SetAlpha(1.0)
        button.enabled:GetCheckedTexture():SetDesaturated(false)
        button.enabled:GetCheckedTexture():SetAlpha(1.0)
    else
        button.name:SetFontObject("GameFontDisable")
        button.icon:GetNormalTexture():SetDesaturated(true)
        button.icon:GetNormalTexture():SetAlpha(0.75)
        button.enabled:GetCheckedTexture():SetDesaturated(true)
        button.enabled:GetCheckedTexture():SetAlpha(0.75)
    end
end

local function UpdateMountButton(button, mount)
    button.mount = mount
    button.icon:SetNormalTexture(mount.iconTexture)
    button.name:SetText(mount.name)

    if not InCombatLockdown() then
        mount:SetupActionButton(button.icon)
    end

    StyleCollected(button, mount.isCollected)

    local i = 1
    while button["flag"..i] do
        FlagButtonUpdate(button["flag"..i], mount)
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

function LM_OptionsUIMounts_AllSelect_OnClick(self)
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
    LM_OptionsUIMounts_UpdateMountList()

end

function LM_OptionsUIMounts_UpdateMountList()

    local scrollFrame = LM_OptionsUIMounts.scrollFrame
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

function LM_OptionsUIMountsScrollFrame_OnSizeChanged(self, w, h)
    CreateMoreButtons(self)
    LM_OptionsUIMounts_UpdateMountList()

    self.stepSize = self.buttonHeight
    self.update = LM_OptionsUIMounts_UpdateMountList
end

local function ProfileClick(self, arg1, arg1, checked)
    UIDropDownMenu_SetSelectedID(UIDROPDOWNMENU_INIT_MENU, self:GetID())
end

local function ProfileInit(self, level)
    local info

    info = UIDropDownMenu_CreateInfo()
    info.isTitle = 1
    info.text = "Select Profile"
    info.notCheckable = 1
    UIDropDownMenu_AddButton(info, level)

    for _,v in ipairs(LM_Options.db:GetProfiles()) do
        info = UIDropDownMenu_CreateInfo()
        info.text = v
        info.value = v
        info.checked = (v == LM_Options.db:GetCurrentProfile())
        info.func = ProfileClick
        UIDropDownMenu_AddButton(info, level)
    end
end

function LM_OptionsUIMountsProfile_OnShow(self)
    UIDropDownMenu_Initialize(self, ProfileInit)
    UIDropDownMenu_SetWidth(self, 100)
    UIDropDownMenu_SetButtonWidth(self, 124)
    UIDropDownMenu_JustifyText(self, "RIGHT")
    UIDropDownMenu_SetSelectedValue(self, LM_Options.db:GetCurrentProfile())
end

function LM_OptionsUIMounts_OnLoad(self)

    -- Because we're the wrong size at the moment we'll only have 1 button
    CreateMoreButtons(self.scrollFrame)

    self.name = format("%s %s", MOUNT, OPTIONS)
    self.default = function ()
            for m in LM_PlayerMounts:Iterate() do
                LM_Options:ResetMountFlags(m)
            end
            LM_Options:SetExcludedMounts({})
            LM_OptionsUIMounts_UpdateMountList()
        end

    LM_OptionsUIPanel_OnLoad(self)
end


function LM_OptionsUIMounts_OnShow(self)
    LM_OptionsUI.CurrentOptionsPanel = self
    LM_OptionsUIMounts_UpdateMountList()
end
