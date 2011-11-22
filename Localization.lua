--[[----------------------------------------------------------------------------

  LiteMount/Localization.lua

  LiteMount translations into other languages.

----------------------------------------------------------------------------]]--

LM_Localize = setmetatable({ }, {__index=function (t,k) return k end})

local L = LM_Localize

-- Default locale is enUS

if GetLocale() == "frFR" then
elseif GetLocale() == "deDE" then
elseif GetLocale() == "koKR" then
elseif GetLocale() == "zhCN" then
elseif GetLocale() == "zhTW" then
    L["Run"]    = "跑"
    L["Fly"]    = "飞"
    L["Swim"]   = "游"
    L["AQ"]     = "AQL"
    L["Vashj"]  = "海"
elseif GetLocale() == "ruRU" then
elseif GetLocale() == "esES" then
elseif GetLocale() == "esMX" then
end
