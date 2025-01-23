fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'https://github.com/Pintta/Broken-TaxSystem'
description 'Broken-TaxSystem'
client_script 'client.lua'
server_scripts {
    'install.lua', -- After installing, you can remove this line (I recommend)
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}
dependency 'oxmysql'
