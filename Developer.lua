--[[----------------------------------------------------------------------------

  LiteMount/Developer.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

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
        t[i] = C_Spell.IsSpellUsable(i)
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
            LM.Print(i .. ": " .. C_Spell.GetSpellName(i))
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

function LM.Developer:ExportMockData()
    LiteMountDB.data = table.wipe(LiteMountDB.data or {})
    local data = LiteMountDB.data

    data.GetMountInfoByID = {}
    data.GetMountInfoExtraByID = {}
    data.GetSpellInfo = {}

    for name, spellID in pairs(LM.SPELL) do
        data.GetSpellInfo[spellID] = C_Spell.GetSpellInfo(spellID)
    end

    for _,mountID in ipairs(C_MountJournal.GetMountIDs()) do
        data.GetMountInfoByID[mountID] = { C_MountJournal.GetMountInfoByID(mountID) }
        data.GetMountInfoExtraByID[mountID] = { C_MountJournal.GetMountInfoExtraByID(mountID) }
        local spellID = select(2, C_MountJournal.GetMountInfoByID(mountID))
        data.GetSpellInfo[spellID] =  C_Spell.GetSpellInfo(spellID)
    end

    data.GetItemInfo = {}
    data.GetItemSpell = {}

    for name, itemID in pairs(LM.ITEM) do
        data.GetItemInfo[itemID] = { C_Item.GetItemInfo(itemID) }
        local spellName, spellID = C_Item.GetItemSpell(itemID)
        if spellName then
            data.GetItemSpell[itemID] = { spellName, spellID }
            data.GetSpellInfo[spellID] = C_Spell.GetSpellInfo(spellID)
        end
    end

    data.GetMapInfo = {}
    data.GetMapGroupID = {}
    data.IsMapValidForNavBarDropdown = {}

    for i = 1, 10000 do
        local info = C_Map.GetMapInfo(i)
        if info then
            data.GetMapInfo[i] = info
            data.GetMapGroupID[i] = C_Map.GetMapGroupID(i)
            if C_Map.IsMapValidForNavBarDropdown(i) then
                data.IsMapValidForNavBarDropdown[i] = true
            end
        end
    end

    data.GetClassInfo = {}

    local classIndex = 1
    while true do
        local info = { GetClassInfo(classIndex) }
        if info[1] then
            data.GetClassInfo[classIndex] = info
            classIndex = classIndex + 1
        else
            break
        end
    end

    data.GetRaceInfo = {}
    for i = 1, 100 do
        data.GetRaceInfo[i] = C_CreatureInfo.GetRaceInfo(i)
    end

    data.GlobalStrings = {}
    for k,v in pairs(_G) do
        if type(k) == 'string' and type(v) == 'string' then
            data.GlobalStrings[k] = v
        end
    end
end
