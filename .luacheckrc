exclude_files = {
    ".luacheckrc",
    "Tests/",
    "Libs/",
}

-- https://luacheck.readthedocs.io/en/stable/warnings.html

ignore = {
    "11./BINDING_.*", -- Setting an undefined (Keybinding) global variable
    "11./MOUNT_JOURNAL_FILTER_.*",
    "211", -- Unused local variable
    "212", -- Unused argument
    "213", -- Unused loop variable
    "432/self", -- Shadowing a local variable
    "542", -- empty if branch
    "631", -- line too long
}

globals = {
    "LiteMount",
    "LiteMountAdvancedEditBoxMixin",
    "LiteMountAdvancedEditScrollMixin",
    "LiteMountAdvancedPanel",
    "LiteMountAdvancedPanelMixin",
    "LiteMountAdvancedUnlockButtonMixin",
    "LiteMountAllPriorityMixin",
    "LiteMountAnnounceFrameMixin",
    "LiteMountBackupDB",
    "LiteMountCombatMacroEditBoxMixin",
    "LiteMountCombatMacroEnableButtonMixin",
    "LiteMountCombatMacroPanelMixin",
    "LiteMountDB",
    "LiteMountFilter",
    "LiteMountFilterButtonMixin",
    "LiteMountFilterClearMixin",
    "LiteMountFilterMixin",
    "LiteMountFlagBitMixin",
    "LiteMountGeneralPanelMixin",
    "LiteMountGroupsPanel",
    "LiteMountGroupsPanelGroupMixin",
    "LiteMountGroupsPanelGroupsMixin",
    "LiteMountGroupsPanelMixin",
    "LiteMountGroupsPanelMountMixin",
    "LiteMountGroupsPanelMountScrollMixin",
    "LiteMountMacroEditBoxMixin",
    "LiteMountMacroPanelMixin",
    "LiteMountMonoFont",
    "LiteMountMountButtonMixin",
    "LiteMountMountIconMixin",
    "LiteMountMountScrollMixin",
    "LiteMountMountScrollBoxMixin",
    "LiteMountMountsPanel",
    "LiteMountMountsPanelMixin",
    "LiteMountGroupsPanelMountScrollBoxMixin",
    "LiteMountGroupsPanelGroupScrollBoxMixin",
    "LiteMountGroupsPanelButtonMixin",
    "LiteMountOptions",
    "LiteMountOptionsBinding_OnLoad",
    "LiteMountOptionsBinding_Update",
    "LiteMountOptionsBindings",
    "LiteMountOptionsBindingsBinding_OnClick",
    "LiteMountOptionsBindings_OnHide",
    "LiteMountOptionsBindings_OnKeyDown",
    "LiteMountOptionsBindings_OnShow",
    "LiteMountOptionsBindings_Update",
    "LiteMountOptionsControl_Cancel",
    "LiteMountOptionsControl_GetControl",
    "LiteMountOptionsControl_OnChanged",
    "LiteMountOptionsControl_OnCommit",
    "LiteMountOptionsControl_OnDefault",
    "LiteMountOptionsControl_OnRefresh",
    "LiteMountOptionsControl_OnTextChanged",
    "LiteMountOptionsControl_Revert",
    "LiteMountOptionsControl_SetControl",
    "LiteMountOptionsControl_SetTab",
    "LiteMountOptionsPanel_AutoLocalize",
    "LiteMountOptionsPanel_Cancel",
    "LiteMountOptionsPanel_OnCancel",
    "LiteMountOptionsPanel_OnCommit",
    "LiteMountOptionsPanel_OnDefault",
    "LiteMountOptionsPanel_OnHide",
    "LiteMountOptionsPanel_OnLoad",
    "LiteMountOptionsPanel_OnRefresh",
    "LiteMountOptionsPanel_OnReset",
    "LiteMountOptionsPanel_OnShow",
    "LiteMountOptionsPanel_Open",
    "LiteMountOptionsPanel_PopOver",
    "LiteMountOptionsPanel_RegisterControl",
    "LiteMountOptionsPanel_Revert",
    "LiteMountPicker",
    "LiteMountPickerMixin",
    "LiteMountPopOverPanel_OnHide",
    "LiteMountPopOverPanel_OnLoad",
    "LiteMountPopOverPanel_OnShow",
    "LiteMountPriorityMixin",
    "LiteMountProfileExport",
    "LiteMountProfileExportMixin",
    "LiteMountProfileImport",
    "LiteMountProfileImportMixin",
    "LiteMountProfileInspect",
    "LiteMountProfileInspectMixin",
    "LiteMountProfilesPanel",
    "LiteMountProfilesPanelMixin",
    "LiteMountReportBugMixin",
    "LiteMountRuleButtonMixin",
    "LiteMountRuleEdit",
    "LiteMountRuleEditActionMixin",
    "LiteMountRuleEditConditionMixin",
    "LiteMountRuleEditMixin",
    "LiteMountRulesPanel",
    "LiteMountRulesPanelMixin",
    "LiteMountRulesScrollMixin",
    "LiteMountSearchBoxMixin",
    "LiteMountTooltip",
    "LiteMountTooltipMixin",
    "LM_BUTTON_BACKDROP_INFO",
    "LM_CONTAINER_BACKDROP_INFO",
    "LM_LISTBUTTON_BACKDROP_INFO",
    "StaticPopupDialogs",
    "SlashCmdList",
}

read_globals = {
    "ACCEPT",
    "ACCESSIBILITY_DRIVE_LABEL",
    "ADVANCED_LABEL",
    "ADVANCED_OPTIONS",
    "ALL",
    "ALWAYS",
    "AMMOSLOT",
    "AuraUtil",
    "BACKSLOT",
    "BLUE_FONT_COLOR",
    "BRAWL_TOOLTIP_MAP",
    "BUG_CATEGORY5",
    "CAMERA_MODIFICATION_TYPE_DISCARD",
    "CAMERA_TRANSITION_TYPE_IMMEDIATE",
    "CANCEL",
    "CHAT",
    "CHECK_ALL",
    "CHESTSLOT",
    "CLASS",
    "CLASS_SORT_ORDER",
    "CLUB_FINDER_ANY_FLAG",
    "COLLECTED",
    "COMBAT",
    "COMMON_GRAY_COLOR",
    "CONFIRM_COMPACT_UNIT_FRAME_PROFILE_DELETION",
    "CROSS_FACTION_CLUB_FINDER_SEARCH_OPTION",
    "C_AddOns",
    "C_BattleNet",
    "C_Calendar",
    "C_ClassTalents",
    "C_Container",
    "C_Covenants",
    "C_CreatureInfo",
    "C_DateAndTime",
    "C_Item",
    "C_Map",
    "C_Minimap",
    "C_MountJournal",
    "C_PetJournal",
    "C_PvP",
    "C_QuestLog",
    "C_Scenario",
    "C_Spell",
    "C_ToyBox",
    "C_Traits",
    "C_Transmog",
    "C_TransmogCollection",
    "C_TransmogSets",
    "C_UI",
    "C_UnitAuras",
    "C_ZoneAbility",
    "CalendarFrame",
    "CanExitVehicle",
    "ChatEdit_InsertLink",
    "Constants",
    "ContainsIf",
    "CopyTable",
    "CreateDataProvider",
    "CreateFrame",
    "CreateFromMixins",
    "CreateMacro",
    "CreateScrollBoxListLinearView",
    "CreateVector2D",
    "DEAD",
    "DEFAULT",
    "DEFAULT_CHAT_FRAME",
    "DELETE",
    "DESCRIPTION",
    "DISABLE",
    "DISABLED_FONT_COLOR",
    "DevTools_Dump",
    "DifficultyUtil",
    "Dismount",
    "EJ_GetCurrentTier",
    "EJ_GetEncounterInfoByIndex",
    "EJ_GetInstanceByIndex",
    "EJ_GetNumTiers",
    "EJ_GetTierInfo",
    "EJ_SelectInstance",
    "EJ_SelectTier",
    "EPIC_PURPLE_COLOR",
    "ERRORS",
    "ERR_NOT_IN_COMBAT",
    "EXPANSION_LEVEL",
    "EditMacro",
    "EncounterJournal",
    "Enum",
    "ExtraActionButton1",
    "FACTION",
    "FACTION_LABELS",
    "FACTION_RED_COLOR",
    "FAVORITES",
    "FEETSLOT",
    "FEMALE",
    "FINGER0SLOT",
    "FINGER1SLOT",
    "FONT_COLOR_CODE_CLOSE",
    "FadingFrame_OnLoad",
    "FadingFrame_SetFadeInTime",
    "FadingFrame_SetFadeOutTime",
    "FadingFrame_SetHoldTime",
    "FadingFrame_Show",
    "FindBaseSpellByID",
    "FindSpellOverrideByID",
    "GAMEMENU_HELP",
    "GRAY_FONT_COLOR_CODE",
    "GREEN_FONT_COLOR",
    "GUILD_RECRUITMENT_MAXLEVEL",
    "GameTooltip",
    "GameTooltip_Hide",
    "GetAchievementInfo",
    "GetActionInfo",
    "GetBindingKey",
    "GetBuildInfo",
    "GetCVar",
    "GetCVarBool",
    "GetClassInfo",
    "GetCursorPosition",
    "GetDifficultyInfo",
    "GetInstanceInfo",
    "GetInventoryItemCooldown",
    "GetKeysArray",
    "GetLocale",
    "GetMacroIndexByName",
    "GetMacroInfo",
    "GetMaxLevelForExpansionLevel",
    "GetMirrorTimerInfo",
    "GetMouseButtonClicked",
    "GetNumClasses",
    "GetNumGroupMembers",
    "GetNumShapeshiftForms",
    "GetNumSubgroupMembers",
    "GetPhysicalScreenSize",
    "GetProfessionInfo",
    "GetProfessions",
    "GetRealmName",
    "GetRunningMacro",
    "GetScreenHeight",
    "GetScreenWidth",
    "GetShapeshiftForm",
    "GetShapeshiftFormID",
    "GetShapeshiftFormInfo",
    "GetSpecialization",
    "GetSpecializationInfo",
    "GetSpecializationInfoByID",
    "GetSpecializationInfoForClassID",
    "GetSpellLink",
    "GetSubZoneText",
    "GetTime",
    "GetUnitSpeed",
    "GetZoneText",
    "HANDSSLOT",
    "HEADSLOT",
    "HEIRLOOMS",
    "HELPFRAME_REPORT_PLAYER_RIGHT_CLICK",
    "HasAction",
    "HasExtraActionBar",
    "HasTempShapeshiftActionBar",
    "HybridScrollFrame_CreateButtons",
    "HybridScrollFrame_GetOffset",
    "HybridScrollFrame_Update",
    "ID",
    "INSTANCE",
    "INVSLOT_AMMO",
    "INVSLOT_BACK",
    "INVSLOT_BODY",
    "INVSLOT_CHEST",
    "INVSLOT_FEET",
    "INVSLOT_FINGER1",
    "INVSLOT_FINGER2",
    "INVSLOT_HAND",
    "INVSLOT_HEAD",
    "INVSLOT_LAST_EQUIPPED",
    "INVSLOT_LEGS",
    "INVSLOT_MAINHAND",
    "INVSLOT_NECK",
    "INVSLOT_OFFHAND",
    "INVSLOT_RANGED",
    "INVSLOT_SHOULDER",
    "INVSLOT_TABARD",
    "INVSLOT_TRINKET1",
    "INVSLOT_TRINKET2",
    "INVSLOT_WAIST",
    "INVSLOT_WRIST",
    "InCombatLockdown",
    "IsAdvancedFlyableArea",
    "IsAltKeyDown",
    "IsControlKeyDown",
    "IsDrivableArea",
    "IsFalling",
    "IsFlyableArea",
    "IsFlying",
    "IsInGroup",
    "IsInInstance",
    "IsInRaid",
    "IsIndoors",
    "IsLeftAltKeyDown",
    "IsLeftControlKeyDown",
    "IsLeftMetaKeyDown",
    "IsLeftShiftKeyDown",
    "IsLegacyDifficulty",
    "IsMacClient",
    "IsMetaKeyDown",
    "IsModifiedClick",
    "IsModifierKeyDown",
    "IsMounted",
    "IsOutdoors",
    "IsPlayerSpell",
    "IsResting",
    "IsRightAltKeyDown",
    "IsRightControlKeyDown",
    "IsRightMetaKeyDown",
    "IsRightShiftKeyDown",
    "IsShiftKeyDown",
    "IsSpellKnown",
    "IsStealthed",
    "IsSubmerged",
    "IsSwimming",
    "Item",
    "KEY_BINDING",
    "LEGENDARY_ORANGE_COLOR",
    "LEGSSLOT",
    "LEVEL",
    "LE_EXPANSION_LEVEL_CURRENT",
    "LE_MOUNT_JOURNAL_FILTER_COLLECTED",
    "LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED",
    "LE_MOUNT_JOURNAL_FILTER_UNUSABLE",
    "LE_SCENARIO_TYPE_WARFRONT",
    "LFGWIZARD_TITLE",
    "LFG_LIST_DIFFICULTY",
    "LFG_LIST_LEGACY",
    "LFG_TYPE_DUNGEON",
    "LOCALIZED_CLASS_NAMES_FEMALE",
    "LOCATION_COLON",
    "L_UIDROPDOWNMENU_MENU_VALUE",
    "L_UIDROPDOWNMENU_OPEN_MENU",
    "LibDebug",
    "LibStub",
    "LoadAddOn",
    "MACRO",
    "MACROFRAME_CHAR_LIMIT",
    "MAINHANDSLOT",
    "MALE",
    "MAX_ACCOUNT_MACROS",
    "MAX_CHARACTER_MACROS",
    "MOUNT",
    "MOUNTS",
    "MOUNT_JOURNAL_FILTER_AQUATIC",
    "MOUNT_JOURNAL_FILTER_DRAGONRIDING",
    "MOUNT_JOURNAL_FILTER_FLYING",
    "MOUNT_JOURNAL_FILTER_GROUND",
    "MOUNT_JOURNAL_FILTER_UNUSABLE",
    "MenuResponse",
    "MenuUtil",
    "Mixin",
    "MountJournalSearchBox",
    "NAME",
    "NECKSLOT",
    "NONE",
    "NOT_BOUND",
    "NOT_COLLECTED",
    "OKAY",
    "ORANGE_FONT_COLOR",
    "OTHER",
    "PARTY",
    "PERKS_VENDOR_CATEGORY_TRANSMOG",
    "PLAYER_FACTION_GROUP",
    "PVP",
    "PickupItem",
    "PickupMacro",
    "PickupSpell",
    "PlaySound",
    "PlayerHasToy",
    "PlayerUtil",
    "RACE",
    "RAID",
    "RAID_FRAME_SORT_LABEL",
    "RANGEDSLOT",
    "RARE_BLUE_COLOR",
    "RARITY",
    "RED_FONT_COLOR",
    "SEARCH",
    "SECONDARYHANDSLOT",
    "SELECTED_CHAT_FRAME",
    "SHIRTSLOT",
    "SHOULDERSLOT",
    "SLASH_DISMOUNT1",
    "SOUNDKIT",
    "SOURCE",
    "SOURCES",
    "SPECIALIZATION",
    "SPELL_FAILED_NO_MOUNTS_ALLOWED",
    "SPELL_TARGET_TYPE1_DESC",
    "STAT_CATEGORY_SPELL",
    "STRING_ENVIRONMENTAL_DAMAGE_FALLING",
    "SUMMONS",
    "ScrollBoxConstants",
    "ScrollUtil",
    "SearchBoxTemplate_OnTextChanged",
    "SetBinding",
    "SetCVar",
    "Settings",
    "SettingsPanel",
    "Spell",
    "StaticPopup_OnClick",
    "StaticPopup_Show",
    "TABARDSLOT",
    "TOTAL",
    "TRANSMOG_OUTFIT_HYPERLINK_TEXT",
    "TRANSMOG_SLOTS",
    "TRINKET0SLOT",
    "TRINKET1SLOT",
    "TUTORIAL_TITLE28",
    "TUTORIAL_TITLE30",
    "TYPE",
    "UIErrorsFrame",
    "UIParent",
    "UNAVAILABLE",
    "UNCHECK_ALL",
    "UNCOMMON_GREEN_COLOR",
    "UNKNOWN",
    "UnitAffectingCombat",
    "UnitChannelInfo",
    "UnitClass",
    "UnitCreatureFamily",
    "UnitExists",
    "UnitFactionGroup",
    "UnitFullName",
    "UnitGUID",
    "UnitGroupRolesAssigned",
    "UnitIsDead",
    "UnitIsFriend",
    "UnitIsPVP",
    "UnitIsPlayer",
    "UnitIsUnit",
    "UnitLevel",
    "UnitName",
    "UnitPlayerOrPetInParty",
    "UnitPlayerOrPetInRaid",
    "UnitRace",
    "UnitSex",
    "VIDEO_OPTIONS_DISABLED",
    "VIDEO_OPTIONS_ENABLED",
    "VehicleExit",
    "WAISTSLOT",
    "WARDROBE_SETS",
    "WHITE_FONT_COLOR",
    "WORLD",
    "WOW_PROJECT_CATACLYSM_CLASSIC",
    "WOW_PROJECT_ID",
    "WOW_PROJECT_MAINLINE",
    "WRISTSLOT",
    "ZONE_COLON",
    "date",
    "debugprofilestop",
    "format",
    "sort",
    "strfind",
    "string",
    "strjoin",
    "strlen",
    "strlower",
    "strsplit",
    "tAppendAll",
    "tCompare",
    "tContains",
    "tDeleteItem",
    "tIndexOf",
    "table",
    "time",
    "tinsert",
    "wipe",
    "GameTooltip_SetTitle",
    "GameTooltip_AddNormalLine",
}
