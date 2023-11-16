--[[----------------------------------------------------------------------------

  LiteMount/ActionButton.lua

  A SecureActionButton to call mount rules based on an action list.

  Fancy SecureActionButton stuff. The default button mechanism is
  type="macro" macrotext="...". If we're not in combat we
  use a preclick handler to set it to what we really want to do.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local L = LM.Localize

LM.ActionButton = { }

-- inputButton here is not real, because only LeftButton comes through the
-- keybinding interface. But, you can pass arbitrary text as this argument
-- with the /click slash command. E.g., /click LM_B1 blah

function LM.ActionButton:PreClick(inputButton, isDown)

    -- SecureActionButtonTemplate in 10.0 only fires the secure actions when
    -- isDown matches the setting of ActionButtonUseKeyDown, even though it
    -- fires PreClick and PostClick for both. Due to poor code for for
    -- handling press-and-hold and the interns doing all the programming.
    --
    -- So our buttons are RegisterForClicks("AnyDown", "AnyUp"), this (and
    -- PostClick) get called twice and we only handle it if we match when
    -- Blizzard will call the actions.
    --
    -- Hilarously the Blizzard code has a comment saying "but we do want to
    -- allow AddOns to function as they did before"... and then they don't.
    -- Epic fail Blizzard!

    -- https://github.com/Stanzilla/WoWUIBugs/issues/317#issuecomment-1510847497
    -- if isDown ~= GetCVarBool("ActionButtonUseKeyDown") then return end

    if InCombatLockdown() then return end

    local startTime = debugprofilestop()

    LM.Debug(format("PreClick handler called on %s (inputButton=%s, isDown=%s)",
                self:GetName(), tostring(inputButton), tostring(isDown)))

    LM.MountRegistry:RefreshMounts()

    -- Re-randomize if it's time
    local keepRandomForSeconds = LM.Options:GetOption('randomKeepSeconds')
    if GetTime() - (self.context.randomTime or 0) > keepRandomForSeconds then
        self.context.random = math.random()
        self.context.randomTime = GetTime()
    end

    -- Set up the fresh run context for a new run.
    local context = self.context:Clone()
    context.inputButton = inputButton

    -- This uses a crazy amount of memory so just save it once
    context.mapPath = LM.Environment:GetMapPath()

    local ruleSet = LM.Options:GetCompiledButtonRuleSet(self.id)

    local act = ruleSet:Run(context)
    if act then
        act:SetupActionButton(self)
        LM.Debug("PreClick ok time " .. (debugprofilestop() - startTime))
        return
    end

    local handler = LM.Actions:GetHandler('CantMount')
    local act = handler()
    act:SetupActionButton(self)
    LM.Debug("PreClick fail time " .. (debugprofilestop() - startTime))
end

function LM.ActionButton:PostClick(inputButton, isDown)

    -- https://github.com/Stanzilla/WoWUIBugs/issues/317#issuecomment-1510847497
    -- if isDown ~= GetCVarBool("ActionButtonUseKeyDown") then return end

    if InCombatLockdown() then return end

    LM.Debug(format("PostClick handler called on %s (inputButton=%s, isDown=%s)",
                self:GetName(), tostring(inputButton), tostring(isDown)))

    -- We'd like to set the macro to undo whatever we did, but
    -- tests like IsMounted() and CanExitVehicle() will still
    -- represent the pre-action state at this point.  We don't want
    -- to just blindly do the opposite of whatever we chose because
    -- it might not have worked.

end

local PreClickSnippet = [[
    local keys = self:GetAttribute("combat-keys")
    if keys then
        for k in keys:gmatch("[^,]+") do
            self:SetAttribute(k, self:GetAttribute("combat-"..k))
        end
    end
]]

local PostClickSnippet = [[
    local keys = self:GetAttribute("combat-keys")
    if keys then
        for k in keys:gmatch("[^,]+") do
            self:SetAttribute(k, nil)
        end
    end
]]

-- Combat actions. A hack until I can figure where to put it all, now that
-- Blizzard have added an in-combat flying sitatuation.

function LM.ActionButton:PLAYER_REGEN_DISABLED(e, ...)
        local act
        -- Amirdrassil ugh
        if select(8, GetInstanceInfo()) == 2549 then
            local mounts = LM.MountRegistry:FilterSearch('DRAGONRIDING', 'COLLECTED')
            local m = mounts:SimpleRandom()
            if m then
                act = m:GetCastAction()
            end
        else
            act = LM.Actions:GetHandler('Combat')()
        end
        if act then
            self:SetAttribute("combat-keys", table.concat(GetKeysArray(act), ','))
            for k,v in pairs(act) do
                self:SetAttribute("combat-"..k, v)
            end
        end
end

function LM.ActionButton:PLAYER_REGEN_ENABLED(e, ...)
    local keys = self:GetAttribute("combat-keys")
    if keys then
        for k in keys:gmatch("[^,]+") do
            self:SetAttribute("combat-"..k, nil)
        end
            self:SetAttribute("combat-keys", nil)
    end
end

function LM.ActionButton:Create(n)

    local name = "LM_B" .. n

    local b = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
    Mixin(b, LM.ActionButton)

    -- So we can look up action lists in LM.Options
    b.id = n

    -- Global context
    b.context = LM.RuleContext:New({ id = n })

    -- b:RegisterForClicks("AnyDown", "AnyUp")
    -- https://github.com/Stanzilla/WoWUIBugs/issues/317#issuecomment-1510847497
    b:RegisterForClicks("AnyDown")

    -- SecureActionButton setup
    b:SetScript("PreClick", self.PreClick)
    b:SetScript("PostClick", self.PostClick)

    -- We could just wrap and unwrap on PLAYER_REGEN_x?
    SecureHandlerWrapScript(b, "OnClick", b, PreClickSnippet, PostClickSnippet)

    b:RegisterEvent("PLAYER_REGEN_DISABLED")
    b:RegisterEvent("PLAYER_REGEN_ENABLED")
    b:SetScript('OnEvent', function (self, e, ...) if self[e] then self[e](self, e, ...) end end)

    return b
end
