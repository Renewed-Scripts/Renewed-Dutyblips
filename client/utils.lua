local Utils = {}

function Utils.playEntityAudio(entity)
    local soundId = GetSoundId()
    PlaySoundFromEntity(soundId, 'Beep_Red', entity, 'DLC_HEIST_HACKING_SNAKE_SOUNDS', false, 0)
    ReleaseSoundId(soundId)
end

local GetPlayerPed = GetPlayerPed
function Utils.awaitPedHandle(playerId)
    return lib.waitFor(function()
        local ped = GetPlayerPed(playerId)
        if ped > 0 then return ped end
    end, ('%s Player didnt exsist in time! (%s)'):format(playerId, bagName), 10000)
end

function Utils.registerNetEvent(event, fn)
    RegisterNetEvent(event, function(...)
        if source ~= '' then fn(...) end
    end)
end

return Utils