local currentWeather = Config.DefaultWeather
local weatherSyncEnabled = Config.SyncEnabled
local weatherZones = Config.WeatherZones
local nextWeatherChange = Config.WeatherChangeInterval

print('[WeatherSync] Server script loaded successfully')

-- Wait for ESX to be ready
ESX = nil

CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Wait(0)
    end
    print('[WeatherSync] ESX integration ready')
end)

-- Initialize weather system
CreateThread(function()
    local lastWeatherChange = GetGameTimer()
    
    while true do
        if weatherSyncEnabled then
            local currentTime = GetGameTimer()
            if (currentTime - lastWeatherChange) >= (nextWeatherChange * 60000) then
                local randomWeather = Config.WeatherTypes[math.random(#Config.WeatherTypes)]
                SetWeatherGlobal(randomWeather)
                lastWeatherChange = currentTime
            end
            Wait(1000) -- Check every second instead of blocking
        else
            Wait(5000)
        end
    end
end)

-- Set global weather
function SetWeatherGlobal(weather)
    currentWeather = weather
    print('[WeatherSync] Broadcasting weather change to all clients: ' .. weather)
    TriggerClientEvent('weathersync:setWeather', -1, weather, transitionMode, transitionTime)
    TriggerClientEvent('weathersync:updateUI', -1, {
        currentWeather = weather,
        syncEnabled = weatherSyncEnabled,
        nextWeatherChange = nextWeatherChange
    })
end

-- Check if player has permission
function HasPermission(source)
    if not ESX then 
        print('[WeatherSync] ERROR: ESX not ready')
        return false 
    end
    
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then 
        print('[WeatherSync] ERROR: Player not found for source: ' .. tostring(source))
        return false 
    end
    
    local playerGroup = xPlayer.getGroup()
    if not playerGroup then
        print('[WeatherSync] WARNING: No group found for player: ' .. xPlayer.getName())
        -- Temporary: Allow access if no group is found (for testing)
        print('[WeatherSync] Allowing access for testing purposes')
        return true
    end
    
    print('[WeatherSync] Player group: ' .. tostring(playerGroup))
    
    for _, group in pairs(Config.AdminGroups) do
        if playerGroup == group then
            print('[WeatherSync] Permission granted for group: ' .. group)
            return true
        end
    end
    
    print('[WeatherSync] Permission denied. Player group: ' .. tostring(playerGroup))
    return false
end

-- Events
RegisterNetEvent('weathersync:requestUI')
AddEventHandler('weathersync:requestUI', function()
    local source = source
    print('[WeatherSync] UI requested by player: ' .. tostring(source))
    
    if not HasPermission(source) then
        print('[WeatherSync] Permission denied for player: ' .. tostring(source))
        TriggerClientEvent('esx:showNotification', source, 'You don\'t have permission to use this!')
        return
    end
    
    print('[WeatherSync] Opening UI for player: ' .. tostring(source))
    TriggerClientEvent('weathersync:openUI', source, {
        currentWeather = currentWeather,
        syncEnabled = weatherSyncEnabled,
        nextWeatherChange = nextWeatherChange,
        zones = weatherZones,
        weatherTypes = Config.WeatherTypes
    })
end)

RegisterNetEvent('weathersync:setWeather')
AddEventHandler('weathersync:setWeather', function(weather)
    local source = source
    
    if IsPlayerOnCooldown(source) then
        TriggerClientEvent('esx:showNotification', source, 'Please wait before changing weather again!')
        return
    end
    
    if not HasPermission(source) then
        TriggerClientEvent('esx:showNotification', source, 'You don\'t have permission to use this!')
        return
    end
    
    if not ValidateWeatherType(weather) then
        TriggerClientEvent('esx:showNotification', source, 'Invalid weather type!')
        return
    end
    
    SetWeatherGlobal(weather)
    TriggerClientEvent('esx:showNotification', source, 'Weather changed to: ' .. weather)
    print('[WeatherSync] Weather changed to ' .. weather .. ' by player: ' .. tostring(source))
end)

RegisterNetEvent('weathersync:toggleSync')
AddEventHandler('weathersync:toggleSync', function()
    local source = source
    
    if not HasPermission(source) then
        TriggerClientEvent('esx:showNotification', source, 'You don\'t have permission to use this!')
        return
    end
    
    weatherSyncEnabled = not weatherSyncEnabled
    TriggerClientEvent('weathersync:updateUI', -1, {
        currentWeather = currentWeather,
        syncEnabled = weatherSyncEnabled,
        nextWeatherChange = nextWeatherChange
    })
    
    local status = weatherSyncEnabled and 'enabled' or 'disabled'
    TriggerClientEvent('esx:showNotification', source, 'Weather sync ' .. status)
end)

RegisterNetEvent('weathersync:updateZone')
AddEventHandler('weathersync:updateZone', function(zoneData)
    local source = source
    
    if not HasPermission(source) then
        TriggerClientEvent('esx:showNotification', source, 'You don\'t have permission to use this!')
        return
    end
    
    if not ValidateZoneData(zoneData) then
        TriggerClientEvent('esx:showNotification', source, 'Invalid zone data!')
        return
    end
    
    -- Update zone in the zones table
    local zoneFound = false
    for i, zone in ipairs(weatherZones) do
        if zone.id == zoneData.id then
            weatherZones[i] = zoneData
            zoneFound = true
            break
        end
    end
    
    if not zoneFound then
        TriggerClientEvent('esx:showNotification', source, 'Zone not found!')
        return
    end
    
    -- Notify all clients about zone update
    TriggerClientEvent('weathersync:updateZones', -1, weatherZones)
    TriggerClientEvent('esx:showNotification', source, 'Zone updated: ' .. zoneData.name)
end)

RegisterNetEvent('weathersync:deleteZone')
AddEventHandler('weathersync:deleteZone', function(zoneId)
    local source = source
    
    if not HasPermission(source) then
        TriggerClientEvent('esx:showNotification', source, 'You don\'t have permission to use this!')
        return
    end
    
    -- Remove zone from the zones table
    for i, zone in ipairs(weatherZones) do
        if zone.id == zoneId then
            table.remove(weatherZones, i)
            break
        end
    end
    
    -- Notify all clients about zone deletion
    TriggerClientEvent('weathersync:updateZones', -1, weatherZones)
    TriggerClientEvent('esx:showNotification', source, 'Zone deleted')
end)

RegisterNetEvent('weathersync:addZone')
AddEventHandler('weathersync:addZone', function(zoneData)
    local source = source
    
    if not HasPermission(source) then
        TriggerClientEvent('esx:showNotification', source, 'You don\'t have permission to use this!')
        return
    end
    
    if not ValidateZoneData(zoneData) then
        TriggerClientEvent('esx:showNotification', source, 'Invalid zone data!')
        return
    end
    
    -- Check for duplicate zone IDs
    for _, zone in ipairs(weatherZones) do
        if zone.id == zoneData.id then
            TriggerClientEvent('esx:showNotification', source, 'Zone ID already exists!')
            return
        end
    end
    
    table.insert(weatherZones, zoneData)
    
    -- Notify all clients about new zone
    TriggerClientEvent('weathersync:updateZones', -1, weatherZones)
    TriggerClientEvent('esx:showNotification', source, 'Zone added: ' .. zoneData.name)
end)

-- Utility functions
function table.contains(tbl, element)
    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

-- Input validation
function ValidateWeatherType(weather)
    return weather and type(weather) == 'string' and table.contains(Config.WeatherTypes, weather)
end

function ValidateZoneData(zoneData)
    return zoneData and 
           type(zoneData.id) == 'string' and 
           type(zoneData.name) == 'string' and 
           ValidateWeatherType(zoneData.weather) and
           type(zoneData.radius) == 'number' and zoneData.radius > 0
end

-- Commands
RegisterCommand('weathersync', function(source, args, rawCommand)
    if source == 0 then
        print('This command can only be used by players')
        return
    end
    
    TriggerServerEvent('weathersync:requestUI')
end, false)

-- Alternative short command
RegisterCommand('ws', function(source, args, rawCommand)
    if source == 0 then
        print('This command can only be used by players')
        return
    end
    
    TriggerServerEvent('weathersync:requestUI')
end, false)

-- Time control
local timeFrozen = false
local frozenHour = 12
local frozenMinute = 0

-- Weather transition mode
local transitionMode = Config.WeatherTransition or 'smooth'
local transitionTime = Config.TransitionTime or 5.0

RegisterNetEvent('weathersync:setTransitionMode')
AddEventHandler('weathersync:setTransitionMode', function(mode)
    local source = source
    
    if not HasPermission(source) then
        TriggerClientEvent('esx:showNotification', source, 'You don\'t have permission to use this!')
        return
    end
    
    if mode ~= 'instant' and mode ~= 'smooth' then
        TriggerClientEvent('esx:showNotification', source, 'Invalid transition mode!')
        return
    end
    
    transitionMode = mode
    TriggerClientEvent('weathersync:updateTransitionMode', -1, mode, transitionTime)
    TriggerClientEvent('esx:showNotification', source, 'Transition mode: ' .. mode)
end)

RegisterNetEvent('weathersync:setTime')
AddEventHandler('weathersync:setTime', function(preset)
    local source = source
    
    if not HasPermission(source) then
        TriggerClientEvent('esx:showNotification', source, 'You don\'t have permission to use this!')
        return
    end
    
    local hour, minute = 12, 0
    
    if preset == 'day' then
        hour, minute = 12, 0
    elseif preset == 'night' then
        hour, minute = 0, 0
    elseif preset == 'noon' then
        hour, minute = 12, 0
    elseif preset == 'midnight' then
        hour, minute = 0, 0
    end
    
    TriggerClientEvent('weathersync:syncTime', -1, hour, minute)
    TriggerClientEvent('esx:showNotification', source, 'Time set to ' .. string.format('%02d:%02d', hour, minute))
end)

RegisterNetEvent('weathersync:setCustomTime')
AddEventHandler('weathersync:setCustomTime', function(hour, minute)
    local source = source
    
    if not HasPermission(source) then
        TriggerClientEvent('esx:showNotification', source, 'You don\'t have permission to use this!')
        return
    end
    
    hour = tonumber(hour) or 12
    minute = tonumber(minute) or 0
    
    -- Validate time
    if hour < 0 or hour > 23 or minute < 0 or minute > 59 then
        TriggerClientEvent('esx:showNotification', source, 'Invalid time! Hour: 0-23, Minute: 0-59')
        return
    end
    
    TriggerClientEvent('weathersync:syncTime', -1, hour, minute)
    TriggerClientEvent('esx:showNotification', source, 'Time set to ' .. string.format('%02d:%02d', hour, minute))
end)

RegisterNetEvent('weathersync:toggleFreezeTime')
AddEventHandler('weathersync:toggleFreezeTime', function()
    local source = source
    
    if not HasPermission(source) then
        TriggerClientEvent('esx:showNotification', source, 'You don\'t have permission to use this!')
        return
    end
    
    timeFrozen = not timeFrozen
    TriggerClientEvent('weathersync:freezeTime', -1, timeFrozen)
    
    local status = timeFrozen and 'frozen' or 'unfrozen'
    TriggerClientEvent('esx:showNotification', source, 'Time ' .. status)
end)

RegisterNetEvent('weathersync:setTransitionMode')
AddEventHandler('weathersync:setTransitionMode', function(mode)
    local source = source
    
    if not HasPermission(source) then
        TriggerClientEvent('esx:showNotification', source, 'You don\'t have permission to use this!')
        return
    end
    
    if mode == 'instant' or mode == 'smooth' then
        transitionMode = mode
        TriggerClientEvent('weathersync:updateTransitionMode', -1, mode, transitionTime)
        TriggerClientEvent('esx:showNotification', source, 'Weather transition set to: ' .. mode)
    end
end)

-- Export functions for other resources
exports('getCurrentWeather', function()
    return currentWeather
end)

exports('setWeather', function(weather)
    if table.contains(Config.WeatherTypes, weather) then
        SetWeatherGlobal(weather)
        return true
    end
    return false
end)

-- Rate limiting for weather changes
local playerCooldowns = {}
local COOLDOWN_TIME = 5000 -- 5 seconds

function IsPlayerOnCooldown(source)
    local currentTime = GetGameTimer()
    if playerCooldowns[source] and (currentTime - playerCooldowns[source]) < COOLDOWN_TIME then
        return true
    end
    playerCooldowns[source] = currentTime
    return false
end

-- Cleanup disconnected players from cooldown tracking
AddEventHandler('playerDropped', function()
    local source = source
    if playerCooldowns[source] then
        playerCooldowns[source] = nil
    end
end)