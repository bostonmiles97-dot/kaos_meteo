# WeatherSync Installation Guide

## Prerequisites
- FiveM Server with ESX Legacy framework
- Admin permissions on the server

## Installation Steps

1. **Download/Clone the Resource**
   - Place the `weathersync` folder in your server's `resources` directory

2. **Add to server.cfg**
   ```
   ensure weathersync
   ```

3. **Configure the Resource**
   - Edit `config.lua` to customize settings:
     - Admin groups that can access the UI
     - Default weather and sync settings
     - Weather zones (optional)
     - UI key binding (default: F6)

4. **Start the Resource**
   - Restart your server or use: `start weathersync`

## Usage

### Opening the UI
- **Key**: Press `F6` (or configured key)
- **Commands**: 
  - `/weathersync` or `/ws`

### Admin Permissions
Only players with admin permissions can access the weather sync UI. Configure admin groups in `config.lua`:

```lua
Config.AdminGroups = {
    'admin',
    'superadmin',
    'mod' -- Add your custom groups here
}
```

## Troubleshooting

### UI Not Opening
1. **Check Admin Permissions**: Make sure your player group is in `Config.AdminGroups`
2. **Verify Resource**: Use `ensure weathersync` in server console
3. **Check Console**: Look for `[WeatherSync]` messages in both server and client console
4. **Try Commands**: 
   - `/weathersync` or `/ws` (requires admin)
   - `/weathersync_debug` (bypasses permissions for testing)
   - `/testweatherui` (client-side test)
5. **Check ESX**: Ensure ESX Legacy is running and loaded before WeatherSync

### Debug Commands
- `/weathersync_debug` - Opens UI bypassing permission checks
- `/testweatherui` - Client-side UI test
- `/weathersync_client_debug` - Forces client to request UI

### Weather Not Changing
1. Ensure auto-sync is enabled in the UI
2. Check if you're in a weather zone that overrides global weather
3. Verify weather type is valid in the console

### ESX Integration Issues
1. Make sure ESX Legacy is running before WeatherSync
2. Check that `@es_extended/imports.lua` path is correct
3. Verify your ESX version is compatible

## Console Commands (Server)
- `start weathersync` - Start the resource
- `stop weathersync` - Stop the resource  
- `restart weathersync` - Restart the resource

## Features
- ✅ Real-time weather synchronization
- ✅ Dynamic weather zones
- ✅ Admin permission system
- ✅ Modern web-based UI
- ✅ Weather presets
- ✅ Export functions for other resources

## Support
Check the server console for any error messages. All WeatherSync messages are prefixed with `[WeatherSync]`.