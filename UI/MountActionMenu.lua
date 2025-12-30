--[[----------------------------------------------------------------------------

  LiteMount/UI/MountActionMenu.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local allTypeFlags = LM.Options:GetFlags()

--[[------------------------------------------------------------------------]]--

function LM.MountActionMenuGenerator(owner, rootDescription)
    rootDescription:CreateTitle(owner.mount.name)

    local mountGroups = owner.mount:GetGroups()
    local allGroups = LM.Options:GetGroupNames()

    local groupMenu = rootDescription:CreateButton(L.LM_GROUPS)
    for _, g in pairs(allGroups) do
        local function IsSelected() return mountGroups[g] end
        local function SetSelected(...)
            if mountGroups[g] then
                LM.Options:ClearMountGroup(owner.mount, g)
            else
                LM.Options:SetMountGroup(owner.mount, g)
            end
        end
        if LM.Options:IsGlobalGroup(g) then
            g = BLUE_FONT_COLOR:WrapTextInColorCode(g)
        end
        groupMenu:CreateRadio(g, IsSelected, SetSelected)
    end

    local priorityMenu = rootDescription:CreateButton(L.LM_PRIORITY)
    for _,p in ipairs(LM.UIFilter.GetPriorities()) do
        local t, d = LM.UIFilter.GetPriorityText(p)
        local function IsSelected() return owner.mount:GetPriority() == p end
        local function SetSelected() LM.Options:SetPriority(owner.mount, p) end
        priorityMenu:CreateRadio(t..' - '..d, IsSelected, SetSelected)
    end
    for _, flag in ipairs(allTypeFlags) do
        local function IsSelected()
            local mountFlags = owner.mount:GetFlags()
            return mountFlags[flag]
        end
        local function SetSelected()
            if IsSelected() then
                LM.Options:ClearMountFlag(owner.mount, flag)
            else
                LM.Options:SetMountFlag(owner.mount, flag)
            end
        end
        rootDescription:CreateCheckbox(L[flag], IsSelected, SetSelected)
    end
end
