-- Discord: https://discord.gg/gqxxwt49SX

Config = {}

Config.settings = {    
    newQB = true,  -- Set to `false` if using qb-core with old export & read info in fxmanifest
    debug = true,
    scullyHolsters = false,
    hack = "ps_scrambler", -- 'ps_scrambler' or 'ultra' <-- https://github.com/ultrahacx/ultra-keypackhack
    locale = 'en',  
    coolDown = {  -- Cooldown
        time = 20  -- In minutes, 20 = 20 minutes ;)
    },
    policeInfo = {
        policeCount = 0,  -- minimun # of cops to start robbery
        -- leaveEvidence = true,  -- Set to `true` to leave evidence. ### SOON ### 
        chance = 77,  -- Higher # means higher chance of police being notified when smashing cases
        dispatch = 'ps-dispatch',  -- ps-dispatch / qb-dispatch / normal <--- basic police alert built-in / custom <--- Check `client/custom_alert` function CustomAlert(vehicle) for more info
    }
}

Config.AllowedWeapons = {  -- Allowed weapons for smashing cases
    [`weapon_assaultrifle`] = {true, time = 5000},  -- `true` means it'll work, `false` means it won't.    
    [`weapon_pumpshotgun`] = {true, time = 5000},
    -- Custom Weapons --
    [`weapon_ak47`] = {true, time = 5000},
}

Config.loot = {  -- Reward/Loot tables
    getItem = 40,  -- Higher # means higher chance of receiving more than 1 item when looting (1-100)
    -- registers = {  -- Cash looted from registers  ### SOON ###
    --     chance = 56,  -- Chance to receive anything from searching registers
    --     type = "markedbills",  -- `cash` or `markmarkedbillsedbills`
    --     amount = {  -- Minimun & maximun amount received for either cash or markedbills
    --         min = 150,
    --         max = 500
    --     }
    -- },
    ["wep_parts"] = { 
        amount = {
            min = 2,
            max = 3
        },
        items = {
            'pistol_extendedclip',            
            'pistol_flashlight',
            'pistol_suppressor',            
            'microsmg_scope',
            'smg_suppressor',            
            'shotgun_suppressor',
            'pistol_extendedclip',            
            'machinepistol_drum',
            'pistol_ammo',
            'smg_ammo',
            'shotgun_ammo',
            'rifle_ammo'
        }
    },
    ["small_arms"] = { 
        amount = {
            min = 1,
            max = 3
        },
        items = {
            'weapon_pistol',            
            'weapon_combatpistol',
            'weapon_appistol',
            'weapon_machinepistol',
            'weapon_pistol50',
            -- Custom Weapons --
            -- 'weapon_de',
            -- 'weapon_glock17',
            -- 'weapon_mac10'            
        }
    },
    ["med_arms"] = { 
        amount = {
            min = 1,
            max = 2
        },
        items = {
            'weapon_smg',   
            'weapon_microsmg',         
            'weapon_pumpshotgun',
            -- Custom Weapons --
            -- 'weapon_ak47'
        }
    },
    -- ["big_arms"] = { 
    --     amount = {
    --         min = 1,
    --         max = 1
    --     },
    --     items = {
    --         'weapon_smg',   
    --         'weapon_microsmg'         
    --         'weapon_pumpshotgun',
    --         -- Custom Weapons --
    --         -- 'weapon_ak47'
    --     }
    -- }
}






