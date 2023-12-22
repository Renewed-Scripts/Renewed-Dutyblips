local Renewed = exports['Renewed-Lib']:getLib()
local Config = require 'config.server'

local duty = {}
local dutyBlips = {}


function duty.getDutyPlayers()
    return dutyBlips
end

local function groupCheck(source, playerData)
    local groups = playerData.Groups or Renewed.getPlayerGroups(source)

    for job, color in pairs(Config.dutyJobs) do
        if groups[job] then
            return color
        end
    end

    return false
end

function duty.isDuty(source)
    return dutyBlips[source]
end

function duty.add(source, playerData)
    playerData = playerData or Renewed.getPlayer(source)
    local jobColor = groupCheck(source, playerData)

    if jobColor then
        dutyBlips[source] = {
            name = playerData.name,
            ped = GetPlayerPed(source),
            color = jobColor
        }

        Player(source).state:set('renewed_dutyblips', dutyBlips[source], true)
    end
end

function duty.remove(source, forced)
    local hasItem = exports.ox_inventory:GetItemCount(source, Config.itemName) > 0

    if not hasItem or forced then
        dutyBlips[source] = nil
        Player(source).state:set('renewed_dutyblips', false, true)
    end
end

RegisterNetEvent('Renewed-Lib:server:playerRemoved', function(source)
    local isOnDuty = dutyBlips[source]

    if isOnDuty then
        dutyBlips[source] = nil
        Player(source).state:set('renewed_dutyblips', false, true)
    end
end)


return duty