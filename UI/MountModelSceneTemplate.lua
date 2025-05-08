--[[----------------------------------------------------------------------------

  LiteMount/UI/MountModelScene.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

LiteMountMountModelSceneMixin = {}

function LiteMountMountModelSceneMixin:SetMount(mount)
    if mount.creatureDisplayID and mount.modelSceneID then
        self:TransitionToModelSceneID(mount.modelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, false)
        local mountActor = self:GetActorByTag("unwrapped")
        if mountActor then
            mountActor:Hide()
            mountActor:SetOnModelLoadedCallback(function () mountActor:Show() end)
            mountActor:SetModelByCreatureDisplayID(mount.creatureDisplayID, true)
            if mount.isSelfMount then
                mountActor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None)
                mountActor:SetAnimation(618)
            else
                mountActor:SetAnimationBlendOperation(Enum.ModelBlendOperation.Anim)
                mountActor:SetAnimation(0)
            end
        end
        self:AttachPlayerToMount(mountActor, mount.animID, mount.isSelfMount, true, mount.spellVisualKitID, false)

        -- I don't know why, but the playerActor affects the camera and the
        -- camera is wrong for some mounts without this. I think?
        local playerActor = self:GetActorByTag("player-rider")
        if playerActor then
            playerActor:ClearModel()
        end

        self:Show()
    else
        self:Hide()
    end
end
