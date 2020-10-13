LM = {}

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
    "Environment.lua",
    "Options.lua",
    "SecureAction.lua",
    "Mount.lua",
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
