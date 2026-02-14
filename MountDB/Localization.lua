--[[----------------------------------------------------------------------------

  LiteMount/MountDB/Localize.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local LMDB = LibStub("LibMountDB-1.0")

-- Vim reformatter from curseforge "Global Strings" export.
-- %s/^\(L\..*\) = \(.*\)/\=printf('%-24s= %s', submatch(1), submatch(2))/

LMDB.L = setmetatable({ }, {__index=function (t,k) return k end})

local locale = GetLocale()

-- enUS / enGB / Default -------------------------------------------------------

--@localization(locale="enUS", format="lua_additive_table", table-name="LMDB.L", handle-unlocalized=ignore, namespace="Family" )@

-- deDE ------------------------------------------------------------------------

if locale == "deDE" then
--@localization(locale="deDE", format="lua_additive_table", table-name="LMDB.L", handle-unlocalized=ignore, namespace="Family" )@
end

-- esES ------------------------------------------------------------------------

if locale == "esES" then
--@localization(locale="esES", format="lua_additive_table", table-name="LMDB.L", handle-unlocalized=ignore, namespace="Family" )@
end

-- esMX ------------------------------------------------------------------------

if locale == "esMX" then
--@localization(locale="esMX", format="lua_additive_table", table-name="LMDB.L", handle-unlocalized=ignore, namespace="Family" )@
end

-- frFR ------------------------------------------------------------------------

if locale == "frFR" then
--@localization(locale="frFR", format="lua_additive_table", table-name="LMDB.L", handle-unlocalized=ignore, namespace="Family" )@
end

-- itIT ------------------------------------------------------------------------

if locale == "itIT" then
--@localization(locale="itIT", format="lua_additive_table", table-name="LMDB.L", handle-unlocalized=ignore, namespace="Family" )@
end

-- koKR ------------------------------------------------------------------------

if locale == "koKR" then
--@localization(locale="koKR", format="lua_additive_table", table-name="LMDB.L", handle-unlocalized=ignore, namespace="Family" )@
end

-- ptBR ------------------------------------------------------------------------

if locale == "ptBR" then
--@localization(locale="ptBR", format="lua_additive_table", table-name="LMDB.L", handle-unlocalized=ignore, namespace="Family" )@
end

-- ruRU ------------------------------------------------------------------------

if locale == "ruRU" then
--@localization(locale="ruRU", format="lua_additive_table", table-name="LMDB.L", handle-unlocalized=ignore, namespace="Family" )@
end

-- zhCN ------------------------------------------------------------------------

if locale == "zhCN" then
--@localization(locale="zhCN", format="lua_additive_table", table-name="LMDB.L", handle-unlocalized=ignore, namespace="Family" )@
end

-- zhTW ------------------------------------------------------------------------

if locale == "zhTW" then
--@localization(locale="zhTW", format="lua_additive_table", table-name="LMDB.L", handle-unlocalized=ignore, namespace="Family" )@
end
