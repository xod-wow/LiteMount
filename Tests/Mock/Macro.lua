function RunMacroText(macrotext)
    print(">>> RUNMACRO " .. macrotext)

    if macrotext == SLASH_DISMOUNT1 then
        MockState.isMounted = false
        for id,info in pairs(C_MountJournal.data.GetMountInfoByID) do
            local spellID = info[2]
            MockState.buffs[spellID] = false
        end
    end
end
