--[[----------------------------------------------------------------------------

  LiteMount/UI/ReportBug.lua

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local Serializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

local function linefold(str, n)
    local out = ''
    for i = 1, str:len(), n do
        out = out .. str:sub(i, i+n-1) .. "\n"
    end
    return out
end

LiteMountReportBugMixin = {}

function LiteMountReportBugMixin:OnLoad()
    self.name = L.LM_REPORT_BUG
end

function LiteMountReportBugMixin:OnSizeChanged()
    local x, y = self.Scroll:GetSize()
    self.Scroll.EditBox:SetSize(x-28, y)
end

function LiteMountReportBugMixin:OnShow()
    local savedDefaults = LM.Options.db.defaults
    LM.Options.db:RegisterDefaults(nil)
    local sv = CopyTable(LM.Options.db.sv)
    LM.Options.db:RegisterDefaults(savedDefaults)

    local data = LibDeflate:EncodeForPrint(
                    LibDeflate:CompressDeflate(
                        Serializer:Serialize(sv) ) )

    local _, race = UnitRace('player')
    local _, class = UnitClass('player')
    local level = UnitLevel('player')
    local spec = GetSpecialization()
    local specID, specName = GetSpecializationInfo(spec)

    self.Scroll.EditBox:SetText([[
|cff00ff00What happens?|r


|cff00ff00What did you expect to happen instead?|r


|cff00ff00Did it work in a previous version of LiteMount? If so, what was the last version that worked?|r


|cffffaa00Please do not modify anything below this line.|r
|cff777777
]] ..
        "--- General ---\n" ..
        "\n" ..
        string.format("date: %s\n", date()) ..
        string.format("version: %s\n", GetAddOnMetadata('LiteMount', 'version')) ..
        string.format("locale: %s\n", GetLocale()) ..
        string.format("current profile: %s\n", LM.Options.db:GetCurrentProfile()) ..
        "\n" ..
        "--- Player ---\n" ..
        "\n" ..
        string.format("name: %s-%s\n", UnitFullName('player')) ..
        string.format("class: %s\n", class) ..
        string.format("level: %s\n", level) ..
        string.format("race: %s\n", race) ..
        string.format("faction: %s\n", UnitFactionGroup('player')) ..
        string.format("spec: %d %d %s\n", spec, specID, specName) ..
        "\n" ..
        "--- Location ---\n" ..
        "\n" ..
        table.concat(LM.Environment:GetLocation(), "\n") ..  "\n" ..
        "\n" ..
        "--- Debugging Output ---\n" ..
        "\n" ..
        table.concat(LM.GetDebugLines(), "\n") .. "\n" ..
        "\n" ..
        "--- Options DB ---\n" ..
        "\n" ..
         linefold(data, 80)
    )
    self.Scroll.EditBox:SetCursorPosition(0)
end
