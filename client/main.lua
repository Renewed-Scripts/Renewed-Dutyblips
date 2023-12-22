local Blips = require 'client.blip'
local playerBlips = {}
local dutyBlips = GlobalState.dutyJobs
local isWhitelisted = false

local getGroups = exports['Renewed-Lib']:getLib().getPlayerGroup

local NetworkIsPlayerActive = NetworkIsPlayerActive
local GetPlayerFromServerId = GetPlayerFromServerId
local GetPlayerPed = GetPlayerPed

local function isGroupsWhitelisted(groups)
    if groups then
        for group, _ in pairs(dutyBlips) do
            if groups[group] then
                return true
            end
        end
    end
end

local function getPedHandle(playerId)
    return lib.waitFor(function()
        local ped = GetPlayerPed(playerId)
        if ped > 0 then return ped end
    end, ('%s Player didnt exsist in time! (%s)'):format(playerId, bagName), 10000)
end

local function createPedBlip(blipData)
    local playerId = GetPlayerFromServerId(blipData.source)
    local blipExsist = playerBlips[blipData.source]
    local playerNearby = NetworkIsPlayerActive(playerId)

    if blipExsist and playerNearby then
        return
    end

    if not blipExsist and playerNearby then
        local pedHandle = getPedHandle(playerId)

        if pedHandle then
            return Blips.addBlipForEntity(pedHandle, blipData)
        end
    end

    if not blipExsist and not playerNearby then
        return Blips.addBlipForCoord(blipData.coords, blipData)
    end

    SetBlipCoords(blipExsist, blipData.coords.x, blipData.coords.y, blipData.coords.z)

    return false
end

RegisterNetEvent('Renewed-Dutyblips:client:updateDutyBlips', function(data)
    for i = 1, #data do
        local blipData = data[i]
        local source = blipData.source
        if source ~= cache.serverId then
            local blip = createPedBlip(blipData)

            if blip then
                playerBlips[source] = blip
            end
        end
    end
end)

local myId = ('player:%s'):format(cache.serverId)
AddStateBagChangeHandler('renewed_dutyblips', nil, function(bagName, _, value)
    if isWhitelisted and bagName ~= myId then
        local source = tonumber(bagName:gsub('player:', ''), 10)

        local blip = playerBlips[source]

        if not value and blip then
            RemoveBlip(blip)
            playerBlips[source] = nil

            return
        end

        local playerId = GetPlayerFromServerId(source)

        local pedHandle = getPedHandle(playerId)

        if pedHandle then
            if blip then
                RemoveBlip(blip)
            end

            playerBlips[source] = Blips.addBlipForEntity(pedHandle, value)
        end
    end
end)

CreateThread(function()
    while true do
        if isWhitelisted and next(playerBlips) then
            for source, blip in pairs(playerBlips) do
                local playerId = GetPlayerFromServerId(source)

                if NetworkIsPlayerActive(playerId) then
                    local playerPed = getPedHandle(playerId)

                    if playerPed then
                        Blips.changeBlipForEntity(blip, playerPed)
                    end
                end
            end
        end
        Wait(2500)
    end
end)

AddEventHandler('Renewed-Lib:client:PlayerLoaded', function(player)
    isWhitelisted = isGroupsWhitelisted(player.group)
end)

AddEventHandler('Renewed-Lib:client:UpdateGroup', function(groups)
    isWhitelisted = isGroupsWhitelisted(groups)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        isWhitelisted = isGroupsWhitelisted(getGroups())
    end
end)