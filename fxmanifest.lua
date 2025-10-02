fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Weather Sync System for ESX Legacy'
version '1.0.0'

dependencies {
    'es_extended'
}

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

server_scripts {
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}