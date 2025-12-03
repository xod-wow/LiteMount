C_Traits = {}

function C_Traits.GetConfigIDByTreeID(treeID)
    if treeID == 1115 then
        return 26654971
    end
end

function C_Traits.GetNodeInfo(configID, nodeID)
    if configID == 26654971 and nodeID == 105869 then
        return {
            meetsEdgeRequirements=true,
            entryIDs={ 130599 },
            ranksIncreased=0,
            posX=3215,
            ID=105869,
            canPurchaseRank=false,
            currentRank=1,
            isCascadeRepurchasable=false,
            visibleEdges={
              { visualStyle=1, type=2, isActive=true, targetNode=105870 }
            },
            isVisible=true,
            posY=3800,
            conditionIDs={ },
            entryIDsWithCommittedRanks={ 130599 },
            isDisplayError=false,
            activeEntry={ entryID=130599, rank=1 },
            flags=8,
            type=0,
            maxRanks=1,
            activeRank=1,
            groupIDs={ 11689, 11690, 11854 },
            isAvailable=true,
            ranksPurchased=1,
            canRefundRank=false
        }
    end
end
