# Weather Sync System for FiveM ESX Legacy

A comprehensive weather management system for FiveM servers running ESX Legacy framework. This resource provides a modern web-based UI for managing server weather, creating weather zones, and controlling weather synchronization.

## Features

- **Modern Web UI**: Clean, responsive interface built with HTML5, CSS3, and JavaScript
- **Weather Control**: Set weather types, toggle auto-sync, and manage weather presets
- **Weather Zones**: Create dynamic weather zones across the map with custom weather patterns
- **ESX Integration**: Full integration with ESX Legacy framework
- **Permission System**: Admin-only access with configurable permission groups
- **Real-time Updates**: Live weather updates across all connected players

## Installation

1. Download or clone this repository to your FiveM server's `resources` folder
2. Rename the folder to `weathersync` (or your preferred name)
3. Add `ensure weathersync` to your `server.cfg`
4. Configure the resource in `config.lua` (optional)
5. Restart your server or start the resource with `start weathersync`

## Configuration

Edit `config.lua` to customize the resource:

```lua
-- Weather types available in GTA V
Config.WeatherTypes = {
    'EXTRASUNNY', 'CLEAR', 'NEUTRAL', 'SMOG', 'FOGGY',
    'OVERCAST', 'CLOUDS', 'CLEARING', 'RAIN', 'THUNDER',
    'SNOW', 'BLIZZARD', 'SNOWLIGHT', 'XMAS'
}

-- Default settings
Config.DefaultWeather = 'CLEAR'
Config.WeatherChangeInterval = 15 -- minutes
Config.SyncEnabled = true

-- Permission settings
Config.AdminGroups = {
    'admin',
    'superadmin'
}

-- UI Settings
Config.UIKey = 'F6' -- Key to open weather sync UI
Config.UICommand = 'weathersync' -- Command to open UI
```

## Usage

### Opening the UI
- **Key**: Press `F6` (configurable)
- **Command**: `/weathersync`

### Weather Management
1. **Home Tab**: View server information, current weather status, and weather impact
2. **Weather Tab**: Select weather types, use presets, and toggle auto-sync
3. **Zones Tab**: Create and manage weather zones across the map

### Weather Zones
- Create zones with custom weather patterns
- Set zone radius and coordinates
- Enable/disable zones individually
- Zones override global weather when players are inside them

### Commands
- `/weathersync` - Open the weather sync UI (admin only)

### Exports

#### Server-side
```lua
-- Get current weather
local weather = exports.weathersync:getCurrentWeather()

-- Set weather programmatically
local success = exports.weathersync:setWeather('RAIN')
```

#### Client-side
```lua
-- Get current weather
local weather = exports.weathersync:getCurrentWeather()

-- Check if player is in a weather zone
local inZone, zoneData = exports.weathersync:isInWeatherZone()
```

## Permissions

Only players with admin permissions can access the weather sync UI. Configure admin groups in `config.lua`:

```lua
Config.AdminGroups = {
    'admin',
    'superadmin',
    'mod' -- Add your custom groups here
}
```

## Weather Types

The following weather types are supported:
- `EXTRASUNNY` - Extra sunny weather
- `CLEAR` - Clear skies
- `NEUTRAL` - Neutral weather
- `SMOG` - Smoggy conditions
- `FOGGY` - Foggy weather
- `OVERCAST` - Overcast skies
- `CLOUDS` - Cloudy weather
- `CLEARING` - Clearing weather
- `RAIN` - Rainy weather
- `THUNDER` - Thunderstorm
- `SNOW` - Snowy weather
- `BLIZZARD` - Blizzard conditions
- `SNOWLIGHT` - Light snow
- `XMAS` - Christmas weather

## Troubleshooting

### UI Not Opening
1. Check if you have admin permissions
2. Verify the resource is started: `ensure weathersync`
3. Check server console for errors

### Weather Not Changing
1. Ensure auto-sync is enabled
2. Check if you're in a weather zone that overrides global weather
3. Verify weather type is valid

### Zone Issues
1. Make sure zone coordinates are correct
2. Check zone radius settings
3. Ensure zone is enabled

## Support

For support, issues, or feature requests, please create an issue on the GitHub repository.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

- Built for FiveM ESX Legacy
- UI inspired by modern web design principles
- Weather system based on GTA V native weather types