fx_version 'cerulean'
game 'gta5'
lua54 'yes'
client_script 'client.lua'
server_scripts {
    'install.lua', -- After installing, you can remove this line (I recommend)
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}
dependency 'oxmysql'