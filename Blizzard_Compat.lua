--[[----------------------------------------------------------------------------

  LiteMount/Blizzard_Compat.lua

  Copyright 2024 Mike Battersby

  For better or worse, try to back-port a functioning amount of compatibility
  for the 11.0 deprecations into classic, on the assumption that it will
  eventually go in there properly and this is the right approach rather than
  making the new way look like the old.

----------------------------------------------------------------------------]]--

local _, LM = ...

--[[ C_Spell ]]-----------------------------------------------------------------

LM.C_Spell = CopyTable(C_Spell or {})

if not LM.C_Spell.GetOverrideSpell then
    function LM.C_Spell.GetOverrideSpell(spellIdentifier)
        local info = LM.C_Spell.GetSpellInfo(spellIdentifier)
        return info and FindSpellOverrideByID(info.spellID)
    end
end


--[[ C_ClassColor ]]------------------------------------------------------------

if not C_ClassColor then
    LM.C_ClassColor = {}
    LM.C_ClassColor.GetClassColor = GetClassColorObj
end

--[[ PanelTemplates ]]----------------------------------------------------------

if not PanelTemplates_AnchorTabs then
    local function GetTabByIndex(frame, index)
        return frame.Tabs and frame.Tabs[index] or _G[frame:GetName().."Tab"..index]
    end

    function LM.PanelTemplates_AnchorTabs(frame)
        for i = 2, frame.numTabs do
            local lastTab = GetTabByIndex(frame, i - 1)
            local thisTab = GetTabByIndex(frame, i)
            thisTab:SetPoint("TOPLEFT", lastTab, "TOPRIGHT", 3, 0)
        end
    end
end
