# WeatherSync - Recent Fixes

## Issues Fixed

### 1. Stack Overflow Error (RangeError: Maximum call stack size exceeded)
**Problem**: `GetParentResourceName()` was calling itself recursively
**Fix**: Changed to parse the resource name from the NUI URL
**Location**: `html/script.js` line ~465

### 2. ESC Key Not Working / UI Stuck
**Problem**: Multiple ESC handlers conflicting and NUI focus not being released
**Fix**: 
- Removed JavaScript ESC handler (handled in Lua)
- Enhanced Lua ESC handler with multiple control disables
- Added extra safety to ensure NUI focus is released
**Location**: `client/main.lua` ESC key handler section

### 3. Syntax Error in Client Script
**Problem**: Malformed comment `--` followed by text on next line
**Fix**: Changed to proper comment format `-- Comment text`
**Location**: `client/main.lua` line ~217

### 4. UI Buttons Not Working
**Problem**: Stack overflow prevented fetch calls from completing
**Fix**: Fixed `GetParentResourceName()` function (see #1)

## Testing After Fixes

1. **Restart the resource**: `restart weathersync`
2. **Open UI**: Use `/weathersync` or `/weathersync_debug`
3. **Test buttons**: Click weather types, toggle sync, etc.
4. **Test ESC**: Press ESC to close - should work immediately
5. **Verify movement**: After closing UI, you should be able to move normally

## Console Output Should Show

```
[WeatherSync] Client script loaded successfully
[WeatherSync] Server script loaded successfully
[WeatherSync] ESX integration ready
[WeatherSync] Opening UI...
[WeatherSync] UI opened successfully
[WeatherSync] Opening UI with data: [object Object]
```

## If Issues Persist

1. Clear your FiveM cache
2. Ensure no other resources are conflicting
3. Check that ESX Legacy is properly installed
4. Use `/weathersync_debug` to bypass permissions
5. Check both server and client console for errors

## Debug Commands

- `/weathersync` - Normal command (requires admin)
- `/weathersync_debug` - Bypasses permissions
- `/testweatherui` - Client-side test
- `/ws` - Short alias for weathersync

## Known Working Configuration

- FiveM Server Build: Latest
- ESX Legacy: Latest version
- Resource folder: `resources/weathersync/`
- Server.cfg: `ensure weathersync`
