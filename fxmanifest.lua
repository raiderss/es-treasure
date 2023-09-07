fx_version "adamant"

description "Eyes Store"
author "! Raider#0101"
version '1.0.0'
repository 'https://discord.gg/EkwWvFS'

game "gta5"

client_scripts {
"main/client/*.lua",
} 

server_scripts {
"main/server/*.lua" ,
}

shared_script "main/config/case.lua"