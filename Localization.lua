--[[----------------------------------------------------------------------------

  LiteMount/Localization.lua

  LiteMount translations into other languages.

----------------------------------------------------------------------------]]--

LM_Localize = setmetatable({ }, {__index=function (t,k) return k end})

local L = LM_Localize

local locale = GetLocale()

if locale == "enUS" then
    -- Default locale is enUS
elseif locale == "frFR" then
elseif locale == "deDE" then
elseif locale == "koKR" then
elseif locale == "zhCN" then
    L["Author"]  = "Author"
    L["Version"] = "Version"
    L["Run"]     = "跑"
    L["Fly"]     = "飞"
    L["Swim"]    = "游"
    L["AQ"]      = "AQL"
    L["Vash"]    = "海"
elseif locale == "zhTW" then
    L["Author"]  = "Author"
    L["Version"] = "Version"
    L["Run"]     = "跑"
    L["Fly"]     = "飞"
    L["Swim"]    = "游"
    L["AQ"]      = "AQL"
    L["Vash"]    = "海"
elseif locale == "ruRU" then
elseif locale == "esES" then
elseif locale == "esMX" then
end
