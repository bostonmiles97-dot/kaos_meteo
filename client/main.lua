local isUIOpen = false
local currentWeather = Config.DefaultWeather
local weatherZones = Config.WeatherZones
local transitionMode = Config.WeatherTransition or 'smooth'
local transitionTime = Config.TransitionTime or 5.0

print('[WeatherSync] Client script loaded successfully')

-- Initialize client
CreateThread(function()
    -- Wait a bit for everything to load
    Wait(1000)
    
    -- Set initial weather
    SetWeatherTypeNowPersist(currentWeather)
    ClearWeatherTypePersist()
    SetWeatherTypeNow(currentWeather)
    
    -- Weather zone checking loop
    local lastWeather = nil
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local targetWeather = currentWeather
        
        -- Check if player is in any weather zone (priority order)
        for _, zone in pairs(weatherZones) do
            if zone.enabled then
                local distance = #(playerCoords - zone.coords)
                if distance <= zone.radius then
                    targetWeather = zone.weather
                    break
                end
            end
        end
        
        -- Only update weather if it changed (performance optimization)
        if targetWeather ~= lastWeather then
            SetWeatherTypeNowPersist(targetWeather)
            ClearWeatherTypePersist()
            SetWeatherTypeNow(targetWeather)
            lastWeather = targetWeather
        end
        
        Wait(3000) -- Balanced check interval
    end
end)

-- ESC key handler
CreateThread(function()
    while true do
        Wait(0)
        if isUIOpen then
            -- Disable ESC and other controls while UI is open
            DisableControlAction(0, 322, true) -- ESC key
            DisableControlAction(0, 200, true) -- ESC alternative
            
            if IsDisabledControlJustPressed(0, 322) or IsDisabledControlJustPressed(0, 200) then
                print('[WeatherSync] ESC pressed, closing UI...')
                isUIOpen = false
                SetNuiFocus(false, false)
                
                -- Send close message to NUI
                SendNUIMessage({
                    type = 'closeUI'
                })
                
                -- Extra safety to ensure focus is removed
                CreateThread(function()
                    Wait(100)
                    SetNuiFocus(false, false)
                    SetNuiFocusKeepInput(false)
                end)
            end
        end
    end
end)

-- Key mapping for UI
RegisterKeyMapping('weathersync_open', 'Open Weather Sync UI', 'keyboard', Config.UIKey)

-- Handle key press
RegisterCommand('weathersync_open', function()
    TriggerServerEvent('weathersync:requestUI')
end, false)

-- Events
RegisterNetEvent('weathersync:setWeather')
AddEventHandler('weathersync:setWeather', function(weather, mode, time)
    print('[WeatherSync] Received weather change: ' .. weather)
    currentWeather = weather
    
    -- Use server-provided values if available, otherwise use local config
    local useMode = mode or transitionMode
    local useTime = time or transitionTime
    
    if useMode == 'instant' then
        SetWeatherTypeNowPersist(weather)
        SetWeatherTypeNow(weather)
    else
        SetWeatherTypeOverTime(weather, useTime)
    end
end)

RegisterNetEvent('weathersync:updateTransitionMode')
AddEventHandler('weathersync:updateTransitionMode', function(mode, time)
    transitionMode = mode
    transitionTime = time
    print('[WeatherSync] Transition mode updated: ' .. mode .. ' (' .. time .. 's)')
end)

RegisterNetEvent('weathersync:updateTransitionMode')
AddEventHandler('weathersync:updateTransitionMode', function(mode, time)
    transitionMode = mode
    transitionTime = time
    print('[WeatherSync] Transition mode updated: ' .. mode)
end)

RegisterNetEvent('weathersync:openUI')
AddEventHandler('weathersync:openUI', function(data)
    if isUIOpen then return end
    
    print('[WeatherSync] Opening UI...')
    isUIOpen = true
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        type = 'openUI',
        data = data
    })
    
    print('[WeatherSync] UI opened successfully')
end)

RegisterNetEvent('weathersync:updateUI')
AddEventHandler('weathersync:updateUI', function(data)
    SendNUIMessage({
        type = 'updateWeatherData',
        data = data
    })
end)

RegisterNetEvent('weathersync:updateZones')
AddEventHandler('weathersync:updateZones', function(zones)
    weatherZones = zones
    SendNUIMessage({
        type = 'updateZones',
        data = zones
    })
end)

RegisterNetEvent('weathersync:syncTime')
AddEventHandler('weathersync:syncTime', function(hour, minute)
    NetworkOverrideClockTime(hour, minute, 0)
end)

RegisterNetEvent('weathersync:freezeTime')
AddEventHandler('weathersync:freezeTime', function(frozen)
    if frozen then
        local hour = GetClockHours()
        local minute = GetClockMinutes()
        NetworkOverrideClockTime(hour, minute, 0)
    else
        NetworkClearClockTimeOverride()
    end
end)

-- NUI Callbacks
RegisterNUICallback('closeUI', function(data, cb)
    print('[WeatherSync] Closing UI via callback...')
    isUIOpen = false
    SetNuiFocus(false, false)
    
    -- Force cursor to disappear
    CreateThread(function()
        Wait(100)
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
    end)
    
    cb('ok')
    print('[WeatherSync] UI closed successfully')
end)

RegisterNUICallback('setWeather', function(data, cb)
    TriggerServerEvent('weathersync:setWeather', data.weather)
    cb('ok')
end)

RegisterNUICallback('toggleSync', function(data, cb)
    TriggerServerEvent('weathersync:toggleSync')
    cb('ok')
end)

RegisterNUICallback('updateZone', function(data, cb)
    TriggerServerEvent('weathersync:updateZone', data.zone)
    cb('ok')
end)

RegisterNUICallback('deleteZone', function(data, cb)
    TriggerServerEvent('weathersync:deleteZone', data.zoneId)
    cb('ok')
end)

RegisterNUICallback('addZone', function(data, cb)
    TriggerServerEvent('weathersync:addZone', data.zone)
    cb('ok')
end)

RegisterNUICallback('getCurrentPosition', function(data, cb)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    cb({
        x = math.floor(coords.x),
        y = math.floor(coords.y),
        z = math.floor(coords.z)
    })
end)

RegisterNUICallback('setTime', function(data, cb)
    TriggerServerEvent('weathersync:setTime', data.preset)
    cb('ok')
end)

RegisterNUICallback('setCustomTime', function(data, cb)
    TriggerServerEvent('weathersync:setCustomTime', data.hour, data.minute)
    cb('ok')
end)

RegisterNUICallback('toggleFreezeTime', function(data, cb)
    TriggerServerEvent('weathersync:toggleFreezeTime')
    cb('ok')
end)

RegisterNUICallback('setTransitionMode', function(data, cb)
    TriggerServerEvent('weathersync:setTransitionMode', data.mode)
    cb('ok')
end)

-- Commands
RegisterCommand(Config.UICommand, function()
    TriggerServerEvent('weathersync:requestUI')
end, false)

-- Alternative command
RegisterCommand('ws', function()
    TriggerServerEvent('weathersync:requestUI')
end, false)

-- Debug command to test UI
RegisterCommand('testweatherui', function()
    print('[WeatherSync] Testing UI...')
    isUIOpen = true
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        type = 'openUI',
        data = {
            currentWeather = 'CLEAR',
            syncEnabled = true,
            nextWeatherChange = 15,
            zones = Config.WeatherZones,
            weatherTypes = Config.WeatherTypes
        }
    })
end, false)

-- Client debug command
RegisterCommand('weathersync_client_debug', function()
    print('[WeatherSync] Client debug - forcing UI open')
    TriggerServerEvent('weathersync:requestUI')
end, false)

-- Simple time commands
RegisterCommand('set', function(source, args)
    if not args[1] then return end
    
    local timeArg = args[1]:lower()
    
    if timeArg == 'day' then
        TriggerServerEvent('weathersync:setTime', 'day')
    elseif timeArg == 'night' then
        TriggerServerEvent('weathersync:setTime', 'night')
    elseif timeArg == '12am' or timeArg == 'midnight' then
        TriggerServerEvent('weathersync:setCustomTime', 0, 0)
    elseif timeArg == '12pm' or timeArg == 'noon' then
        TriggerServerEvent('weathersync:setCustomTime', 12, 0)
    end
end, false)

-- Exports
exports('getCurrentWeather', function()
    return currentWeather
end)

exports('isInWeatherZone', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    for _, zone in pairs(weatherZones) do
        if zone.enabled then
            local distance = #(playerCoords - zone.coords)
            if distance <= zone.radius then
                return true, zone
            end
        end
    end
    return false, nil
end)

-- Resource cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if isUIOpen then
            SetNuiFocus(false, false)
            isUIOpen = false
        end
    end
end)