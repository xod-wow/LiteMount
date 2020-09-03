local function Dismount()
    for id,info in pairs(C_MountJournal.data.GetMountInfoByID) do
        local spellID = info[2]
        if MockState.buffs[spellID] then
            CancelAura(spellID)
        end
    end
end

function RunMacroText(macrotext)
    print(">>> RUNMACRO " .. macrotext)
    if macrotext == SLASH_DISMOUNT1 then
        Dismount()
    end
end
