--[[----------------------------------------------------------------------------

  LiteMount/UI/ReportBug.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.L

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
    ScrollUtil.RegisterScrollBoxWithScrollBar(self.Scroll.ScrollBox, self.ScrollBar)
end

local function GetAnyLiteMountMacros()
    local macros = ''
    for i = 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS do
        local name, _, body = GetMacroInfo(i)
        if name and body:match("/click.*LM_") then
            macros = macros .. format("%s:\n    %s\n", name, body:gsub("\n", "\n    "))
        end
    end
    return macros
end

-- Add a break between activations by looking for PreClick handler
local function GetSplitDebugLines()
    local lines = LM.GetDebugLines()
    for i = #lines, 2, -1 do
        if lines[i]:find('PreClick handler') then
            table.insert(lines, i, '')
        end
    end
    return lines
end

function LiteMountReportBugMixin:OnShow()
    local savedDefaults = LM.db.defaults
    LM.db:RegisterDefaults(nil)
    local sv = CopyTable(LM.db.sv)
    LM.db:RegisterDefaults(savedDefaults)

    local data = LibDeflate:EncodeForPrint(
                    LibDeflate:CompressDeflate(
                        Serializer:Serialize(sv) ) )

    local _, race = UnitRace('player')
    local _, class = UnitClass('player')
    local level = UnitLevel('player')
    local spec = GetSpecialization and GetSpecialization() or 0
    local specID, specName = GetSpecializationInfo and GetSpecializationInfo(spec) or 0, 0

    local macros = GetAnyLiteMountMacros()

    self.Scroll:SetText([[
|cff00ff00Have you checked https://github.com/xod-wow/LiteMount/releases and have the latest version.|r

No (you should change this to yes when you have checked).


|cff00ff00What is the issue?|r


|cff00ff00Describe how to trigger the issue (if applicable).|r


|cff00ff00Did it work in a previous version of LiteMount? If so, what was the last version that worked?|r


|cff00ff00Please trigger the error before capturing and reporting this issue.

Do not modify anything below this line.|r
|cff777777
]] ..
        "--- General ---\n" ..
        "\n" ..
        string.format("date: %s\n", date()) ..
        string.format("expansion: %s\n", _G['EXPANSION_NAME'..EXPANSION_LEVEL]) ..
        string.format("build: %s\n", strjoin(' | ', GetBuildInfo())) ..
        string.format("version: %s\n", C_AddOns.GetAddOnMetadata('LiteMount', 'version')) ..
        string.format("locale: %s\n", GetLocale()) ..
        string.format("current profile: %s\n", LM.db:GetCurrentProfile()) ..
        "\n" ..
        "--- Player ---\n" ..
        "\n" ..
        string.format("name: %s-%s\n", UnitFullName('player')) ..
        string.format("class: %s\n", class) ..
        string.format("level: %s\n", level) ..
        string.format("race: %s\n", race) ..
        string.format("faction: %s\n", UnitFactionGroup('player')) ..
        string.format("spec: %d %d %s\n", spec, specID, specName or "") ..
        "\n" ..
        "--- Location ---\n" ..
        "\n" ..
        table.concat(LM.Environment:GetLocation(), "\n") ..  "\n" ..
        "\n" ..
        "--- Macros ---\n" ..
        "\n```\n" ..
        macros ..
        "```\n\n" ..
        "--- Debugging Output ---\n" ..
        "\n```\n" ..
        table.concat(GetSplitDebugLines(), "\n") .. "\n" ..
        "```\n\n" ..
        "--- Options DB ---\n" ..
        "\n" ..
         linefold(data, 80)
    )
    self.Scroll:SetCursorPosition(0)
end
