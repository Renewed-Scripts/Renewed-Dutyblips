local Config = require 'config.client'

local Blips = {}

local function applyBlipSettings(blip, color, name, sprite)
    SetBlipSprite(blip, sprite)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(name)
    EndTextCommandSetBlipName(blip)
end

function Blips.getBlipSprite(pedHandle)
    local sprite = 1
    local vehicle = GetVehiclePedIsIn(pedHandle, false)
    local class = vehicle and (GetVehicleClass(vehicle))

    return class and Config.classSprites[class] or sprite
end

function Blips.changeBlipCoords(blip, coords)
    SetBlipCoords(blip, coords.x, coords.y, 0.0)
end

function Blips.addBlipForCoord(coords, blipData)
    local blip = AddBlipForCoord(coords.x, coords.y, 0.0)
    applyBlipSettings(blip, blipData.color, blipData.name, 1)

    return blip
end

function Blips.changeBlipForEntity(blip, pedHandle)
    local newSprite = Blips.getBlipSprite(pedHandle)

    if newSprite ~= GetBlipSprite(blip) then
        local color = GetBlipColour(blip)
        SetBlipSprite(blip, newSprite)
        SetBlipColour(blip, color)
    end
end

function Blips.addBlipForEntity(pedHandle, blipData)
    local blip = AddBlipForEntity(pedHandle)
    applyBlipSettings(blip, blipData.color, blipData.name, Blips.getBlipSprite(pedHandle))
    SetBlipShowCone(blip, true)

    return blip
end

return Blips
