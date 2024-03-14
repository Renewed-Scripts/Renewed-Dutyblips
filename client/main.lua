local Utils = require 'client.utils'
local Blips = require 'client.blip'
local cops = {}
local nearbyCops = {}
local whiteListed = false

Utils.registerNetEvent('Renewed-Dutyblips:updateBlips', function(data)
    for i = 1, #data do
        local cop = cops[i]

        if not nearbyCops[cop.source] and cop.source ~= cache.serverId then
            if cop.blip then
                Blips.changeBlipCoords(cop.blip, data[i])
            else
                cop.blip = Blips.addBlipForCoord(data[i], {
                    color = cop.color,
                    name = cop.name,
                })
            end
        end
    end
end)

local function getCopFromSource(source)
    for i = 1, #cops do
        if cops[i].source == source then
            return i
        end
    end
end

AddStateBagChangeHandler('renewed_dutyblips', nil, function(bagName, _, value)
    local source = tonumber(bagName:gsub('player:', ''), 10)

    if not whiteListed or source == cache.serverId or not value then
        return
    end

    local index = getCopFromSource(source)

    if index then
        local playerId = GetPlayerFromServerId(source)
        local pedHandle = Utils.awaitPedHandle(playerId)

        if pedHandle then
            local cop = cops[index]

            if cop.blip then
                RemoveBlip(cop.blip)
            end

            cop.blip = Blips.addBlipForEntity(pedHandle, cop)
            nearbyCops[source] = true
        end
    end

end)

RegisterNetEvent('onPlayerDropped', function(serverId)
    if nearbyCops[serverId] then
        nearbyCops[serverId] = nil
        local index = getCopFromSource(serverId)
        local cop = index and cops[index]

        if cop then
            local blipCoord = GetBlipCoords(cop.blip)

            RemoveBlip(cop.blip)

            cop.blip = Blips.addBlipForCoord(blipCoord, {
                color = cop.color,
                name = cop.name,
            })
        end
    end
end)


Utils.registerNetEvent('Renewed-Dutyblips:addOfficer', function(data)
    cops[#cops+1] = {
        source = tonumber(data.source),
        name = data.name,
        color = data.color or 1,
    }
end)

Utils.registerNetEvent('Renewed-Dutyblips:removeOfficer', function(index)
    table.remove(cops, index)
end)


Utils.registerNetEvent('Renewed-Dutyblips:goOffDuty', function()
    for i = 1, #cops do
        local cop = cops[i]

        if cop.blip then
            RemoveBlip(cop.blip)
        end
    end

    table.wipe(cops)
    table.wipe(nearbyCops)
    whiteListed = false
end)

Utils.registerNetEvent('Renewed-Dutyblips:goOnDuty', function(copsData)
    for i = 1, #copsData do
        local cop = copsData[i]

        cops[i] = {
            source = tonumber(cop.source),
            name = cop.name,
            color = cop.color or 1,
        }
    end

    whiteListed = true
end)
