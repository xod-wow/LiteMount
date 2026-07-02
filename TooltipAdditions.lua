--[[----------------------------------------------------------------------------

    Hook tooltips and show mount rarity.

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.L

LM.TooltipAdditions = {}

local InCombatLockdown = InCombatLockdown
local TooltipUtil = TooltipUtil
local issecretvalue = issecretvalue or function () return false end

local fmt = "|T%s:16:16|t %s (%s)"

-- Only for journal mounts
local function GetMountText(m)
    m:Refresh()
    if not m.mountID then
        return m.name
    elseif m:IsCollected() then
        return string.format(fmt, m.icon, m.name, COLLECTED)
    else
        return string.format(fmt, m.icon, m.name, NOT_COLLECTED)
    end
end

local function UnitPost(tooltip, data)
    if InCombatLockdown() or not LM.Options:GetOption('tooltipAdditions') then
        return
    end
    local _, unitToken = TooltipUtil.GetDisplayedUnit(tooltip)
    if unitToken and not issecretvalue(unitToken) then
        local m = LM.MountRegistry:GetMountFromUnitAura(unitToken)
        if m and m.mountID and m.rarity then
            GameTooltip_AddBlankLineToTooltip(tooltip)
            local c = LM.UIFilter.GetRarityColor(m.rarity)
            local r = string.format(L.LM_RARITY_FORMAT, m.rarity)
            tooltip:AddDoubleLine(GetMountText(m), c:WrapTextInColorCode(r))
        end
    end
end

local function ItemPost(tooltip, data)
    if InCombatLockdown() or not LM.Options:GetOption('tooltipAdditions') then
        return
    end
    local _, _, itemID = TooltipUtil.GetDisplayedItem(tooltip)
    if not itemID or issecretvalue(itemID) then
        return
    end
    local mountID = C_MountJournal.GetMountFromItem(itemID)
    if mountID then
        local m = LM.MountRegistry:GetMountByID(mountID)
        -- Add if we've collected it on items maybe?
        if m and m.rarity then
            GameTooltip_AddBlankLineToTooltip(tooltip)
            local c = LM.UIFilter.GetRarityColor(m.rarity)
            local text = string.format(L.LM_RARITY_FORMAT_LONG, m.rarity)
            GameTooltip_AddColoredLine(tooltip, text, c)
        end
    end
end

function LM.TooltipAdditions:Initialize()
    if WOW_PROJECT_ID == 1 then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, UnitPost)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, ItemPost)
    end
end
