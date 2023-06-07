if Config.settings.newQB then
	QBCore = exports['qb-core']:GetCoreObject()
else
	QBCore = nil
	TriggerEvent("QBCore:GetObject", function(obj)
	  QBCore = obj
	end)
end

local robbing, stealing, coolDown, alarmSound, alerted, alert, hacked = false, false, false, false, false, false, false
local zones, guards, targets = {}, {}, {}
soundid = GetSoundId()

local function _U(entry)
	return locales[Config.settings.locale][entry] 
end

local function validWeapon()
    return Config.AllowedWeapons[GetSelectedPedWeapon(PlayerPedId())] ~= nil
end 

local function LoadAnimDict(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end        
    end
    return animDict
end

local function loadParticle()
	if not HasNamedPtfxAssetLoaded("scr_jewelheist") then
		RequestNamedPtfxAsset("scr_jewelheist")
    end
    while not HasNamedPtfxAssetLoaded("scr_jewelheist") do
		Wait(0)
    end
    SetPtfxAssetNextCall("scr_jewelheist")
end

RegisterNetEvent("lp_ammo_rob:client:policeAlert", function()     
    local ped = PlayerPedId()
    for _, v in pairs(guards) do
        TaskCombatPed(v, ped, 0, 16)
        print('attack')
    end
    if not alert then 
        alert = true
        if Config.settings.policeInfo.dispatch == 'ps-dispatch' then
            exports['ps-dispatch']:StoreRobbery()
        elseif Config.settings.policeInfo.dispatch == 'qb-dispatch' then
            TriggerServerEvent('police:server:policeAlert', _U("police_alert"))
        elseif Config.settings.policeInfo.dispatch == 'custom' then
            CustomAlert()
        elseif Config.settings.policeInfo.dispatch == 'normal' then
            local Player = QBCore.Functions.GetPlayerData()
            if Player.job.name == 'police' and Player.job.onduty then
            -- if Player.job.type == 'leo' and Player.job.onduty then
                PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
                local currentPos = GetEntityCoords(PlayerPedId())
                local locationInfo = GetLocation(currentPos)
                TriggerEvent('QBCore:Notify', _U('theft_info')..locationInfo, 'police', 10000)
                local transG = 250
                local blip = AddBlipForCoord(currentPos.x, currentPos.y, currentPos.z)
                SetBlipSprite(blip, 458)
                SetBlipColour(blip, 1)
                SetBlipDisplay(blip, 4)
                SetBlipAlpha(blip, transG)
                SetBlipScale(blip, 1.0)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentString(_U("police_alert"))
                EndTextCommandSetBlipName(blip)
                while transG ~= 0 do
                    Wait(60 * 3)
                    transG = transG - 1
                    SetBlipAlpha(blip, transG)
                    if transG == 0 then
                        SetBlipSprite(blip, 2)
                        RemoveBlip(blip)
                        return
                    end
                end
            end
        end
        Wait(60 * 1000)
        alert = false
    end
end)

local function setAlarm(loc, type)
    if alerted then return end
    if type then
        if not alarmSound then
            alarmSound = true  
            alerted = true          
            Wait(math.random(2000,4000))
            PlaySoundFromCoord(soundid, "VEHICLES_HORNS_AMBULANCE_WARNING", loc.x, loc.y, loc.z) 
            TriggerEvent('lp_ammo_rob:client:policeAlert')  
                  
            TriggerEvent('QBCore:Notify', _U('alarm_triggered'), 'error', 5000)            
            Wait(math.random(30000,120000))
            alarmSound = false
            StopSound(soundid)  
        end
    else
        alarmSound = false
        StopSound(soundid) 
    end
end

local function SpawnGuards(name)
    local ped = PlayerPedId()
    SetPedRelationshipGroupHash(ped, GetHashKey("PLAYER"))
    AddRelationshipGroup("Security")
    for k, v in pairs(Locations.SecurityGuard) do
        if k == name then
            for i = 1, #Locations.SecurityGuard[k] do
                local security = Locations.SecurityGuard[k][i]
                RequestModel(GetHashKey(security.ped))
                while not HasModelLoaded(GetHashKey(security.ped)) do
                    Wait(1)
                end
                guards[i] = CreatePed(4, GetHashKey(security.ped), security.pos[1], security.pos[2], security.pos[3], security.pos[4], true, true)
                Wait(50)
                local networkID = NetworkGetNetworkIdFromEntity(guards[i])
                SetNetworkIdCanMigrate(networkID, true)
                SetNetworkIdExistsOnAllMachines(networkID, true)  
                GiveWeaponToPed(guards[i], GetHashKey(security.weapon), 255, false, false)
                SetPedRelationshipGroupHash(guards[i], GetHashKey("Security"))
                SetPedAccuracy(guards[i], 20)
                SetPedArmour(guards[i], 100)
                SetPedFleeAttributes(guards[i], 0, false)
                SetPedCanSwitchWeapon(guards[i], true)
                SetPedDropsWeaponsWhenDead(guards[i], false)
                SetPedCombatMovement(guards[i], 3)
                SetPedAlertness(guards[i], 3)
                SetPedCombatRange(guards[i], 2)
                SetPedSeeingRange(guards[i], 300.0)
                SetPedHearingRange(guards[i], 300.0)
                SetPedCombatAttributes(guards[i], 5000, 1)
                SetPedCanRagdollFromPlayerImpact(guards[i], false)
                SetEntityAsMissionEntity(guards[i])
                SetEntityVisible(guards[i], true)
                SetEntityMaxHealth(guards[i], 1000)
                SetEntityHealth(guards[i], 1000)
            end
        end
    end    
    
    SetRelationshipBetweenGroups(0, GetHashKey("Security"), GetHashKey("Security"))
    SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), GetHashKey("Security")) 
end

local function StartRobbing(spot, name)
    local ped = PlayerPedId() 
    local plyCoords = GetOffsetFromEntityInWorldCoords(ped, 0, 0.6, 0)
    local pedWeapon = GetSelectedPedWeapon(ped)
    local randomTime = 5000
    if spot.time ~= nil then
        randomTime = spot.time 
        if Config.settings.scullyHolsters then
            exports['scully_holster']:UpdateWeapon(pedWeapon)
        else    
            SetCurrentPedWeapon(PlayerPedId(),'WEAPON_UNARMED', true)
        end
        Wait(1000)     
    else
        randomTime = Config.AllowedWeapons[pedWeapon].time        
    end
    stealing = true
    Wait(1000)
    QBCore.Functions.Progressbar("looting",  _U('grabbing'), randomTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() 
        ClearPedTasks(ped)
        FreezeEntityPosition(ped, false)         
        -- TriggerServerEvent('lp_ammo_rob:server:GiveLoot', spot.itemType) 
        QBCore.Functions.TriggerCallback('lp_ammo_rob:server:GiveLoot', function(cb)
            if cb then 
                exports['qb-target']:RemoveZone(spot.name) 
            end
        end, spot.itemType)
        if spot.time ~= nil then 
            if Config.settings.scullyHolsters then
                exports['scully_holster']:UpdateWeapon(pedWeapon)
            else 
                SetCurrentPedWeapon(ped, pedWeapon, true)
            end
        end
        stealing = false
    end, function()         
        ClearPedTasks(ped) 
        if spot.time ~= nil then 
            if Config.settings.scullyHolsters then
                exports['scully_holster']:UpdateWeapon(pedWeapon)
            else 
                SetCurrentPedWeapon(ped, pedWeapon, true) 
            end
        end
        stealing = false
    end)  
    
    local chance = math.random(1, 100)
    if chance <= Config.settings.policeInfo.chance then 
        local alarmZone = Locations.AlarmLocations[name].coords        
        setAlarm(alarmZone, true)
    end

    CreateThread(function()
        while stealing do
            local animation = spot.dict
            LoadAnimDict(animation)
            Wait(100)
            if spot.time == nil then
                TaskPlayAnim(ped, animation, spot.animation, 3.0, 3.0, -1, 2, 0, 0, 0, 0 )
                Wait(500)
                TriggerServerEvent("InteractSound_SV:PlayOnSource", "breaking_vitrine_glass", 0.25)
                loadParticle()
                StartParticleFxLoopedAtCoord("scr_jewel_cab_smash", plyCoords.x, plyCoords.y, plyCoords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
                Wait(5500)
            else
                TaskPlayAnim(ped, animation, spot.animation, 3.0, 3.0, -1, 2, 0, 0, 0, 0 )
                Wait(5500)
            end
        end
    end)   
end

local function DistanceCheck(spot)
    if Config.settings.debug then
        print('timer-event')
    end    
    if not timer then
        local sleep = 1000  
        if Config.settings.debug then 
            print('timer-start')
        end
        CreateThread(function()
            local ped = PlayerPedId() 
            local robPos = vector3(spot.x, spot.y, spot.z)
            Wait(1)
            while robbing do
                Wait(sleep)
                if #(GetEntityCoords(ped) - robPos) > 100 then                    
                    robbing, stealing, coolDown, alarmSound, alerted, alert, hacked = false, false, false, false, false, false, false
                    sleep = 500
                    for k, v in pairs(zones) do
                        if v ~= "main" then
                            exports['qb-target']:RemoveZone(v)
                        end
                    end
                    for _, v in pairs(guards) do
                        DeletePed(v)
                    end
                    DeleteEntity(laptop) 
                    setAlarm(nil, false)
                    TriggerServerEvent("lp_ammo_rob:server:sync", nil, false) 
                    if Config.settings.debug then
                        print('timer-end')
                    end
                end
            end
        end)
    end
end

local function HackPC(info)
    print(info)
    if Config.settings.hack == "ultra" then
        TriggerEvent('codem-blackhudv2:SetForceHide', true, true)
        TriggerEvent('ultra-keypadhack', 1, math.random(60,90), function(outcome, reason)    
            if outcome == 0 then
                TriggerEvent('codem-blackhudv2:SetForceHide', false, false)
                TriggerEvent('QBCore:Notify', _U('hack_failed'), 'error', 5000)
            elseif outcome == 1 then
                hacked = true                
                TriggerEvent('codem-blackhudv2:SetForceHide', false, false)
                exports['qb-target']:RemoveZone(info) 
                TriggerEvent('QBCore:Notify', _U('hack_success'), 'success', 5000)
            elseif outcome == 2 then
                TriggerEvent('codem-blackhudv2:SetForceHide', false, false)
                TriggerEvent('QBCore:Notify', _U('hack_failed'), 'error', 5000)
            elseif outcome == -1 then
                TriggerEvent('codem-blackhudv2:SetForceHide', false, false)
                TriggerEvent('QBCore:Notify', _U('hack_failed'), 'error', 5000)
            end
        end)
    elseif Config.settings.hack == "ps_scrambler" then
        TriggerEvent('codem-blackhudv2:SetForceHide', true, true)
        exports['ps-ui']:Scrambler(function(success)
            if success then
                hacked = true
                print("success")
                TriggerEvent('codem-blackhudv2:SetForceHide', false, false)
                exports['qb-target']:RemoveZone(info) 
            else
                print("fail")
                TriggerEvent('codem-blackhudv2:SetForceHide', false, false)
            end
        end, "alphabet", math.random(20,35), 0) -- Type (alphabet, numeric, alphanumeric, greek, braille, runes), Time (Seconds), Mirrored (0: Normal, 1: Normal + Mirrored 2: Mirrored only )
    end
end

local function SpawnProp(coords, prop)
    print(coords)
    local model = prop
    RequestModel(model)
    while (not HasModelLoaded(model)) do
        Wait(10)
    end

    laptop = CreateObject(model, coords.x, coords.y, coords.z, true, false, true)
    SetEntityHeading(laptop, coords.w)
    PlaceObjectOnGroundProperly(laptop)
    SetModelAsNoLongerNeeded(model)
    SetEntityAsMissionEntity(laptop)
end

local function TeleportPlayer(name, spot, type)
    if type then
        local zone = Locations.Start[name]["door_02"]
        SetEntityCoords(PlayerPedId(), zone.teleport_enter.x, zone.teleport_enter.y, zone.teleport_enter.z)	
        SetEntityHeading(PlayerPedId(), zone.teleport_enter.w)        
        TriggerEvent('QBCore:Notify', _U('hack_pc'), 'success', 8000)
        for i = 1, #Locations.Zone[name] do
            local hacks = Locations.Zone[name][i]
            if hacks.name == "hack_pc" then                
                hacks[i] = exports['qb-target']:AddBoxZone(hacks.name, vector3(hacks.coords.x, hacks.coords.y, hacks.coords.z), hacks.length, hacks.width, {
                    name = hacks.name,
                    heading = hacks.coords.w,
                    debugPoly = Config.settings.debug,
                    minZ = hacks.min_z,
                    maxZ = hacks.max_z,
                }, {
                    options = {
                        {
                            num = 1,
                            icon = "fa-solid fa-cash-register",
                            label = hacks.label,
                            type = 'client',
                            item = hacks.itemNeeded,
                            action = function(entity)
                                HackPC("hack_pc")       
                            end,          	
                        },
                    },
                    distance = 0.6 
                })
                table.insert(zones, hacks.name)

                SpawnProp(hacks.coords, hacks.prop)
            end
        end
    else
        local zone = Locations.Start[name]["door_02"]
        local item = zone.itemNeeded  
        QBCore.Functions.TriggerCallback('lp_ammo_rob:server:checkItem', function(cb)
            if cb then            
                local ped = PlayerPedId()
                local weapon = GetSelectedPedWeapon(ped)
                if Config.settings.scullyHolsters then
                    exports['scully_holster']:UpdateWeapon(weapon)
                else    
                    SetCurrentPedWeapon(PlayerPedId(),'WEAPON_UNARMED', true)
                end
                Wait(1000)
                QBCore.Functions.Progressbar("start_heist_02", "Breaking into room", zone.time, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                    animDict = zone.animDict,
                    anim = zone.anim,
                    flags = zone.flags,
                }, {}, {}, function()   
                    exports['qb-target']:RemoveZone(zone.name)                     
                    ClearPedTasks(ped)
                    FreezeEntityPosition(ped, false)
                    SetEntityCoords(PlayerPedId(), zone.teleport_exit.x, zone.teleport_exit.y, zone.teleport_exit.z)
                    SetEntityHeading(PlayerPedId(), zone.teleport_exit.w)
                    if Config.settings.scullyHolsters then
                        exports['scully_holster']:UpdateWeapon(weapon)
                    else 
                        SetCurrentPedWeapon(PlayerPedId(), weapon, true)
                    end
                    TriggerEvent("lp_ammo_rob:client:robberySpots", name, zone.teleport_exit)
                end, function() 
                    ClearPedTasks(ped) 
                    if Config.settings.scullyHolsters then
                        exports['scully_holster']:UpdateWeapon(weapon)
                    else 
                        SetCurrentPedWeapon(PlayerPedId(), weapon, true)
                    end
                end)              
            end
        end, name, item, spot)        
    end
end

local function StartHeist(name, spot)
    QBCore.Functions.TriggerCallback('lp_ammo_rob:server:getCops', function(cops)
        if cops >= Config.settings.policeInfo.policeCount then
            local item = spot.itemNeeded    
            print(item)        
            QBCore.Functions.TriggerCallback('lp_ammo_rob:server:checkItem', function(cb)
                if cb then            
                    local ped = PlayerPedId()
                    local weapon = GetSelectedPedWeapon(ped)
                    if Config.settings.scullyHolsters then
                        exports['scully_holster']:UpdateWeapon(weapon)
                    else    
                        SetCurrentPedWeapon(PlayerPedId(),'WEAPON_UNARMED', true)
                    end
                    Wait(1000)
                    QBCore.Functions.Progressbar("start_heist", "Breaking into room", spot.time, false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }, {
                        animDict = spot.animDict,
                        anim = spot.anim,
                        flags = spot.flags,
                    }, {}, {}, function()   
                        if Locations.SecurityGuards then
                            TriggerServerEvent("lp_ammo_rob:server:sync", name, true)                          
                        end
                        -- exports['qb-target']:RemoveZone(spot.name)                         
                        Wait(500)
                        ClearPedTasks(ped)
                        FreezeEntityPosition(ped, false)
                        TeleportPlayer(name, spot, true)
                        if Config.settings.scullyHolsters then
                            exports['scully_holster']:UpdateWeapon(weapon)
                        else  
                            SetCurrentPedWeapon(PlayerPedId(), weapon, true)
                        end
                        DistanceCheck(spot.coords) 
                    end, function() 
                        ClearPedTasks(ped)
                    end)           
                end
            end, name, item, spot)
        else
            TriggerEvent('QBCore:Notify', _U('cop_count'), 'error', 5000)
        end
    end)
end

RegisterNetEvent('lp_ammo_rob:client:sync', function(name)
    SpawnGuards(name)
end)

RegisterNetEvent('lp_ammo_rob:client:setBusy', function(name, state) 
    Locations.Start[name].busy = state
    print(Locations.Start[name].busy)
end)

RegisterNetEvent('lp_ammo_rob:client:robberySpots', function(name, loc) 
    for i = 1, #Locations.Zone[name] do
        local target = Locations.Zone[name][i]
        if target.name ~= "hack_pc" then
            targets[i] = exports['qb-target']:AddBoxZone(target.name, vector3(target.coords.x, target.coords.y, target.coords.z), target.length, target.width, {
                name = target.name,
                heading = target.coords.w,
                debugPoly = Config.settings.debug,
                minZ = target.min_z,
                maxZ = target.max_z,
            }, {
                options = {
                    {
                        num = 1,
                        icon = "fa-solid fa-cash-register",
                        label = target.label,
                        type = 'client',
                        action = function(entity)
                            if validWeapon() then
                                StartRobbing(target, name) 
                            end      
                        end,          	
                    },
                },
                distance = 1.0 
            })
            table.insert(zones, target.name)
        end
    end    
    if not hacked then
        local alarmZone = Locations.AlarmLocations[name].coords
        setAlarm(alarmZone, true)          
    end
end)

CreateThread(function()    
    for k, v in pairs(Locations.Start) do
        for p, d in pairs(v) do
            exports['qb-target']:AddBoxZone(d.name, vector3(d.coords.x, d.coords.y, d.coords.z), d.length, d.width, {
                name = d.name,
                heading = d.coords.w,
                debugPoly = Config.settings.debug,
                minZ = d.min_z,
                maxZ = d.max_z,
            }, {
                options = {
                    {
                        num = 1,
                        icon = "fa-solid fa-cash-register",
                        label = d.label,
                        type = 'client',
                        action = function()
                            if d.name == "main" then    
                                QBCore.Functions.TriggerCallback('lp_ammo_rob:server:checkRobbed', function(cb)  
                                    if not cb then                          
                                        StartHeist(k, d)  
                                        robbing = true
                                    else
                                        TriggerEvent('QBCore:Notify', _U('robbed'), 'error')
                                    end
                                end)
                            else
                                if d.name == "door_02" then  
                                    TeleportPlayer(k, d, false)
                                end
                            end                                               
                        end,               	
                    }                    
                },
                distance = 0.75
            }) 
            table.insert(zones, d.name)
        end
    end    
end)


AddEventHandler("onResourceStop", function(resName)
    if resName == GetCurrentResourceName() then
        for _, v in pairs(zones) do
            exports['qb-target']:RemoveZone(v)
        end
        for _, v in pairs(guards) do
           DeletePed(v)
        end
        DeleteEntity(laptop)
    end    
end)


