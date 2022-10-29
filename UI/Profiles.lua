--[[----------------------------------------------------------------------------

  LiteMount/UI/Profiles.lua

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local LibDD = LibStub("LibUIDropDownMenu-4.0")

--[[------------------------------------------------------------------------]]--

LiteMountProfilesPanelMixin = {}

L.LM_PROFILES_EXP = "Here you can manage profiles, different LiteMount configurations that you can switch between. Each character has its own selected profile.\n\nSorry about this low-effort page, this is a quick hack for 10.0 / Dragonflight. It will improve soon.\n\nUse the drop down menu below to manage profiles."

function LiteMountProfilesPanelMixin:OnLoad()

    self.name = L.LM_PROFILES

    LiteMountProfileButton:Attach(self)

    -- LibDD:Create_UIDropDownMenu(self.RandomPersistDropDown)

    LiteMountOptionsPanel_OnLoad(self)
end
