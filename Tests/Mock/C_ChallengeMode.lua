C_ChallengeMode = {}

-- activeKeystoneLevel, activeAffixIDs, wasActiveKeystoneCharged = C_ChallengeMode.GetActiveKeystoneInfo()

function C_ChallengeMode.GetActiveKeystoneInfo()
    if math.random() > 0.9 then
        return math.random(24) + 1, {}, false
    end
end
