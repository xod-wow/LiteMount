--[[----------------------------------------------------------------------------

  LiteMount/Localization.lua

  LiteMount translations into other languages.

  Copyright 2011,2012 Mike Battersby

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
    L["Non-flying Mount"] = "非飞行坐骑"
    L["Author"]  = "作者"
    L["Version"] = "版本"
    L["Run"]     = "跑"
    L["Fly"]     = "飞"
    L["Swim"]    = "游"
    L["AQ"]      = "AQL"
    L["Vash"]    = "海"
elseif locale == "zhTW" then
    L["Non-flying Mount"] = "非飞行坐骑"
    L["Author"]  = "作者"
    L["Version"] = "版本"
    L["Run"]     = "跑"
    L["Fly"]     = "飞"
    L["Swim"]    = "游"
    L["AQ"]      = "AQL"
    L["Vash"]    = "海"
elseif locale == "ruRU" then
elseif locale == "esES" then
elseif locale == "esMX" then
end
