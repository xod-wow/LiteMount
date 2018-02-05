--[[----------------------------------------------------------------------------

  LiteMount/MountsFilter.lua

  UI Filter state abstracted out similar to how C_MountJournal does it

  Copyright 2011-2018 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

_G.LM_UIFilter = { }


-- Sources ---------------------------------------------------------------------

local sourceFilterList = { }

function LM_UIFilter.GetNumSources()
    return C_PetJournal.GetNumPetSources() + 1
end

function LM_UIFilter.SetAllSourceFilters(v)
    if v then
        wipe(sourceFilterList)
    else
        for i = 1,LM_UIFilter.GetNumSources() do
            if LM_UIFilter.IsValidSourceFilter(i) then
                sourceFilterList[i] = true
            end
        end
    end
end

function LM_UIFilter.SetSourceFilter(i, v)
    if v then
        sourceFilterList[i] = nil
    else
        sourceFilterList[i] = true
    end
end

function LM_UIFilter.IsSourceChecked(i)
    return not sourceFilterList[i]
end

function LM_UIFilter.IsValidSourceFilter(i)
    if C_MountJournal.IsValidSourceFilter(i) then
        return true
    elseif i == C_PetJournal.GetNumPetSources() + 1 then
        return true
    else
        return false
    end
end

function LM_UIFilter.GetSourceText(i)
    local n = C_PetJournal.GetNumPetSources()
    if i <= n then
        return _G["BATTLE_PET_SOURCE_"..i]
    elseif i == n+1 then
        return OTHER
    end
end


-- Sources ---------------------------------------------------------------------

function LM_UIFilter.IsFlagChecked(f)
    return not LM_Options.db.profile.uiMountFilterList[f]
end

function LM_UIFilter.SetFlagFilter(f, v)
    LM_Options.db.profile.uiMountFilterList[f] = (not v)
end

function LM_UIFilter:SetAllFlagFilters(v)
    for _,f in ipairs(LM_UIFilter.GetFlags()) do
        LM_UIFilter.SetFlagFilter(f, v)
    end
end

function LM_UIFilter.GetFlags()
    return LM_Options:GetAllFlags()
end

function LM_UIFilter.GetFlagText(f)
    if LM_Options:IsPrimaryFlag(f) then
        return ITEM_QUALITY_COLORS[2].hex
            .. L[f]
            .. FONT_COLOR_CODE_CLOSE
    else
        return f
    end
end


-- Search ----------------------------------------------------------------------

local searchText

function LM_UIFilter.SetSearchText(t)
    searchText = t
end

function LM_UIFilter.GetSearchText(t)
    return searchText
end


-- Check -----------------------------------------------------------------------

function LM_UIFilter.IsFilteredMount(m)

    local filters = LM_Options.db.profile.uiMountFilterList

    if m.isFiltered then
        return true
    end

    local source = m.sourceType
    if not source or source == 0 then
        source = LM_UIFilter.GetNumSources()
    end

    if sourceFilterList[source] == true then
        return true
    end

    if filters.DISABLED and LM_Options:IsExcludedMount(m) then
        return true
    end

    if filters.ENABLED and not LM_Options:IsExcludedMount(m) then
        return true
    end

    if filters.COLLECTED and m.isCollected then
        return true
    end

    if filters.NOT_COLLECTED and not m.isCollected then
        return true
    end

    if filters.UNUSABLE and m.needsFaction and m.needsFaction ~= UnitFactionGroup("player") then
        return true
    end

    local okflags = CopyTable(m:CurrentFlags())
    local noFilters = true
    for _,flagName in ipairs(LM_Options:GetAllFlags()) do
        if filters[flagName] then
            okflags[flagName] = nil
            noFilters = false
        end
    end
    if noFilters == false and next(okflags) == nil then
        return true
    end

    -- strfind is expensive, avoid if possible, leave this at the end
    local filtertext = LM_UIFilter.GetSearchText()
    if not filtertext or filtertext == SEARCH or filtertext == "" then
        return false
    end

    if filtertext == "=" then
        local spellName = GetSpellInfo(m.spellID)
        return UnitAura("player", spellName) == nil
    end

    return strfind(m.name:lower(), filtertext:lower(), 1, true) == nil
end
