--[[----------------------------------------------------------------------------

  LiteMount/KeyBindingStrings.lua

  Texts for keybindings menu entries.

  Copyright 2011-2015 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

BINDING_HEADER_LITEMOUNT_TITLE = GetAddOnMetadata("LiteMount", "Title")
_G["BINDING_NAME_CLICK LiteMountActionButton1:LeftButton"] = MOUNT .. " / " .. BINDING_NAME_DISMOUNT
_G["BINDING_NAME_CLICK LiteMountActionButton2:LeftButton"] = L["Non-flying Mount"] .. " / " .. BINDING_NAME_DISMOUNT
_G["BINDING_NAME_CLICK LiteMountActionButton3:LeftButton"] = format("%s %s 1 / %s", MOUNT, CUSTOM, BINDING_NAME_DISMOUNT)
_G["BINDING_NAME_CLICK LiteMountActionButton4:LeftButton"] = format("%s %s 2 / %s", MOUNT, CUSTOM, BINDING_NAME_DISMOUNT)
