local Utils = {}



local GetPlayerPed = GetPlayerPed
function Utils.awaitPedHandle(playerId)
    local timeout = GetGameTimer() + 4500
    while GetGameTimer() < timeout do
        local ped = GetPlayerPed(playerId)


        if ped > 0 then
            return ped
        end

        Wait(100)
    end

    return false
end

function Utils.registerNetEvent(event, fn)
    RegisterNetEvent(event, function(...)
        if source ~= '' then fn(...) end -- luacheck: ignore
    end)
end

return Utils
