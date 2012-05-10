--[[----------------------------------------------------------------------------

  LiteMount/Localization.lua

  LiteMount translations into other languages.

  Copyright 2011,2012 Mike Battersby

----------------------------------------------------------------------------]]--

LM_Localize = setmetatable({ }, {__index=function (t,k) return k end})

local L = LM_Localize

local locale = GetLocale()

if locale == "enUS" or locale == "enGB" then
    -- Default locale is English
elseif locale == "deDE" then
    L["Author"]  = "Autor"
elseif locale == "esES" or locale == "esMX" then
    L["Author"]  = "Autor"
elseif locale == "frFR" then
    L["Author"]  = "Auteur"
elseif locale == "koKR" then
    L["Author"]  = "저자"
elseif locale == "ptBR" then
    L["Author"]  = "Autor"
elseif locale == "ruRU" then
    L["Author"]  = "Aвтор"
elseif locale == "zhCN" then
    L["Author"]  = "作者"
    L["Non-flying Mount"] = "非飞行坐骑"
    L["Run"]     = "跑"
    L["Fly"]     = "飞"
    L["Swim"]    = "游"
    L["AQ"]      = "AQL"
    L["Vash"]    = "瓦丝琪尔"
elseif locale == "zhTW" then
    L["Author"]  = "作者"
    L["Non-flying Mount"] = "非飞行坐骑"
    L["Run"]     = "跑"
    L["Fly"]     = "飛"
    L["Swim"]    = "游"
    L["AQ"]      = "AQL"
    L["Vash"]    = "瓦許伊爾"
end
