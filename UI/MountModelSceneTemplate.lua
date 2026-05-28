--[[----------------------------------------------------------------------------

  LiteMount/UI/MountModelScene.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

LiteMountMountModelSceneMixin = {}

-- I have no idea what this really is, but 4 is what 99% of the mounts use
local DEFAULT_MODELSCENEID = 4

function LiteMountMountModelSceneMixin:SetMount(mount)
    if mount.creatureDisplayID then
        self:TransitionToModelSceneID(mount.modelSceneID or DEFAULT_MODELSCENEID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, false)
-- self:SetViewTranslation(0, -80)
        local mountActor = self:GetActorByTag("unwrapped")
        if mountActor then
mountActor:SetUseCenterForOrigin(true, true, true)
mountActor:SetPosition(0, 0, 0)
DevTools_Dump({
    activeBB = { mountActor:GetActiveBoundingBox() },
    maxBB = { mountActor:GetMaxBoundingBox() },
    yaw = { mountActor:GetYaw() },
    iucfo = { mountActor:IsUsingCenterForOrigin() },
    pos = { mountActor:GetPosition() },
    scale = { mountActor:GetScale() },
})
            local n = math.random(#mount.creatureDisplayID)
            mountActor:Hide()
            mountActor:SetOnModelLoadedCallback(function () mountActor:Show() end)
            mountActor:SetModelByCreatureDisplayID(mount.creatureDisplayID[n], true)
            mountActor:SetDesaturation(mount.creatureDesaturation or 0)
            mountActor:SetAlpha(mount.creatureAlpha or 1)
            if mount.isSelfMount then
                mountActor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None)
                mountActor:SetAnimation(618)
            else
                mountActor:SetAnimationBlendOperation(Enum.ModelBlendOperation.Anim)
                mountActor:SetAnimation(0)
            end
        end
        self:AttachPlayerToMount(mountActor, mount.animID or 0, mount.isSelfMount, true, mount.spellVisualKitID, false)

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
