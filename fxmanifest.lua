fx_version 'cerulean'
game 'gta5'
author 'LlamaPalooza | Dream Scripts'
description 'QBCore Ammunation Heist'
version 'A-1.0.0'

shared_script {  -- COMMENT IF YOU'RE USING OLD QB-CORE EXPORT                         
    'server/shared.lua',
    'client/locations.lua',
    'locales/*.lua',
}

-- shared_script {  -- UNCOMMENT IF YOU'RE USING OLD QB-CORE EXPORT
--     '@qb-core/import.lua',    
--     'server/shared.lua',
--     'client/locations.lua',
--     'client/client_editable.lua',
--     'locales/*.lua',
-- }   

client_script {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
}

dependency '/assetpacks'

lua54 'yes'