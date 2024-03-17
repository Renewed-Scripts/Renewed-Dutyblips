if not lib.checkDependency('Renewed-Lib', '1.1.7', true) then return end

local dutyGroup = require 'config.server'.dutyJobs
local duty = require 'server.duty'
local wasInService = {}

AddStateBagChangeHandler('renewed_service', '', function(bagName, _, value)
    local source = GetPlayerFromStateBagName(bagName)

    if value and dutyGroup[value] then
        duty.add(source)
        wasInService[source] = true
    elseif wasInService[source] then
        duty.remove(source)
        wasInService[source] = false
    end
end)

AddEventHandler('Renewed-Lib:server:playerRemoved', function(source)
    if wasInService[source] then
        duty.remove(source)
    end
end)


AddEventHandler('playerDropped', function()
    if wasInService[source] then
        duty.remove(source)
    end
end)


-- Not the most optimized but who cares people shouldnt restart their resources on liveuse
AddEventHandler('onServerResourceStart', function(res)
    if res == cache.resource then
        Wait(500)
        for _, source in ipairs(GetPlayers()) do
            source = tonumber(source, 10)
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
