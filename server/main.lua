local Config = require 'config.server'
local duty = require 'server.duty'

GlobalState.dutyJobs = Config.dutyJobs

SetInterval(function()
    local n = 0
    local activeBlips = {}
    local dutyBlips = duty.getDutyPlayers()

    for source, officer in pairs(dutyBlips) do
        n += 1
        activeBlips[n] = {
            coords = GetEntityCoords(officer.ped),
            name = officer.name,
            source = source,
            color = officer.color,
        }
    end

    duty.TriggerOfficerEvent('Renewed-Dutyblips:client:updateDutyBlips', activeBlips)
end, math.random(3, 5) * 1000)

local function itemCheck(source)
    local Items = exports.ox_inventory:GetInventoryItems(source)

    if Items and next(Items) then
        for _, item in pairs(Items) do
            if item.name == Config.itemName then
                return duty.add(source)
            end
        end
    end
end

AddEventHandler('Renewed-Lib:server:playerLoaded', function(source)
    Wait(3000)
    itemCheck(source)
end)

AddEventHandler('Renewed-Lib:server:playerRemoved', function(source)
    if duty.isDuty(source) then
        duty.remove(source, true)
    end
end)

-- Supports server restarts, but this is very bad please don't restart this with many players online
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(100)
        for _, source in ipairs(GetPlayers()) do
            itemCheck(tonumber(source))
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
   if resource == GetCurrentResourceName() then
      local dutyBlips = duty.getDutyPlayers()

        for source in pairs(dutyBlips) do
            Player(source).state:set('renewed_dutyblips', false, true)
        end
   end
end)

exports.ox_inventory:registerHook('swapItems', function(payload)
    if payload.fromInventory == payload.toInventory then return true end -- If they are just swapping slots, don't do anything
    local source = payload.source

    local adding = payload.toInventory == source

    local isOnDuty = duty.isDuty(source)

    if adding then
        if type(payload.fromInventory) == 'number' and duty.isDuty(payload.fromInventory) then
            SetTimeout(100, function()
                duty.remove(payload.fromInventory)
            end)
        end

        if not isOnDuty then
            duty.add(source)
        end
    elseif not adding and isOnDuty then
        SetTimeout(100, function()
            duty.remove(source)
        end)
    end

    return true
end, {
    itemFilter = {
        [Config.itemName] = true,
    },
})

exports.ox_inventory:registerHook('createItem', function(payload)
    local source = payload.inventoryId

    if type(source) == 'number' and DoesPlayerExist(source) and not duty.isDuty(source) then
        SetTimeout(100, function()
            if exports.ox_inventory:GetItemCount(source, Config.itemName) > 0 then
                duty.add(source)
            end
        end)
    end

    return true
end, {
    itemFilter = {
        [Config.itemName] = true,
    },
})

RegisterNetEvent('Renewed-Dutyblips:server:updateMeBlip', function(isWhitelisted)
    if isWhitelisted then
        if exports.ox_inventory:GetItemCount(source, Config.itemName) > 0 then
            duty.add(source)
        end
    elseif duty.isDuty(source) then
        duty.remove(source, true)
    end
end)
