--[[----------------------------------------------------------------------------

  LiteMount/UI/Tooltip.lua

  Mount tooltip with preview scene

  Copyright 2011-2019 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

local function SetMount(self, m)

    if m.mountID then
        self:SetMountBySpellID(m.spellID)
    else
        self:SetSpellByID(m.spellID)
    end

    self.TextRight2:SetText(ID.." "..m.spellID)
    self.TextRight2:Show()

    if m.sourceText then
        LiteMountTooltip:AddLine(" ")
        LiteMountTooltip:AddLine("|cffffffff" .. SOURCE .. "|r")
        LiteMountTooltip:AddLine(m.sourceText)
    end

    if m.modelScene and m.creatureDisplay then
        self.ModelScene:TransitionToModelSceneID(m.modelScene, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN)
        local mountActor = self.ModelScene:GetActorByTag("unwrapped")
        if mountActor then
            mountActor:SetModelByCreatureDisplayID(m.creatureDisplay)
            if m.isSelfMount then
                mountActor:SetAnimationBlendOperation(LE_MODEL_BLEND_OPERATION_NONE)
                mountActor:SetAnimation(618)
            else
                mountActor:SetAnimationBlendOperation(LE_MODEL_BLEND_OPERATION_ANIM)
                mountActor:SetAnimation(0)
            end
        end

        -- This is ridiculous, but the sizing for GameTooltips is done in the C
        -- code. This is how GameTooltip_InsertFrame() does it.

        GameTooltip_AddBlankLinesToTooltip(self, 18)
        self.ModelScene:Show()
    else
        self.ModelScene:Hide()
    end

    if m:IsCastable() then
        LiteMountTooltip:AddLine(" ")
        LiteMountTooltip:AddDoubleLine(" ", "|cffff00ff" .. HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. ": " .. MOUNT .. "|r")
    end
end

local function AddParentKeys(frame)
    -- This adds parentKey for all the regions because Blizzard didn't
    local ttName = frame:GetName()
    local regions = { frame:GetRegions() }

    for _, r in ipairs(regions) do
        local name = r:GetName()
        if name and name:sub(1, #ttName) == ttName then
            name = name:sub(#ttName + 1)
            frame[name] = r
        end
    end
end

function LiteMountTooltip_OnLoad(self)
    AddParentKeys(self)
    self.SetMount = SetMount
    GameTooltip_OnLoad(self)
end
