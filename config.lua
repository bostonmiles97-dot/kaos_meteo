Config = {}

-- Weather types available in GTA V
Config.WeatherTypes = {
    'EXTRASUNNY',
    'CLEAR', 
    'NEUTRAL',
    'SMOG',
    'FOGGY',
    'OVERCAST',
    'CLOUDS',
    'CLEARING',
    'RAIN',
    'THUNDER',
    'SNOW',
    'BLIZZARD',
    'SNOWLIGHT',
    'XMAS'
}

-- Default weather settings
Config.DefaultWeather = 'CLEAR'
Config.WeatherChangeInterval = 15 -- minutes
Config.SyncEnabled = true

-- Permission settings
Config.AdminGroups = {
    'admin',
    'superadmin'
}

-- Weather zones configuration
Config.WeatherZones = {
    {
        id = 'downtown',
        name = 'Downtown District',
        coords = vector3(215.0, -850.0, 30.0),
        radius = 500.0,
        weather = 'RAIN',
        enabled = true
    },
    {
        id = 'sandy_shores',
        name = 'Sandy Shores',
        coords = vector3(1800.0, 3700.0, 30.0),
        radius = 800.0,
        weather = 'EXTRASUNNY',
        enabled = true
    },
    {
        id = 'mount_chiliad',
        name = 'Mount Chiliad',
        coords = vector3(500.0, 5600.0, 800.0),
        radius = 1000.0,
        weather = 'SNOW',
        enabled = false
    }
}

-- UI Settings
Config.UIKey = 'F6' -- Key to open weather sync UI
Config.UICommand = 'weathersync' -- Command to open UI

-- Weather transition settings
Config.WeatherTransition = 'smooth' -- 'instant' or 'smooth'
Config.TransitionTime = 5.0 -- Seconds for smooth transition (if smooth is enabled)