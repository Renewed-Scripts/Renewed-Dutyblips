lib.versionCheck('Renewed-Scripts/Renewed-Dutyblips')

local blipType = require 'config.server'.blipType
local dutyBlips = require 'server.duty'


SetInterval(function()
    local currentDutyBlips = dutyBlips.getCopsOnDuty()
    local size = #currentDutyBlips

    if size > 0 then
        local activeBlips = table.create(0, size)

        for i = 1, size do
            activeBlips[i] = GetEntityCoords(currentDutyBlips[i].ped).xy
        end

        dutyBlips.triggerDutyEvent('Renewed-Dutyblips:updateBlips', activeBlips)
    end
end, math.random(3, 5) * 1000)


local path = ('bridge.%s'):format(blipType)

lib.load(path)
