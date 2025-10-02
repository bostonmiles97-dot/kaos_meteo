// Global variables
let currentWeatherData = {
    currentWeather: 'CLEAR',
    syncEnabled: true,
    nextWeatherChange: 15,
    zones: [],
    weatherTypes: []
};

let activeTab = 'home';
let requestQueue = new Map(); // Debounce requests

// Weather icons mapping
const weatherIcons = {
    'EXTRASUNNY': '<path d="M12 2v2M12 20v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M2 12h2M20 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/><circle cx="12" cy="12" r="5"/>',
    'CLEAR': '<path d="M12 2v2M12 20v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M2 12h2M20 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/><circle cx="12" cy="12" r="5"/>',
    'CLOUDS': '<path d="M17.5 19H9a7 7 0 1 1 6.71-9h1.79a4.5 4.5 0 1 1 0 9Z"/>',
    'OVERCAST': '<path d="M17.5 19H9a7 7 0 1 1 6.71-9h1.79a4.5 4.5 0 1 1 0 9Z"/>',
    'RAIN': '<path d="M17.5 19H9a7 7 0 1 1 6.71-9h1.79a4.5 4.5 0 1 1 0 9Z"/><path d="M16 14v6M8 14v6M12 16v4"/>',
    'THUNDER': '<path d="M17.5 19H9a7 7 0 1 1 6.71-9h1.79a4.5 4.5 0 1 1 0 9Z"/><path d="M13 10V3L8 14h5v7l5-11h-5Z"/>',
    'CLEARING': '<path d="M17.5 19H9a7 7 0 1 1 6.71-9h1.79a4.5 4.5 0 1 1 0 9Z"/><path d="M8 19v1M8 6v1M1 13h1M16 13h1M3 7l1 1M14 18l1 1M3 19l1-1M14 8l1-1"/>',
    'NEUTRAL': '<path d="M17.5 19H9a7 7 0 1 1 6.71-9h1.79a4.5 4.5 0 1 1 0 9Z"/>',
    'SNOW': '<path d="M17.5 19H9a7 7 0 1 1 6.71-9h1.79a4.5 4.5 0 1 1 0 9Z"/><path d="M2 17h2M22 17h2M12 16v2M12 6v2M16 13l-4-4-4 4M16 21l-4-4-4 4"/>',
    'BLIZZARD': '<path d="M17.5 19H9a7 7 0 1 1 6.71-9h1.79a4.5 4.5 0 1 1 0 9Z"/><path d="M2 17h2M22 17h2M12 16v2M12 6v2M16 13l-4-4-4 4M16 21l-4-4-4 4"/>',
    'SNOWLIGHT': '<path d="M17.5 19H9a7 7 0 1 1 6.71-9h1.79a4.5 4.5 0 1 1 0 9Z"/><path d="M2 17h2M22 17h2M12 16v2M12 6v2M16 13l-4-4-4 4M16 21l-4-4-4 4"/>',
    'XMAS': '<path d="M17.5 19H9a7 7 0 1 1 6.71-9h1.79a4.5 4.5 0 1 1 0 9Z"/><path d="M2 17h2M22 17h2M12 16v2M12 6v2M16 13l-4-4-4 4M16 21l-4-4-4 4"/>',
    'FOGGY': '<path d="M4 14.899A7 7 0 1 1 15.71 8h1.79a4.5 4.5 0 0 1 2.5 8.242M8 19v1M8 6v1M1 13h1M16 13h1"/>'
};

// Initialize UI
document.addEventListener('DOMContentLoaded', function () {
    console.log('[WeatherSync] DOM loaded, initializing...');

    // Hide UI initially
    document.getElementById('app').classList.add('hidden');

    // Set up event listeners
    setupEventListeners();

    // Initialize current time display
    updateCurrentTime();
    setInterval(updateCurrentTime, 1000);

    // Test mode - uncomment for testing without FiveM
    testMode();

    console.log('[WeatherSync] Initialization complete');
});

// Test mode function for debugging
function testMode() {
    console.log('[WeatherSync] Running in test mode');
    setTimeout(() => {
        openUI({
            currentWeather: 'CLEAR',
            syncEnabled: true,
            nextWeatherChange: 15,
            zones: [
                {
                    id: '1',
                    name: 'Test Zone',
                    weather: 'RAIN',
                    radius: 500,
                    coords: { x: 100, y: 200, z: 30 },
                    enabled: true
                }
            ],
            weatherTypes: ['CLEAR', 'RAIN', 'THUNDER', 'SNOW', 'FOGGY']
        });
    }, 1000);
}

// Setup event listeners
function setupEventListeners() {
    // Listen for messages from FiveM
    window.addEventListener('message', function (event) {
        const data = event.data;

        switch (data.type) {
            case 'openUI':
                openUI(data.data);
                break;
            case 'updateWeatherData':
                updateWeatherData(data.data);
                break;
            case 'updateZones':
                updateZones(data.data);
                break;
            case 'closeUI':
                document.getElementById('app').classList.add('hidden');
                break;
        }
    });

    // ESC key is handled by Lua client script, not here

    // Add click event listeners for buttons that exist on page load
    document.addEventListener('click', function (event) {
        // Handle navigation buttons
        if (event.target.closest('.nav-btn')) {
            const btn = event.target.closest('.nav-btn');
            const tab = btn.dataset.tab;
            if (tab) {
                switchTab(tab);
            }
        }

        // Handle close button
        if (event.target.closest('.close-btn')) {
            closeUI();
        }
    });
}

// Open UI
function openUI(data) {
    console.log('[WeatherSync] Opening UI with data:', data);
    currentWeatherData = data;
    document.getElementById('app').classList.remove('hidden');

    // Update all UI elements
    updateWeatherData(data);
    updateZones(data.zones || []);
    populateWeatherGrid(data.weatherTypes || []);

    // Switch to home tab
    switchTab('home');
    console.log('[WeatherSync] UI opened successfully');
}

// Close UI
function closeUI() {
    console.log('[WeatherSync] Closing UI...');
    document.getElementById('app').classList.add('hidden');

    // Send close message to FiveM
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).catch(err => {
        console.error('[WeatherSync] Error closing UI:', err);
    });
}

// Switch tabs
function switchTab(tabName) {
    activeTab = tabName;

    // Update nav buttons
    document.querySelectorAll('.nav-btn').forEach(btn => {
        btn.classList.remove('active');
        if (btn.dataset.tab === tabName) {
            btn.classList.add('active');
        }
    });

    // Update tab content
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    document.getElementById(`${tabName}-tab`).classList.add('active');
}

// Update weather data
function updateWeatherData(data) {
    // Update current weather display
    document.getElementById('current-weather').textContent = data.currentWeather;
    document.getElementById('sync-status').textContent = data.syncEnabled ? 'Active' : 'Inactive';
    document.getElementById('next-change').textContent = `${data.nextWeatherChange}m`;

    // Update sync button
    const syncBtn = document.getElementById('sync-toggle');
    const autoSyncBtn = document.getElementById('auto-sync-btn');

    if (data.syncEnabled) {
        syncBtn.textContent = 'Sync Enabled';
        syncBtn.className = 'btn btn-success';
        autoSyncBtn.textContent = 'Auto Sync';
        autoSyncBtn.className = 'btn btn-preset btn-success';
    } else {
        syncBtn.textContent = 'Manual Mode';
        syncBtn.className = 'btn btn-danger';
        autoSyncBtn.textContent = 'Manual Mode';
        autoSyncBtn.className = 'btn btn-preset btn-danger';
    }

    // Update weather icon
    updateWeatherIcon(data.currentWeather);

    // Update active weather button
    updateActiveWeatherButton(data.currentWeather);
}

// Update weather icon
function updateWeatherIcon(weather) {
    const iconElement = document.querySelector('.current-weather-icon');
    if (iconElement && weatherIcons[weather]) {
        iconElement.innerHTML = weatherIcons[weather];
    }
}

// Populate weather grid
function populateWeatherGrid(weatherTypes) {
    const grid = document.getElementById('weather-grid');
    grid.innerHTML = '';

    weatherTypes.forEach(weather => {
        const button = document.createElement('button');
        button.className = 'weather-btn';
        button.onclick = () => setWeather(weather);
        button.innerHTML = `
            <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                ${weatherIcons[weather] || weatherIcons['CLEAR']}
            </svg>
            <span>${weather}</span>
        `;
        grid.appendChild(button);
    });
}

// Update active weather button
function updateActiveWeatherButton(currentWeather) {
    document.querySelectorAll('.weather-btn').forEach(btn => {
        btn.classList.remove('active');
        if (btn.querySelector('span').textContent === currentWeather) {
            btn.classList.add('active');
        }
    });
}

// Update zones
function updateZones(zones) {
    currentWeatherData.zones = zones;

    // Update zone stats
    const activeZones = zones.filter(z => z.enabled).length;
    const totalCoverage = zones.reduce((acc, z) => acc + (z.enabled ? z.radius : 0), 0);

    document.getElementById('active-zones').textContent = `${activeZones} / ${zones.length}`;
    document.getElementById('total-coverage').textContent = `${totalCoverage}m`;

    // Update zones list
    const zonesList = document.getElementById('zones-list');
    zonesList.innerHTML = '';

    if (zones.length === 0) {
        zonesList.innerHTML = `
            <div style="text-align: center; padding: 3rem 0;">
                <svg class="icon" style="width: 3rem; height: 3rem; color: #475569; margin: 0 auto 0.75rem;" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/>
                    <circle cx="12" cy="10" r="3"/>
                </svg>
                <p style="color: #94a3b8; font-size: 0.875rem;">No zones created yet</p>
                <p style="color: #64748b; font-size: 0.75rem; margin-top: 0.25rem;">Click "Add Zone" to create your first weather zone</p>
            </div>
        `;
        return;
    }

    zones.forEach(zone => {
        const zoneCard = document.createElement('div');
        zoneCard.className = `zone-card ${zone.enabled ? 'active' : ''}`;
        zoneCard.innerHTML = `
            <div class="zone-header">
                <div class="zone-info">
                    <div class="zone-icon ${zone.enabled ? 'active' : 'inactive'}">
                        <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                            ${weatherIcons[zone.weather] || weatherIcons['CLEAR']}
                        </svg>
                    </div>
                    <div class="zone-details">
                        <h3>${zone.name}</h3>
                        <p>${zone.weather} • ${zone.radius}m radius</p>
                    </div>
                </div>
                <div class="zone-actions">
                    <button class="zone-action-btn edit" onclick="editZone('${zone.id}')">
                        <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
                            <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
                        </svg>
                    </button>
                    <button class="zone-action-btn delete" onclick="deleteZone('${zone.id}')">
                        <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                            <path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
                        </svg>
                    </button>
                </div>
            </div>
            <div class="zone-coords">
                <div class="coord-item">
                    <p>X Coord</p>
                    <p>${zone.coordinates ? zone.coordinates.x : zone.coords.x}</p>
                </div>
                <div class="coord-item">
                    <p>Y Coord</p>
                    <p>${zone.coordinates ? zone.coordinates.y : zone.coords.y}</p>
                </div>
                <div class="coord-item">
                    <p>Z Coord</p>
                    <p>${zone.coordinates ? zone.coordinates.z : zone.coords.z}</p>
                </div>
            </div>
            <div class="zone-weather-selector">
                <label style="font-size: 0.75rem; color: #94a3b8; margin-bottom: 0.5rem; display: block;">Zone Weather:</label>
                <select class="zone-weather-select" onchange="updateZoneWeather('${zone.id}', this.value)">
                    ${currentWeatherData.weatherTypes.map(w => `
                        <option value="${w}" ${zone.weather === w ? 'selected' : ''}>${w}</option>
                    `).join('')}
                </select>
            </div>
            <button class="btn zone-toggle ${zone.enabled ? 'btn-success' : 'btn-secondary'}" onclick="toggleZone('${zone.id}')">
                ${zone.enabled ? 'Zone Active' : 'Zone Disabled'}
            </button>
        `;
        zonesList.appendChild(zoneCard);
    });
}

// Debounced request helper
function debounceRequest(key, fn, delay = 300) {
    if (requestQueue.has(key)) {
        clearTimeout(requestQueue.get(key));
    }
    requestQueue.set(key, setTimeout(() => {
        fn();
        requestQueue.delete(key);
    }, delay));
}

// Weather functions
function setWeather(weather) {
    console.log('[WeatherSync] Setting weather to:', weather);
    
    // Validate weather type
    if (!currentWeatherData.weatherTypes || !currentWeatherData.weatherTypes.includes(weather)) {
        console.error('[WeatherSync] Invalid weather type:', weather);
        return;
    }
    
    debounceRequest('setWeather', () => {
        fetch(`https://${GetParentResourceName()}/setWeather`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ weather: weather })
        }).catch(err => console.error('[WeatherSync] Error setting weather:', err));
    });
}

function setWeatherPreset(weather) {
    console.log('[WeatherSync] Setting weather preset:', weather);
    setWeather(weather);
}

function setTransitionMode(mode) {
    console.log('[WeatherSync] Setting transition mode:', mode);
    
    // Update button states
    const instantBtn = document.getElementById('transition-instant-btn');
    const smoothBtn = document.getElementById('transition-smooth-btn');
    
    if (mode === 'instant') {
        instantBtn.classList.add('btn-primary');
        smoothBtn.classList.remove('btn-primary');
    } else {
        smoothBtn.classList.add('btn-primary');
        instantBtn.classList.remove('btn-primary');
    }
    
    fetch(`https://${GetParentResourceName()}/setTransitionMode`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ mode: mode })
    }).catch(err => console.error('[WeatherSync] Error setting transition mode:', err));
}

function toggleSync() {
    console.log('[WeatherSync] Toggling sync');
    fetch(`https://${GetParentResourceName()}/toggleSync`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).catch(err => console.error('[WeatherSync] Error toggling sync:', err));
}

function forceUpdate() {
    console.log('[WeatherSync] Force updating weather');
    fetch(`https://${GetParentResourceName()}/setWeather`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ weather: currentWeatherData.currentWeather })
    }).catch(err => console.error('[WeatherSync] Error force updating:', err));
}

// Zone functions
function addNewZone() {
    console.log('[WeatherSync] Adding new zone');
    // Get current player position
    fetch(`https://${GetParentResourceName()}/getCurrentPosition`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).then(response => response.json()).then(coords => {
        const newZone = {
            id: Date.now().toString(),
            name: 'New Zone',
            weather: 'CLEAR',
            radius: 500,
            coordinates: coords,
            enabled: false
        };

        fetch(`https://${GetParentResourceName()}/addZone`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ zone: newZone })
        });
    }).catch(err => console.error('[WeatherSync] Error adding zone:', err));
}

function editZone(zoneId) {
    console.log('[WeatherSync] Editing zone:', zoneId);
    // For now, just toggle the zone
    // In a full implementation, you'd open an edit modal
    toggleZone(zoneId);
}

function deleteZone(zoneId) {
    console.log('[WeatherSync] Deleting zone:', zoneId);
    fetch(`https://${GetParentResourceName()}/deleteZone`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ zoneId: zoneId })
    }).catch(err => console.error('[WeatherSync] Error deleting zone:', err));
}

function updateZoneWeather(zoneId, weather) {
    console.log('[WeatherSync] Updating zone weather:', zoneId, weather);
    const zone = currentWeatherData.zones.find(z => z.id === zoneId);
    if (zone) {
        zone.weather = weather;
        
        debounceRequest(`updateZoneWeather_${zoneId}`, () => {
            fetch(`https://${GetParentResourceName()}/updateZone`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ zone: zone })
            }).catch(err => console.error('[WeatherSync] Error updating zone weather:', err));
        });
    }
}

function toggleZone(zoneId) {
    console.log('[WeatherSync] Toggling zone:', zoneId);
    const zone = currentWeatherData.zones.find(z => z.id === zoneId);
    if (zone) {
        zone.enabled = !zone.enabled;

        fetch(`https://${GetParentResourceName()}/updateZone`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ zone: zone })
        }).catch(err => console.error('[WeatherSync] Error updating zone:', err));
    }
}

// Time functions
function setTime(preset) {
    console.log('[WeatherSync] Setting time preset:', preset);
    fetch(`https://${GetParentResourceName()}/setTime`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ preset: preset })
    }).catch(err => console.error('[WeatherSync] Error setting time:', err));
}

function setCustomTime() {
    const hour = parseInt(document.getElementById('time-hour').value) || 12;
    const minute = parseInt(document.getElementById('time-minute').value) || 0;
    
    console.log('[WeatherSync] Setting custom time:', hour, ':', minute);
    fetch(`https://${GetParentResourceName()}/setCustomTime`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ hour: hour, minute: minute })
    }).catch(err => console.error('[WeatherSync] Error setting custom time:', err));
}

function toggleFreezeTime() {
    console.log('[WeatherSync] Toggling freeze time');
    fetch(`https://${GetParentResourceName()}/toggleFreezeTime`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).catch(err => console.error('[WeatherSync] Error toggling freeze time:', err));
}

// Update current time display with caching
let lastTimeString = '';
function updateCurrentTime() {
    const now = new Date();
    const timeString = now.toLocaleTimeString('en-US', {
        hour12: false,
        hour: '2-digit',
        minute: '2-digit'
    });

    // Only update DOM if time changed
    if (timeString !== lastTimeString) {
        const timeElement = document.getElementById('current-time');
        if (timeElement) {
            timeElement.textContent = timeString;
            lastTimeString = timeString;
        }
    }
}

// Utility function to get parent resource name
function GetParentResourceName() {
    try {
        if (window.location.href.includes('://nui_')) {
            const match = window.location.href.match(/nui_(.+?)\//);
            if (match && match[1]) {
                return match[1];
            }
        }
    } catch (e) {
        console.error('[WeatherSync] Error getting resource name:', e);
    }
    return 'weathersync';
}