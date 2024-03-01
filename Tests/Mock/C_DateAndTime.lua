C_DateAndTime = {}

function C_DateAndTime.GetCurrentCalendarTime()
    return os.date("*t")
end

function C_DateAndTime.CompareCalendarTime(a, b)
    local aSecs, bSecs = os.time(a), os.time(b)
    if aSecs < bSecs then
        return -1
    elseif aSecs > bSecs then
        return 1
    elseif aSecs == bSecs then
        return 0
    end
end
