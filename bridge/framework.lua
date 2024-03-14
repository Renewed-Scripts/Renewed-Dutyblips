local dutyGroup = require 'config.server'.dutyJobs
local duty = require 'server.duty'
local wasInService = {}

AddStateBagChangeHandler('renewed_service', '', function(bagName, _, value)
    local source = GetPlayerFromStateBagName(bagName)

    if value then
        if dutyGroup[value] then
            duty.add(source)
            wasInService[source] = true
        end
    else
        if wasInService[source] then
            duty.remove(source)
            wasInService[source] = false
        end
    end
end)

AddEventHandler('Renewed-Lib:server:playerRemoved', function(source)
    if wasInService[source] then
        duty.remove(source)
    end
end)


-- Not the most optimized but who cares people shouldnt restart their resources on liveuse
AddEventHandler('onServerResourceStart', function(res)
    if res == cache.resource then
        Wait(500)
        for _, source in ipairs(GetPlayers()) do
            local inService = Player(source).state.renewed_service

            if inService then
                if dutyGroup[inService] then
                    duty.add(source)
                    wasInService[source] = true
                end
            end
        end
    end
end)
