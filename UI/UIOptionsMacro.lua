--[[----------------------------------------------------------------------------

  LiteMount/UIOptionsMacro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011,2012 Mike Battersby

----------------------------------------------------------------------------]]--

local NUM_SUGGESTION_BUTTONS = 4

local ClassSuggestions = {
    ["HUNTER"] = {
        {
            ["iconspell"] = 5118,
            ["macro"] = "/cast !Aspect of the Cheetah",
        },
    },
    ["MAGE"] = {
        {
            ["iconspell"] = 1953,
            ["macro"] = "/cast Blink",
        },
        {
            ["iconspell"] = 130,
            ["macro"] = "/cast [@player] Slow Fall",
        },
    },
    ["PRIEST"] = {
        {
            ["iconspell"] = 1706,
            ["macro"] = "/cast [@player] Levitate",
        },
    },
    ["ROGUE"] = {
        {
            ["iconspell"] = 2983,
            ["macro"] = "/cast Sprint",
        },
    },
    ["WARLOCK"] = {
        {
            ["iconspell"] = 48020,
            ["macro"] = "/cast Demonic Circle: Teleport",
        },
    },
}

local RaceSuggestions = {
    ["Worgen"] = {
        {
            ["iconspell"] = 68992,
            ["macro"] = "/cast Darkflight",
        },
    },
}

local ProfessionSuggestions = {
    [202] = {   -- Engineering
        {
            ["iconspell"] = 55002,
            ["macro"] = "# Cloak (Flexweave Underlay)\n/use 15",
        },
        {
            ["iconspell"] = 55002,
            ["macro"] = "# Belt (Hyperspeed Accelerators)\n/use 6",
        },
    },
}

local function GetSuggestions()
    local suggestions = { }

    local class = select(2, UnitClass("player"))
    if ClassSuggestions[class] then
        for _,s in ipairs(ClassSuggestions[class]) do
            table.insert(suggestions, s)
        end
    end

    local race = select(2, UnitRace("player"))
    if RaceSuggestions[race] then
        for _,s in ipairs(RaceSuggestions[race]) do
            table.insert(suggestions, s)
        end
    end

    local pindex1, pindex2 = GetProfessions()
    for _, pindex in ipairs({pindex1, pindex2}) do
        local skillLine = select(7, GetProfessionInfo(pindex))
        if ProfessionSuggestions[skillLine] then
            for _,s in ipairs(ProfessionSuggestions[skillLine]) do
                table.insert(suggestions, s)
            end
        end
    end

    return suggestions
end

local function SetSuggestion(button, s)
    if s then
        SetItemButtonTexture(button, select(3, GetSpellInfo(s.iconspell)))
        button.macro = s.macro
        button.tooltip = s.macro
        button:Show()
    else
        button.macro = nil
        button.tooltip = nil
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
        LiteMountOptionsMacroEditBox:SetText(self.macro)
    end
end

function LiteMountOptionsMacro_OnLoad(self)

    LiteMount_Frame_AutoLocalize(self)

    self.parent = LiteMountOptions.name
    self.name = MACRO .. " : " .. UNAVAILABLE
    self.title:SetText("LiteMount : " .. self.name)

    self.default = function ()
            LM_Options:SetMacro(nil)
        end

    InterfaceOptions_AddCategory(self)
end

function LiteMountOptionsMacro_OnShow(self)
    LiteMountOptions.CurrentOptionsPanel = self
    local m = LM_Options:GetMacro()
    if m then
        LiteMountOptionsMacroEditBox:SetText(m)
    end
    UpdateSuggestionButtons()
end

function LiteMountOptionsMacro_OnTextChanged(self)
    local m = LiteMountOptionsMacroEditBox:GetText()
    if not m or string.match(m, "^%s*$") then
        LM_Options:SetMacro(nil)
    else
        LM_Options:SetMacro(m)
    end

    local c = string.len(m or "")
    LiteMountOptionsMacroCount:SetText(string.format(MACROFRAME_CHAR_LIMIT, c))
end

