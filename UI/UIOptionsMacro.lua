--[[----------------------------------------------------------------------------

  LiteMount/UIOptionsMacro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

local NUM_SUGGESTION_BUTTONS = 4

local ClassSuggestions = {
    ["DEMONHUNTER"] = {
        {
            ["iconspell"] = 195072,                 -- Fel Rush
        },
    },
    ["DRUID"] = {
        {
            ["iconspell"] = 1850,                   -- Dash
            ["macro"] = "/cast [form:2] {name}",
        },
        {
            ["iconspell"] = 106898,                 -- Stampeding Roar
        },
    },
    ["HUNTER"] = {
        {
            ["iconspell"] = 5118,                   -- Aspect of the Cheetah
        },
    },
    ["MAGE"] = {
        {
            ["iconspell"] = 1953,                   -- Blink
        },
        {
            ["iconspell"] = 130,                    -- Slow Fall
            ["macro"] = "/cast [@player] {name}",
        },
    },
    ["MONK"] = {
        {
            ["iconspell"] = 116841,                 -- Tiger's Lust
            ["macro"] = "/cast [@player] {name}",
        },
        {
            ["iconspell"] = 125883,                 -- Zen Flight
        },
    },
    ["PALADIN"] = {
        {
            ["iconspell"] = 190784,                 -- Divine Steed
        },
    },
    ["PRIEST"] = {
        {
            ["iconspell"] = 1706,                   -- Levitate
            ["macro"] = "/cast [@player] {name}",
        },
    },
    ["ROGUE"] = {
        {
            ["iconspell"] = 2983,                   -- Sprint
        },
    },
    ["SHAMAN"] = {
        {
            ["iconspell"] = 58875,                  -- Spirit Walk
        },
    },
    ["WARLOCK"] = {
        {
            ["iconspell"] = 111400,                 -- Burning Rush
        },
        {
            ["iconspell"] = 48020,                  -- Demonic Circle: Teleport
        },
    },
    ["WARRIOR"] = {
    },
}

local RaceSuggestions = {
    ["Worgen"] = {
        {
            ["iconspell"] = 68992,
        },
    },
}

local ProfessionSuggestions = {
    [202] = {   -- Engineering
        {
            ["iconspell"] = 55002,
            ["macro"] = "# Cloak (Flexweave Underlay/Goblin Glider)\n/use 15",
        },
        {
            ["iconspell"] = 55002,
            ["macro"] = "# Belt (Hyperspeed Accelerators/Watergliding Jets)\n/use 6",
        },
    },
}

local function GetSuggestions()
    local suggestions = { }

    local class = select(2, UnitClass("player"))
    if ClassSuggestions[class] then
        for _,s in ipairs(ClassSuggestions[class]) do
            if IsSpellKnown(s.iconspell) then
                tinsert(suggestions, s)
            end
        end
    end

    local race = select(2, UnitRace("player"))
    if RaceSuggestions[race] then
        for _,s in ipairs(RaceSuggestions[race]) do
            tinsert(suggestions, s)
        end
    end

    local pindex1, pindex2 = GetProfessions()
    for _, pindex in ipairs({pindex1, pindex2}) do
        local skillLine = select(7, GetProfessionInfo(pindex))
        if ProfessionSuggestions[skillLine] then
            for _,s in ipairs(ProfessionSuggestions[skillLine]) do
                tinsert(suggestions, s)
            end
        end
    end

    return suggestions
end

local function SetSuggestion(button, s)
    if s then
        local name, _, texture = GetSpellInfo(s.iconspell)
        SetItemButtonTexture(button, texture)
        if s.macro then
            button.macro = gsub(s.macro, "{name}",  name) .. "\n"
        else
            button.macro = "/cast " .. name .. "\n";
        end
        button.tooltipText = button.macro
        button:Show()
    else
        button.macro = nil
        button.tooltipText = nil
        button:Hide()
    end
end

local function UpdateSuggestionButtons()
    local suggestions = GetSuggestions()

    for i = 1, NUM_SUGGESTION_BUTTONS do
        local b = _G["LiteMountOptionsMacroSuggest"..i]
        SetSuggestion(b, suggestions[i])
    end
end

function LiteMountOptionsMacroSuggest_OnClick(self)
    if self.macro then
        local t = LiteMountOptionsMacroEditBox:GetText() or ""
        t = t .. self.macro
        LiteMountOptionsMacroEditBox:SetText(t)
    end
end

function LiteMountOptionsMacro_OnLoad(self)
    self.name = MACRO .. " : " .. UNAVAILABLE
    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountOptionsMacro_OnShow(self)
    UpdateSuggestionButtons()
    LiteMountOptionsPanel_OnShow(self)
end

function LiteMountOptionsMacro_OnTextChanged(self)
    local c = strlen(self:GetText() or "")
    LiteMountOptionsMacroCount:SetText(format(MACROFRAME_CHAR_LIMIT, c))
end

