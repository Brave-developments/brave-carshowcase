Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)
        local anyInRange = false

        for i = 1, #Cars do
            local distance = #(pCoords - Cars[i].pos)
            if distance < ShowRange then
                anyInRange = true
                if not Cars[i].spawned then
                    SpawnLocalCar(i)
                end
            else
                if Cars[i].spawned then
                    DeleteEntity(Cars[i].spawned)
                    Cars[i].spawned = nil
                end
            end
        end
        if not anyInRange then
            Wait(1000)
        else
            Wait(5000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        local pl = GetEntityCoords(ped)
        for k, v in pairs(Cars) do
            if #(pl - v.pos) < ShowRange then
                Draw3DText(v.pos.x, v.pos.y, v.pos.z - 0.5, v.text, 0, 0.1, 0.1)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        for i = 1, #Cars do
            if Cars[i].spawned and Cars[i].spin then
                local currentHeading = GetEntityHeading(Cars[i].spawned)
                SetEntityHeading(Cars[i].spawned, currentHeading - 0.3)
            end
        end
        Wait(5)
    end
end)

function SpawnLocalCar(i)
    Citizen.CreateThread(function()
        local model = Cars[i].model
        local hash = GetHashKey(model)
        RequestModel(hash)
        local attempt = 0
        while not HasModelLoaded(hash) do
            attempt = attempt + 1
            if attempt > 2000 then
                print("Failed to load model: " .. model)
                return
            end
            Wait(0)
        end

        local pos = Cars[i].pos
        local heading = Cars[i].heading
        local veh = CreateVehicle(hash, pos.x, pos.y, pos.z - 1, heading, false, false)
        SetModelAsNoLongerNeeded(hash)
        SetVehicleEngineOn(veh, false)
        SetVehicleBrakeLights(veh, false)
        SetVehicleLights(veh, 0)
        SetVehicleLightsMode(veh, 0)
        SetVehicleInteriorlight(veh, false)
        SetVehicleOnGroundProperly(veh)
        FreezeEntityPosition(veh, true)
        SetVehicleCanBreak(veh, true)
        SetVehicleFullbeam(veh, false)

        if carInvincible then
            SetVehicleReceivesRampDamage(veh, true)
            RemoveDecalsFromVehicle(veh)
            SetVehicleCanBeVisiblyDamaged(veh, true)
            SetVehicleLightsCanBeVisiblyDamaged(veh, true)
            SetVehicleWheelsCanBreakOffWhenBlowUp(veh, false)
            SetDisableVehicleWindowCollisions(veh, true)
            SetEntityInvincible(veh, true)
        end

        if DoorLock then
            SetVehicleDoorsLocked(veh, 2)
        end

        SetVehicleNumberPlateText(veh, Cars[i].plate)
        Cars[i].spawned = veh
    end)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for i = 1, #Cars do
            if Cars[i].spawned then
                DeleteEntity(Cars[i].spawned)
            end
        end
    end
end)

function Draw3DText(x, y, z, textInput, fontId, scaleX, scaleY)
    local camCoords = GetGameplayCamCoords()
    local dist = #(vector3(camCoords.x, camCoords.y, camCoords.z) - vector3(x, y, z))
    local scale = (1 / dist) * 20
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    SetTextScale(scaleX * scale, scaleY * scale)
    SetTextFont(fontId)
    SetTextProportional(1)
    SetTextColour(250, 250, 250, 255)
    SetTextDropshadow(1, 1, 1, 1, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(textInput)
    SetDrawOrigin(x, y, z + 2, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end
