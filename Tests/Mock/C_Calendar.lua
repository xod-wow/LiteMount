-- Does nothing, returns nothing

local status, date = pcall(require, "date")

if status then
    C_Calendar = { }

    local reference = date()

    function C_Calendar.GetMonthInfo()
        local first = reference:setday(1)
        local last = first:addmonths(1):adddays(-1)

        return {
            month = reference:getmonth(),
            year = reference:getyear(),
            numDays = last:getday(),
            firstWeekday = first:getweekday(),
        }
    end

    function C_Calendar.SetAbsMonth(month, year)
        reference = reference:setmonth(month):setyear(year)
    end

    function C_Calendar.SetMonth(offset)
        reference = reference:addmonths(offset)
    end

    function C_Calendar.GetNumDayEvents(monthOffset, monthDay)
        return 0
    end

    function C_Calendar.GetDayEvent(monthOffset, monthDay, i)
    end

end
