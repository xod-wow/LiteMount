--[[----------------------------------------------------------------------------

  LiteMount/Developer.lua

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local MAX_SPELL_ID = 500000

LM.Developer = CreateFrame("Frame")

function LM.Developer:Initialize()
    self.usableOnSurface = self.usableOnSurface or {}
    self.usableUnderWater = self.usableUnderWater or {}
end

local function CoPartialUpdate(t)
    local i = #t + 1
    while true do
        if i > MAX_SPELL_ID then return end
        t[i] = IsUsableSpell(i)
        if i % 50000 == 0 then
            LM.Print(i)
            coroutine.yield()
        end
        i = i + 1
    end
end

function LM.Developer:CompareUsability()
    for i = 1, #self.usableOnSurface do
        if self.usableOnSurface[i] ~= self.usableUnderWater[i] then
            LM.Print("Found a spell with a difference!")
            LM.Print(i .. ": " .. GetSpellInfo(i))
            LM.Print("")
        end
        if i % 50000 == 0 then
            LM.Print(i)
            coroutine.yield()
        end
    end
end

function LM.Developer:OnUpdate(elapsed)
    if not self.thread or coroutine.status(self.thread) == "dead" then
        self:SetScript("OnUpdate", nil)
    else
        coroutine.resume(self.thread)
    end
end

function LM.Developer:UpdateUsability()
    if GetMirrorTimerInfo(2) == "BREATH" then
        LM.Print("Updating underwater usability table.")
        wipe(self.usableUnderWater)
        self.thread = coroutine.create(
                    function ()
                        CoPartialUpdate(self.usableUnderWater)
                    end)
    elseif IsSwimming() then
        LM.Print("Updating on surface usability table.")
        wipe(self.usableOnSurface)
        self.thread = coroutine.create(
                    function ()
                        CoPartialUpdate(self.usableOnSurface)
                    end)
    else
        LM.Print("Comparing usability.")
        self.thread = coroutine.create(
                    function ()
                        self:CompareUsability()
                    end)
    end

    self:SetScript("OnUpdate", self.OnUpdate)
end

function LM.Developer:Profile(n)
    self.profileCount = self.profileCount or 0
    if n == nil then
        LM.Print("Profile count = " .. self.profileCount)
    elseif n == 0 then
        self.profileCount = 0
    else
        self.profileCount = self.profileCount + n
    end
end
