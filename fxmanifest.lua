fx_version 'cerulean'
game 'gta5'

use_experimental_fxv2_oal 'yes'
lua54 'yes'

description 'Renewed Dutyblips'
version '2.0.0'

shared_script '@ox_lib/init.lua'
client_script 'client/*.lua'
server_script {
    'server/*.lua',
}

files {
    'config/*.lua',
    'bridge/*.lua',
}
