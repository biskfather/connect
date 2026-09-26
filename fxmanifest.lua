fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'connect'
author 'biskfather'
description 'Custom QB-Core "Boarding Pass" connecting screen (Adaptive Card deferrals) with ban/whitelist checks, multi-language support and an in-game NUI replay.'
version '1.0.0'
repository 'https://github.com/biskfather/connect'

shared_scripts {
    'config.lua',
    'locales/*.lua',
}

server_scripts {
    'server/card.lua',
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}
