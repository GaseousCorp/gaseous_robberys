fx_version 'cerulean'
game 'gta5'

name "robberys"
description "Robbery system"
author "Zhawty"
version "1.0.0"

shared_scripts {
	'shared/*.lua'
}

client_scripts {
    "@vrp/lib/utils.lua",
	'client/*.lua'
}

server_scripts {
    "@vrp/lib/utils.lua",
	'server/*.lua'
}
