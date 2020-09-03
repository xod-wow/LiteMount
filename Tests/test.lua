--[[------------------------------------------------------------------------]]--

dofile("mock/WoWAPI.lua")

local LM = {}

loadfile("../Libs/LibStub.lua")()
loadfile("../Libs/CallbackHandler-1.0/CallbackHandler-1.0.lua")()
loadfile("../Libs/AceDB-3.0/AceDB-3.0.lua")()
loadfile("../Libs/AceSerializer-3.0/AceSerializer-3.0.lua")()
loadfile("../Libs/LibDeflate/LibDeflate.lua")()

tocFiles = {
    "Localization.lua",
    "AutoEventFrame.lua",
    "Print.lua",
    "Developer.lua",
    "SpellInfo.lua",
    "Mount.lua",
    "SecureAction.lua",
    "LM_Journal.lua",
    "LM_Spell.lua",
    "LM_ItemSummoned.lua",
    "LM_GhostWolf.lua",
    "LM_Nagrand.lua",
    "LM_RunningWild.lua",
    "LM_TravelForm.lua",
    "LM_Soulshape.lua",
    "MountList.lua",
    "PlayerMounts.lua",
    "Location.lua",
    "Options.lua",
    "SlashCommand.lua",
    "Conditions.lua",
    "Vars.lua",
    "Actions.lua",
    "ActionList.lua",
    "ActionButton.lua",
    "Core.lua",
    "KeyBindingStrings.lua",
}

for _,file in ipairs(tocFiles) do
    local f, err = loadfile("../" .. file)
    if f then
        f('LiteMount', LM)
    else
        print(file)
        print(err)
        os.exit()
    end
end

function SpamOnUpdate(seconds)
    for i = 1, math.floor(seconds*100) do
        SendOnUpdate()
    end
end

SendEvent('ADDON_LOADED', 'LiteMount')

local f, err = loadfile("SavedVariables/LiteMount.lua")
if f then f() else print(err) end

SendEvent('VARIABLES_LOADED')
SendEvent('PLAYER_LOGIN')

LM.Options:Initialize()

SpamOnUpdate(100)

-- MockState.extraActionButton = 202477
MockState.keyDown.shift = true

LiteMount.actions[1]:Click()

SpamOnUpdate(3)

LiteMount.actions[1]:Click()

SendEvent('PLAYER_LOGOUT')
