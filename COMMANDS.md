# WeatherSync - Command Reference

## UI Commands

| Command | Description | Permission |
|---------|-------------|------------|
| `/weathersync` | Open weather sync UI | Admin |
| `/ws` | Open weather sync UI (short) | Admin |
| `/weathersync_debug` | Open UI (bypass permissions) | None |
| `/testweatherui` | Test UI client-side | None |

## Time Commands

| Command | Time Set | Description |
|---------|----------|-------------|
| `/set day` | 12:00 | Set time to day (noon) |
| `/set night` | 00:00 | Set time to night (midnight) |
| `/set 12am` | 00:00 | Set time to midnight |
| `/set 12pm` | 12:00 | Set time to noon |
| `/set noon` | 12:00 | Set time to noon |
| `/set midnight` | 00:00 | Set time to midnight |

**Note**: All `/set` commands require admin permissions

## UI Features

### Home Tab
- **Server Information**: Sync status, uptime, next weather change
- **Current Weather**: Display current weather and time
- **Time Controls**: 
  - Quick buttons: Day, Night, Noon, Midnight
  - Custom time: Hour (0-23) and Minute (0-59) inputs
  - Freeze/Unfreeze time button
- **Weather Impact**: Road condition, visibility, wind speed

### Weather Tab
- **Weather Grid**: Click any weather type to change
- **Weather Presets**: Quick scenarios (Chase Scene, Night Ops, etc.)
- **Auto Sync Toggle**: Enable/disable automatic weather changes

### Zones Tab
- **Zone Management**: Create, edit, delete weather zones
- **Zone Stats**: Active zones count and total coverage
- **Zone Controls**: Enable/disable individual zones

## Admin Groups

Configure in `config.lua`:
```lua
Config.AdminGroups = {
    'admin',
    'superadmin'
}
```

## Exports (For Other Resources)

### Server-side
```lua
-- Get current weather
local weather = exports.weathersync:getCurrentWeather()

-- Set weather programmatically
local success = exports.weathersync:setWeather('RAIN')
```

### Client-side
```lua
-- Get current weather
local weather = exports.weathersync:getCurrentWeather()

-- Check if player is in a weather zone
local inZone, zoneData = exports.weathersync:isInWeatherZone()
```

## Available Weather Types

- EXTRASUNNY
- CLEAR
- NEUTRAL
- SMOG
- FOGGY
- OVERCAST
- CLOUDS
- CLEARING
- RAIN
- THUNDER
- SNOW
- BLIZZARD
- SNOWLIGHT
- XMAS

## Quick Start

1. **Open UI**: `/weathersync` or `/ws`
2. **Change Weather**: Click weather type in Weather tab
3. **Set Time**: Use buttons or inputs in Home tab
4. **Quick Time**: `/set day` or `/set night`
5. **Close UI**: Press ESC

## Troubleshooting

- **UI won't open**: Check admin permissions or use `/weathersync_debug`
- **Weather not syncing**: Check server console for error messages
- **Time not changing**: Verify admin permissions
- **Commands not working**: Make sure resource is started: `ensure weathersync`
