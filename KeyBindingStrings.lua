--[[----------------------------------------------------------------------------

  LiteMount/KeyBindingStrings.lua

  Texts for keybindings menu entries.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

BINDING_HEADER_LITEMOUNT_TITLE = GetAddOnMetadata("LiteMount", "Title")
_G["BINDING_NAME_CLICK LM_B1:LeftButton"] = MOUNT .. " / " .. BINDING_NAME_DISMOUNT
_G["BINDING_NAME_CLICK LM_B2:LeftButton"] = L["Non-flying Mount"] .. " / " .. BINDING_NAME_DISMOUNT
_G["BINDING_NAME_CLICK LM_B3:LeftButton"] = format("%s %s 1 / %s", MOUNT, CUSTOM, BINDING_NAME_DISMOUNT)
_G["BINDING_NAME_CLICK LM_B4:LeftButton"] = format("%s %s 2 / %s", MOUNT, CUSTOM, BINDING_NAME_DISMOUNT)
