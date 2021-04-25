obs           = obslua
source_name   = ""
participants_text = ""

hotkey_id     = obs.OBS_INVALID_HOTKEY_ID

function RunLottery(Names)
    string.split =
        function(str, pattern) -- Source for this string splitting method: http://lua-users.org/wiki/SplitJoin
            pattern = pattern or "[^%s]+"
            if pattern:len() == 0 then pattern = "[^%s]+" end
            local parts = {__index = table.insert}
            setmetatable(parts, parts)
            str:gsub(pattern, parts)
            setmetatable(parts, nil)
            parts.__index = nil
            return parts
        end

    NameList = Names:split("[^,%s]+")
    OrderList = {}

    function Contains(Array, Object)
        for i = 1, #Array do
            Val = Array[i]
            if (Val == Object) then return true end
        end
        return false
    end

    repeat
        RandomNumber = math.random(1, #NameList)
        if not Contains(OrderList, RandomNumber) then
            table.insert(OrderList, RandomNumber)
        end
    until #OrderList == #NameList

    ReturnedString = ""

    for i = 1, #OrderList do
        ReturnedString = ReturnedString .. NameList[OrderList[i]] .. "\n"
    end
    return ReturnedString
end

-- =========================================================================

function script_description()
    return "Lottery of meeting participants in random order.\n\nMade by Arttu Ylhävuori, 2021"
end