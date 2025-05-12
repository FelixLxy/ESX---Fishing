fx_version 'cerulean'
games {'gta5'}
lua54 'yes'

author 'FelixL'
description 'ESX/OX - Fishing'
version '1.1.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_script 'client/main.lua'
server_script 'server/main.lua'
