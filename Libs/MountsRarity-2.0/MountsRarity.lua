--[[----------------------------------------------------------------------------

  MountsRarity/MountsRarity.lua

  Copyright (c) 2023 Sören Gade

----------------------------------------------------------------------------]]--

local _, namespace = ...

local MAJOR, MINOR = "MountsRarity-2.0", (namespace.VERSION_MINOR or 1)
---@class MountsRarity: { GetData: function, GetRarityByID: function }
local MountsRarity = LibStub:NewLibrary(MAJOR, MINOR)
if not MountsRarity then print("no") return end -- already loaded and no upgrade necessary

function MountsRarity:GetData()
  ---@type table<number, number|nil>
  return namespace.data
end

---Returns the rarity of a mount (0-100) by ID, or `nil`.
---@param mountID number The mount ID.
function MountsRarity:GetRarityByID(mountID)
  return self:GetData()[mountID]
end
