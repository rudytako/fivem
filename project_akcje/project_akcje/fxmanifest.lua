-- Resource Metadata
fx_version 'cerulean'
games { 'gta5' }

author 'rudytako'
description 'Vinity: Roleplay action on internet buying'
version '1.0.0'

client_scripts {
    'client/client.lua',
    'config.lua'
}

ui_page('html/index.html')

files({
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/media/font/Bariol_Regular.otf',
    'html/media/font/Vision-Black.otf',
    'html/media/font/Vision-Bold.otf',
    'html/media/font/Vision-Heavy.otf'
})

server_script {
    'server/server.lua',
    'config.lua',
    '@mysql-async/lib/MySQL.lua'
}