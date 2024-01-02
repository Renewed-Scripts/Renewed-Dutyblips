fx_version 'cerulean'
game 'gta5'

use_experimental_fxv2_oal 'yes'
lua54        'yes'

description 'Renewed Dutyblips'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'client/main.lua'
}
server_scripts {
    'server/main.lua',
    'config/server.lua'
}

files {
    'config/client.lua',
    'client/blip.lua',
    'client/utils.lua'
}
