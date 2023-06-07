if Config.settings.newQB then
	QBCore = exports['qb-core']:GetCoreObject()
else
	QBCore = nil
	TriggerEvent("QBCore:GetObject", function(obj)
	  QBCore = obj
	end)
end

local timeOut, AlreadyRobbed = false, false
local cachedPoliceAmount = {}

local function _U(entry)
	return locales[Config.settings.locale][entry] 
end


QBCore.Functions.CreateCallback('lp_ammo_rob:server:getCops', function(source, cb)
	local amount = 0
    for _, v in pairs(QBCore.Functions.GetQBPlayers()) do
        if v.PlayerData.job.name == "police" and v.PlayerData.job.onduty then
            amount = amount + 1
        end
    end
    cachedPoliceAmount[source] = amount
    cb(amount)
end)

QBCore.Functions.CreateCallback('lp_ammo_rob:server:checkRobbed', function(source, cb)
    if not timeOut then
        cb(AlreadyRobbed)
    else
        cb(true)
    end
end)

QBCore.Functions.CreateCallback('lp_ammo_rob:server:checkItem', function(source, cb, name, item, loc)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)    
    local hasItem = QBCore.Functions.HasItem(src, 'trojan_usb', 1)
    local items = {}
    if not hasItem then
        items[#items+1] = { name = 'trojan_usb' } 
        TriggerClientEvent('inventory:client:requiredItems', src, items, true) 
        Wait(5000)
        TriggerClientEvent('inventory:client:requiredItems', src, items, false)
        cb(false) 
    elseif hasItem then
        if Player.Functions.RemoveItem(item, 1) then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "remove", 1)
            cb(true)          
        else    
            items[#items+1] = { name = item } 
            TriggerClientEvent('QBCore:Notify', src,  _U('no_item'), 'error') 
            cb(false)
            TriggerClientEvent('inventory:client:requiredItems', src, items, true)
            Wait(5000)
            TriggerClientEvent('inventory:client:requiredItems', src, items, false)
        end
    end   
end)  

RegisterNetEvent('lp_ammo_rob:server:Timer', function() 
    local wait = (60 * 1000) * Config.settings.coolDown.time
    if not timeOut then        
        timeOut = true
        if Config.settings.debug then
            print('timer-server-started')
        end
        CreateThread(function()
            Wait(wait)
            AlreadyRobbed = false
            if Config.settings.debug then
                print('timer-server-ended')
            end
            timeOut = false
        end)
    end
end)

RegisterServerEvent("lp_ammo_rob:server:sync", function(name, type)
    if type then
        AlreadyRobbed = true
        TriggerEvent('lp_ammo_rob:server:Timer')
        TriggerClientEvent('lp_ammo_rob:client:sync', -1, name)
    else
        AlreadyRobbed = false
    end
end)

local function GiveWep(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    for i = 1, tonumber(amount) do
        if Player.Functions.AddItem(item, 1) then
            if tonumber(i) == tonumber(amount) then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add", amount)
            end
            return true
        else            
            TriggerClientEvent('QBCore:Notify', src, _U("over_weight"), "error") 
            return false 
        end
        Wait(5)
    end
end

QBCore.Functions.CreateCallback('lp_ammo_rob:server:GiveLoot', function(source, cb, itemType)
-- RegisterServerEvent('lp_ammo_rob:server:GiveLoot', function(itemType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if itemType ~= "safe" then
        for i = 1, math.random(2,5) do 
            local items = Config.loot[itemType].items[math.random(1, #Config.loot[itemType].items)]
            local amount = math.random(Config.loot[itemType].amount.min, Config.loot[itemType].amount.max)
            local chance = math.random(1, 100)
            if chance <= Config.loot.getItem then
                if QBCore.Shared.Items[items].type == "weapon" or QBCore.Shared.Items[items].unique then
                    for i = 1, tonumber(amount) do
                        if Player.Functions.AddItem(items, 1) then
                            if tonumber(i) == tonumber(amount) then
                                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[items], "add", amount)
                                cb(true)
                            end
                        else            
                            TriggerClientEvent('QBCore:Notify', src, _U("over_weight"), "error") 
                        end
                    end                    
                else
                    if Player.Functions.AddItem(items, amount, false) then
                        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[items], "add", amount) 
                        -- TriggerClientEvent('QBCore:Notify', src,  _U('items_found'), 'success') 
                        cb(true)         
                    else
                        TriggerClientEvent('QBCore:Notify', src,  _U('over_weight'), 'error') 
                        cb(false)
                    end
                end
            else
                if QBCore.Shared.Items[items].type == "weapon" or QBCore.Shared.Items[items].unique then
                    for i = 1, tonumber(1) do
                        if Player.Functions.AddItem(items, 1) then
                            if tonumber(i) == tonumber(1) then
                                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[items], "add", 1)
                                cb(true)
                            end
                        else            
                            TriggerClientEvent('QBCore:Notify', src, _U("over_weight"), "error") 
                        end
                    end    
                else
                    if Player.Functions.AddItem(items, 1, false) then
                        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[items], "add", 1) 
                        -- TriggerClientEvent('QBCore:Notify', src,  _U('items_found'), 'success') 
                        cb(true)
                    else
                        TriggerClientEvent('QBCore:Notify', src,  _U('over_weight'), 'error') 
                        cb(false)
                    end
                end
            end
        end
    else
        local chance = math.random(1, 100)
        if chance <= Config.loot.registers.chance then
            local reward = math.random(Config.loot.registers.amount.min, Config.loot.registers.amount.max)
            if Config.loot.registers.type == "cash" then
                Player.Functions.AddMoney('cash', reward)  
                TriggerClientEvent('QBCore:Notify', src,  _U('cash_found')..reward.."..", 'error') 
                cb(true)
            elseif Config.loot.registers.type == "markedbills" then
                local info = {
                    worth = reward
                } 
                Player.Functions.AddItem('markedbills', 1, false, info)
                TriggerClientEvent('QBCore:Notify', src,  _U('cash_found')..info.worth.."..", 'error') 
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'], "add", info.worth)
                cb(true)
            end                
        else
            TriggerClientEvent('QBCore:Notify', src,  _U('nothing_found'), 'error') 
            cb(true)
        end
    end
end)





