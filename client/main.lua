local Blips = require 'client.blip'
local playerBlips = {}
local audioPlayers = {}
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
    local currentBlip = playerBlips[blipData.source]
    local blipExsist = DoesBlipExist(currentBlip)
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

    if not playerNearby and not DoesBlipExist(currentBlip) then
        return Blips.addBlipForCoord(blipData.coords, blipData)
    end

    SetBlipCoords(currentBlip, blipData.coords.x, blipData.coords.y, blipData.coords.z)

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

local function playAudio(ped)
    local soundId = GetSoundId()
    PlaySoundFromEntity(soundId, 'Beep_Red', ped, 'DLC_HEIST_HACKING_SNAKE_SOUNDS', false, 0)
    ReleaseSoundId(soundId)
end

local function doesPedHandleExsist(ped)
    for i = 1, #audioPlayers do
        if audioPlayers[i] == ped then
            return i
        end
    end

    return false
end

local enableTrackerAudio = require 'config.client'.enableTrackerAudio
local myId = ('player:%s'):format(cache.serverId)
AddStateBagChangeHandler('renewed_dutyblips', nil, function(bagName, _, value)
    local source = tonumber(bagName:gsub('player:', ''), 10)

    local blip = playerBlips[source]
    local playerId = GetPlayerFromServerId(source)
    local pedHandle = getPedHandle(playerId)

    if not value then
        if blip then
            RemoveBlip(blip)
            playerBlips[source] = nil
        end

        if pedHandle then
            local index = doesPedHandleExsist(pedHandle)

            if index and index > 0 then
                audioPlayers[index] = nil
            end
        end

        return
    end

    if enableTrackerAudio and not doesPedHandleExsist(pedHandle) then
        audioPlayers[#audioPlayers+1] = pedHandle
        playAudio(pedHandle)
    end

    if isWhitelisted and bagName ~= myId then
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

if enableTrackerAudio then
    CreateThread(function()
        while true do
            if next(audioPlayers) then
                for i = 1, #audioPlayers do
                    local ped = audioPlayers[i]

                    if DoesEntityExist(ped) then
                        playAudio(ped)
                    else
                        audioPlayers[i] = nil
                    end

                    Wait(500)
                end
            end

            Wait(math.random(9, 15) * 1000)
        end
    end)
end


AddEventHandler('Renewed-Lib:client:PlayerLoaded', function(player)
    isWhitelisted = isGroupsWhitelisted(player.group)
end)

AddEventHandler('Renewed-Lib:client:UpdateGroup', function(groups)
    local wasWhitelisted = isWhitelisted

    isWhitelisted = isGroupsWhitelisted(groups)

    if wasWhitelisted ~= isWhitelisted then
        if next(playerBlips) then
            for source, blip in pairs(playerBlips) do
                RemoveBlip(blip)
                playerBlips[source] = nil
            end
        end

        TriggerServerEvent('Renewed-Dutyblips:server:updateMeBlip', isWhitelisted)
    end
end)

RegisterNetEvent('Renewed-Dutyblips:client:removedOfficer', function(officerSource)
    local blip = playerBlips[officerSource]

    if blip then
        RemoveBlip(blip)
        playerBlips[officerSource] = nil
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        isWhitelisted = isGroupsWhitelisted(getGroups())
    end
end)