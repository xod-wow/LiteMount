--[[----------------------------------------------------------------------------

  LiteMount/Localization.lua

  LiteMount translations into other languages.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

-- Vim reformatter from curseforge "Global Strings" export.
-- %s/^\(L\..*\) = \(.*\)/\=printf('%-24s= %s', submatch(1), submatch(2))/

LM.Localize = setmetatable({ }, {__index=function (t,k) return k end})

local L = LM.Localize

local locale = GetLocale()

-- Automatic / Blizzard --------------------------------------------------------

L.FAVORITES             = FAVORITES
L.LM_PRIORITY_DESC0     = DISABLE
L.LM_PRIORITY_DESC4     = ALWAYS
L.Unknown               = UNKNOWN
L.RIDEALONG             = MOUNT_JOURNAL_FILTER_RIDEALONG
L.DRAGONRIDING          = MOUNT_JOURNAL_FILTER_DRAGONRIDING
L.SKYRIDING             = MOUNT_JOURNAL_FILTER_DRAGONRIDING
L.FLY                   = MOUNT_JOURNAL_FILTER_FLYING
L.RUN                   = MOUNT_JOURNAL_FILTER_GROUND
L.SWIM                  = MOUNT_JOURNAL_FILTER_AQUATIC
L.DRIVE                 = ACCESSIBILITY_DRIVE_LABEL


-- enUS / enGB / Default -------------------------------------------------------

L = L or {}
L["LM_ACTION"] = "Action"
L["LM_ACTION_MENU_TITLE"] = "Actions on currently filtered mounts"
L["LM_ACTIONS"] = "Actions"
L["LM_ADD_MOUNTS_AT_PRIORITY_0"] = "When Blizzard adds a new mount, set it to priority 0 (disabled)."
L["LM_ADD_SPELL_OR_ITEM"] = "Add a spell or item to use"
L["LM_ADVANCED_EXP"] = "These settings allow you to customize the actions run by each of the LiteMount key bindings. Please read the documentation at the URL below before changing anything."
L["LM_ANNOUNCE_FLIGHT_STYLE"] = "Announce flight style switches."
L["LM_ANNOUNCE_MOUNTS"] = "Announce summoned mounts in:"
L["LM_AREA_FMT_S"] = "%s area"
L["LM_AUTHOR"] = "Author"
L["LM_CHANGE_PROFILE"] = "Change Profile"
L["LM_COLOR_BY_PRIORITY"] = "Color by priority"
L["LM_COMBAT_MACRO_EXP"] = "If enabled, this macro will be run instead of the default combat actions if LiteMount is activated while you are combat."
L["LM_CONDITIONS"] = "Conditions"
L["LM_COPY_TARGETS_MOUNT"] = "Try to copy target's mount."
L["LM_COVENANT"] = "Covenant"
L["LM_CREATE_GLOBAL_GROUP"] = "Global"
L["LM_CREATE_PROFILE_GROUP"] = "Profile"
L["LM_CURRENT_PROFILE"] = "Current Profile"
L["LM_CURRENT_SETTINGS"] = "Current Settings"
L["LM_DEBUGGING_DISABLED"] = "Debugging disabled."
L["LM_DEBUGGING_ENABLED"] = "Debugging enabled."
L["LM_DEFAULT_SETTINGS"] = "Default Settings"
L["LM_DELETE_FLAG"] = "Delete Flag"
L["LM_DELETE_GROUP"] = "Delete Group"
L["LM_DELETE_PROFILE"] = "Delete Profile"
L["LM_DISABLING_MOUNT"] = "Disabling active mount: %s"
L["LM_DRAG_TO_REORDER"] = "Drag to reorder"
L["LM_EDIT_RULE"] = "Edit Rule"
L["LM_ENABLE_DEBUGGING"] = "Enable debugging messages."
L["LM_ENABLING_MOUNT"] = "Enabling active mount: %s"
L["LM_EQUIPMENT_SLOT"] = "Equipment Slot"
L["LM_ERR_ALL_MOUNTS_DISABLED"] = "Can't mount because all matching mounts are disabled."
L["LM_ERR_BAD_ACTION"] = "Invalid action '%s'"
L["LM_ERR_BAD_ARGUMENTS"] = "Invalid arguments '%s'"
L["LM_ERR_BAD_CONDITION"] = "Invalid conditions '%s'"
L["LM_ERR_BAD_RULE"] = "Invalid rule '%s': %s"
L["LM_EVERY_D_MINUTES"] = "Every %d minutes"
L["LM_EVERY_D_SECONDS"] = "Every %d seconds"
L["LM_EVERY_TIME"] = "Every time"
L["LM_EXCLUDE_MOUNTS"] = "Exclude Mounts"
L["LM_EXPORT_PROFILE"] = "Export Profile"
L["LM_EXPORT_PROFILE_EXP"] = "Cut-and-paste the text below into a file to save this profile. You can restore it again with 'Import Profile'."
L["LM_FALLING_EXP"] = "If you are falling LiteMount will try to use these spells and items to save you. The first one that is usable will be activated."
L["LM_FAMILY"] = "Family"
L["LM_FLAG"] = "Flag"
L["LM_FLAGS"] = "Flags"
L["LM_FLIGHT_STYLE"] = "Flight Style"
L["LM_FRIEND_IN_GROUP"] = "Friend in group"
L["LM_GATHERED_RECENTLY"] = "Gathered recently"
L["LM_GROUND"] = "Ground"
L["LM_GROUP"] = "Group"
L["LM_GROUPS"] = "Groups"
L["LM_GROUPS_EXP"] = "Here you can manage groups of mounts, which can be used in the Rules and Advanced settings."
L["LM_HELP_TRANSLATE"] = "Help translate LiteMount into your language. Thank you."
L["LM_HERB"] = "Herb"
L["LM_HIDDEN"] = "Hidden"
L["LM_HOLIDAY"] = "Holiday"
L["LM_IMPORT_PROFILE"] = "Import Profile"
L["LM_IMPORT_PROFILE_EXP"] = "Paste a previously exported profile into the box below to import it as the entered name."
L["LM_INCLUDE_MOUNTS"] = "Include Mounts"
L["LM_INSTANT_ONLY_MOVING"] = "Don't summon instant-cast mounts unless moving."
L["LM_ITEM_EQUIPPED"] = "Equipped"
L["LM_LEFT_CLICK"] = "Left Click"
L["LM_LIMIT_MOUNTS"] = "Limit Mounts"
L["LM_LIMITEXCLUDE_DESCRIPTION"] = "Remove the specified mounts from the set available to later actions."
L["LM_LIMITINCLUDE_DESCRIPTION"] = "Add the specified mounts to the set available to later actions."
L["LM_LIMITSET_DESCRIPTION"] = "Limit the available mounts for all later actions to those specified."
L["LM_LIST_VIEW"] = "List View"
L["LM_MACRO_EXP"] = "This macro will be run if LiteMount is unable to find a usable mount. This might be because you are indoors, or are moving and don't know any instant-cast mounts."
L["LM_MACRO_NOT_ALLOWED"] = "This setting does not work when activating LiteMount using a macro on an action bar. This is due to Blizzard preventing macros from calling other macros."
L["LM_MODEL_VIEW"] = "Model View"
L["LM_MODIFIER_KEY"] = "Modifier key"
L["LM_MOUNT_ACTION"] = "Random Mount"
L["LM_MOUNT_DESCRIPTION"] = "Summon a random mount."
L["LM_MOUNTED"] = "Mounted"
L["LM_MOUNTSPECIAL_TIMER"] = "Automatically run %s when idle"
L["LM_MOUSE_BUTTON_CLICKED"] = "Mouse button clicked"
L["LM_NEW_FLAG"] = "New Flag"
L["LM_NEW_GROUP"] = "New Group"
L["LM_NEW_PROFILE"] = "New Profile"
L["LM_NOT"] = "NOT"
L["LM_NOT_FORMAT"] = "Not %s"
L["LM_ON_SCREEN_DISPLAY"] = "On-Screen Display"
L["LM_ORE"] = "Ore"
L["LM_PARTY_OR_RAID_GROUP"] = "In a party or raid group"
L["LM_PRECAST_ACTION"] = "Cast Spell Before Mounting"
L["LM_PRECAST_DESCRIPTION"] = "Register a spell to try to cast before mounting. Enter a spell name or spell ID. Only cast before journal mounts, and the spell must have no cast time."
L["LM_PREUSE_ACTION"] = "Use Item Before Mounting"
L["LM_PREUSE_DESCRIPTION"] = "Register an item to try use before mounting. Enter an item name, item ID or equipment slot number. Only used before journal mounts. The item should have no cast time."
L["LM_PRIORITY"] = "Priority"
L["LM_PRIORITY_DESC1"] = "Normal"
L["LM_PRIORITY_DESC2"] = "More often"
L["LM_PRIORITY_DESC3"] = "A lot more often"
L["LM_PRIORITYMOUNT_ACTION"] = "Priority Mount"
L["LM_PRIORITYMOUNT_DESCRIPTION"] = "Summon a random mount. Uses the priorities/rarities for summoning mounts more or less often (or never)."
L["LM_PROFILES"] = "Profiles"
L["LM_PROFILES_EXP"] = "Profiles are different configurations that you can switch between. Each of your characters has its own selected profile. All settings except the Combat and Unavailable macros are saved in the profile and change when switching profiles."
L["LM_RANDOM_PERSISTENCE"] = "How often to select a new random mount"
L["LM_RARITY"] = "Rarity"
L["LM_RARITY_DATA_INFO"] = "Rarity data (how many accounts have collected each mount) is provided by DataForAzeroth and updated each time a LiteMount version is released. For more frequently updated data please also install the MountsRarity AddOn."
L["LM_RARITY_DISABLES_PRIORITY"] = "Priorities other than 0 (disabled) are inactive because summon by rarity has been selected in the General settings."
L["LM_RARITY_FORMAT"] = "%0.1f%%"
L["LM_RARITY_FORMAT_LONG"] = "Collected by %0.1f%% of WoW accounts."
L["LM_RENAME_FLAG"] = "Rename Flag"
L["LM_RENAME_GROUP"] = "Rename Group"
L["LM_REPORT_BUG"] = "Report Bug"
L["LM_REPORT_BUG_EXP"] = "To report a bug in LiteMount, please describe the bug at the top of the field below, then cut-and-paste the entire text into the Create Issue form at this URL:"
L["LM_RESET_PROFILE"] = "Reset Profile"
L["LM_RESTORE_FORMS"] = "Try to restore druid shapeshift forms when dismounting."
L["LM_RIGHT_CLICK"] = "Right Click"
L["LM_RULES_EXP"] = "Rules for mounting. Each rule has up to 3 conditions and an action. Rules are checked in order, and if all conditions match the action is applied."
L["LM_RULES_INACTIVE"] = "Rules for key binding %d are inactive because your custom action list (in Advanced Options) does not contain the 'ApplyRules' action."
L["LM_SEASON"] = "Season"
L["LM_SEASON_FALL"] = "Fall"
L["LM_SEASON_SPRING"] = "Spring"
L["LM_SEASON_SUMMER"] = "Summer"
L["LM_SEASON_WINTER"] = "Winter"
L["LM_SET_DEFAULT_MOUNT_PRIORITY_TO"] = "Set default mount priority to %d (%s) instead of %d (%s)."
L["LM_SETTINGS_TAGLINE"] = "Simple and reliable random mount summoning."
L["LM_SEX"] = "Sex"
L["LM_SHOW_ALL_MOUNTS"] = "Show all mounts"
L["LM_SMARTMOUNT_ACTION"] = "Smart Priority Mount"
L["LM_SMARTMOUNT_DESCRIPTION"] = "Summon a random mount of the best available type for the current situation. Uses the priorities/rarities for summoning mounts more or less often (or never)."
L["LM_SPELL_ACTION"] = "Cast Spell"
L["LM_SPELL_DESCRIPTION"] = "Cast a spell. Enter either a spell name or a spell ID."
L["LM_SPELL_KNOWN"] = "Spell known"
L["LM_STEADY_FLIGHT"] = "Steady Flight"
L["LM_SUMMON_CHAT_MESSAGE"] = "%s (Priority: %d, Summons: %d)"
L["LM_SUMMON_CHAT_MESSAGE_RARITY"] = "%s (Rarity: %s, Summons: %d)"
L["LM_SUMMON_STYLE"] = "How to choose a random mount"
L["LM_SUMMON_STYLE_LEASTUSED"] = "Summon mounts you have used the least"
L["LM_SUMMON_STYLE_PRIORITY"] = "Use the manually set mount priorities"
L["LM_SUMMON_STYLE_RARITY"] = "Summon rare (fewer players know them) mounts more often"
L["LM_TOGGLE"] = "Toggle"
L["LM_TRANSLATORS"] = "Translators"
L["LM_USABLE"] = "Usable"
L["LM_USAGE"] = "Usage"
L["LM_USE_ACTION"] = "Use Item"
L["LM_USE_DESCRIPTION"] = "Use an item. Enter an item name, item ID, or an equipment slot number."
L["LM_USE_FLYING_AS_GROUND"] = "Also use this flying mount as a ground mount"
L["LM_USE_RARITY_WEIGHTS"] = "Summon mounts more or less often based on their rarity (instead of priority)."
L["LM_WARN_REPLACE_COND"] = "The [%s] action list condition has been replaced by [%s] due to Blizzard changes."
L["LM_ZONEMATCH"] = "From current zone"

-- deDE ------------------------------------------------------------------------

if locale == "deDE" then
--@localization(locale="deDE", format="lua_additive_table", handle-unlocalized=ignore )@
end

-- esES ------------------------------------------------------------------------

if locale == "esES" then
--@localization(locale="esES", format="lua_additive_table", handle-unlocalized=ignore )@
end

-- esMX ------------------------------------------------------------------------

if locale == "esMX" then
--@localization(locale="esMX", format="lua_additive_table", handle-unlocalized=ignore )@
end

-- frFR ------------------------------------------------------------------------

if locale == "frFR" then
--@localization(locale="frFR", format="lua_additive_table", handle-unlocalized=ignore )@
end

-- itIT ------------------------------------------------------------------------

if locale == "itIT" then
--@localization(locale="itIT", format="lua_additive_table", handle-unlocalized=ignore )@
end

-- koKR ------------------------------------------------------------------------

if locale == "koKR" then
--@localization(locale="koKR", format="lua_additive_table", handle-unlocalized=ignore )@
end

-- ptBR ------------------------------------------------------------------------

if locale == "ptBR" then
--@localization(locale="ptBR", format="lua_additive_table", handle-unlocalized=ignore )@
end

-- ruRU ------------------------------------------------------------------------

if locale == "ruRU" then
--@localization(locale="ruRU", format="lua_additive_table", handle-unlocalized=ignore )@
end

-- zhCN ------------------------------------------------------------------------

if locale == "zhCN" then
--@localization(locale="zhCN", format="lua_additive_table", handle-unlocalized=ignore )@
end

-- zhTW ------------------------------------------------------------------------

if locale == "zhTW" then
--@localization(locale="zhTW", format="lua_additive_table", handle-unlocalized=ignore )@
end
