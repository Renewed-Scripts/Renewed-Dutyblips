local Renewed = exports['Renewed-Lib']:getLib()
local currentDuty = {}
local jobs = require 'config.server'.dutyJobs


local function groupCheck(source, playerData)
    local groups = playerData.Groups or Renewed.getPlayerGroups(source)

    for job, color in pairs(jobs) do
        if groups[job] then
            return color
        end
    end

    return false
end

local function triggerDutyEvent(eventName, eventData)
    for i = 1, #currentDuty do
        TriggerClientEvent(eventName, currentDuty[i].source, eventData)
    end
end


local function isCopOnDuty(source)
    for i = 1, #currentDuty do
        if currentDuty[i].source == source then
            return i
        end
    end

    return false
end

local function addPolice(source)
    if not isCopOnDuty(source) then
        local playerData = Renewed.getPlayer(source)

        local getBlipColor = groupCheck(source, playerData)

        if getBlipColor then
            Player(source).state:set('renewed_dutyblips', true, true)

            local copData = {
                name = playerData.name or Renewed.getCharName(source),
                ped = GetPlayerPed(source),
                source = source,
                color = getBlipColor
            }

            currentDuty[#currentDuty+1] = copData

            triggerDutyEvent('Renewed-Dutyblips:addOfficer', copData)
            TriggerClientEvent('Renewed-Dutyblips:goOnDuty', source, currentDuty)

            return true
        end
    end

    return false
end

local function removePolice(source)
    if isCopOnDuty(source) then
        local index = isCopOnDuty(source)

        if index then
            table.remove(currentDuty, index)

            Player(source).state:set('renewed_dutyblips', false, true)
            triggerDutyEvent('Renewed-Dutyblips:removeOfficer', source)
            TriggerClientEvent('Renewed-Dutyblips:goOffDuty', source)
        end
    end
end

return {
    add = addPolice,
    remove = removePolice,
    onDuty = isCopOnDuty,
    getCopsOnDuty = function()
        return currentDuty
    end,
    triggerDutyEvent = triggerDutyEvent
}


