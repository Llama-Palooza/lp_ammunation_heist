-- Please join the discord server for support! Don't change these if you don't know what you're doing!
-- Discord: https://discord.gg/gqxxwt49SX

Locations = {}
Locations.SecurityGuards = true  -- Set to `false` to disable security guards

Locations.AlarmLocations = {
    ["elgin"] = {
        coords = vector3(18.99, -1105.66, 32.0)
    }
}

Locations.Start = {
    ["elgin"] = {
        ["door_01"] = {  -- don't change
            busy = false,
            coords = vector4(21.99, -1104.31, 38.15, 340.0),
            teleport_enter = nil,
            teleport_exit = nil,
            name  = "main",  -- keep this name!
            label = "Break In",
            animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            anim = "machinic_loop_mechandplayer",
            flags = 0,
            time = math.random(3500,8000),
            itemNeeded  = 'screwdriverset',
            length = 0.8,
            width = 1.1,
            min_z = 37.15,
            max_z = 39.4 
        },
        ["door_02"] = {  -- don't change
            busy = false,
            coords = vector4(13.8, -1106.77, 29.8, 340.0),
            teleport_enter = vector4(12.82, -1109.96, 29.8, 334.82),
            teleport_exit = vector4(14.0, -1106.3, 29.8, 338.63),
            name  = "door_02",
            label = "Lockpick Door",
            animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            anim = "machinic_loop_mechandplayer",
            flags = 49,
            time = math.random(3500,8000),
            itemNeeded  = 'lockpick',
            length = 0.3,
            width = 1.25,
            min_z = 28.9,
            max_z = 31.1 
        }        
    }
}

Locations.Zone = {
    ["elgin"] = {
        [1] = {
            prop = `prop_laptop_01a`,
            coords = vector4(12.31, -1106.59, 30.00, 344.0),
            name   = "hack_pc",  -- Must be different for each one!
            label  = "Hack Security",
            dict   = "mp_shipment_steal",
            animation   = "hack_loop",
            flags = 59,
            time = 7500,
            itemNeeded = 'trojan_usb',
            length  = 0.5,
            width = 0.5,
            min_z = 29.8,
            max_z = 30.2
        },
        [2] = {
            coords = vector4(20.45, -1105.46, 29.8, 340.0),
            name   = "small_wep_01",  -- Must be different for each one!
            label  = "Steal Weapons",
            dict   = "missheist_jewel",
            animation   = "smash_case",
            flags = 15,
            time = nil,
            itemType   = "small_arms",
            length  = 0.7,
            width = 1.95,
            min_z = 29.4,
            max_z = 29.85
        },
        [3] = {
            coords = vector4(22.37, -1106.13, 29.8, 340.0),
            name   = "small_wep_02",  -- Must be different for each one!
            label  = "Steal Weapons",
            dict   = "missheist_jewel",
            animation   = "smash_case",
            flags = 15,
            time = nil,
            itemType   = "small_arms",
            length  = 0.7,
            width = 1.95,
            min_z = 29.4,
            max_z = 29.85
        },
        [4] = {
            coords = vector4(23.12, -1107.91, 29.8, 70.0),
            name   = "small_wep_03",  -- Must be different for each one!
            label  = "Steal Weapons",
            dict   = "missheist_jewel",
            animation   = "smash_case",
            flags = 15,
            time = nil,
            itemType   = "med_arms",
            length  = 0.7,
            width = 1.95,
            min_z = 29.4,
            max_z = 29.85
        },
        [5] = {
            coords = vector4(20.81, -1103.7, 29.8, 340.0),
            name   = "wep_parts_01",  -- Must be different for each one!
            label  = "Steal Parts",
            dict   = "anim@scripted@player@mission@tun_table_grab@cash@",
            animation   = "grab",
            flags = 15,
            time = 7500,
            itemType   = "wep_parts",
            length  = 0.45,
            width = 1.90,
            min_z = 28.85,
            max_z = 30.05
        },
        [6] = {
            coords = vector4(22.8, -1104.36, 29.8, 340.0),
            name   = "wep_parts_02",  -- Must be different for each one!
            label  = "Steal Parts",
            dict   = "anim@scripted@player@mission@tun_table_grab@cash@",
            animation   = "grab",
            flags = 15,
            time = 7500,
            itemType   = "wep_parts",
            length  = 0.45,
            width = 1.90,
            min_z = 28.85,
            max_z = 30.05
        },
        [7] = {
            coords = vector4(24.69, -1105.05, 29.8, 340.0),
            name   = "wep_parts_03",  -- Must be different for each one!
            label  = "Steal Parts",
            dict   = "anim@scripted@player@mission@tun_table_grab@cash@",
            animation   = "grab",
            flags = 15,
            time = 7500,
            itemType   = "wep_parts",
            length  = 0.45,
            width = 1.90,
            min_z = 28.85,
            max_z = 30.05
        }            
    }
}

Locations.SecurityGuard = {
    ["elgin"] = {
        [1] = {pos = vector4(15.87, -1113.61, 29.1, 307.21), ped = 'mp_m_securoguard_01', weapon = 'WEAPON_STUNGUN'},
        [2] = {pos = vector4(8.91, -1109.9, 29.8, 66.55), ped = 'mp_m_securoguard_01', weapon = 'WEAPON_PISTOL'},
        [3] = {pos = vector4(12.06, -1099.43, 29.8, 157.51), ped = 'mp_m_securoguard_01', weapon = 'WEAPON_PISTOL'},
    }
}



