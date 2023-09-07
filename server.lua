ESX = nil
QBcore = nil
local PlayersAvailable = {}

local Trash = {
    TrashModel = 1748268526, 
    TrashSpot = Config.TrashBin,
    TrashObj = false
}
local ConModels = {
    -14708062,
    -96647174,
    811169045,
}
local ActiveColour = {
    yellow = false,
    blue = false,
    green = false,
}
local Containers = Config.RecycleBins

if Config.UseESX then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.UseQBCore then
    QBCore = exports['qb-core']:GetCoreObject()
end

RegisterNetEvent('angelicxs-RecylceJob:Server:ActivityUpdater', function(active)
    if active then
        PlayersAvailable[source] = true
        for k, v in pairs (Containers) do
            if not DoesEntityExist(v.entity) then
                ContainerMaker(v)
            end
        end
        if not DoesEntityExist(Trash.TrashObj) then
            Trash.TrashObj = CreateObject(Trash.TrashModel, Trash.TrashSpot.x, Trash.TrashSpot.y, Trash.TrashSpot.z-1, true, true, true)
            SetEntityHeading(Trash.TrashObj, Trash.TrashSpot.w)
        end
        TriggerClientEvent('angelicxs-RecylceJob:Client:ActivityUpdater', -1, ActiveColour, Containers)
    else
        PlayersAvailable[source] = false
        local inzone = 0
        for id, active in pairs(PlayersAvailable) do
            if active then inzone = inzone + 1 end
        end
        if inzone == 0 then
            for k, v in pairs (Containers) do
                if DoesEntityExist(v.entity) then
                    DeleteEntity(v.entity)
                    v.entity = nil
                    v.colour = nil
                end
            end
            if DoesEntityExist(Trash.TrashObj) then
                DeleteEntity(Trash.TrashObj)
                Trash.TrashObj = false
            end
            ActiveColour.yellow = false
            ActiveColour.blue = false
            ActiveColour.green = false
            TriggerClientEvent('angelicxs-RecylceJob:Client:ActivityUpdater', -1, ActiveColour, Containers)
        end
    end
end)

RegisterNetEvent('angelicxs-RecylceJob:Payment', function(number, loc)
    local src = source
    local dist = #(loc-vector3(Trash.TrashSpot.x, Trash.TrashSpot.y, Trash.TrashSpot.z))
    if dist > Config.FurtherstBin then print('RecylceJob payment') TriggerEvent('angelicxs-RecylceJob:ThatIsAThing', "triggering payment more than 50 units away") return end
    local amount = Config.FlatAmount*number
    if Config.RandomAmount then
        amount = math.floor(math.random(Config.MinAmount, Config.MaxAmount)*number)
    end
    if Config.UseESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.addAccountMoney(Config.AccountMoney,amount)
    elseif Config.UseQBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.AddMoney(Config.AccountMoney, amount)
    end
    TriggerClientEvent('angelicxs-RecylceJob:Notify',src, Config.Lang['offduty']..amount, Config.LangType['success'])
end)

RegisterNetEvent('angelicxs-RecylceJob:RandomItem', function(colour, loc)
    local src = source
    local dist = #(loc-vector3(Trash.TrashSpot.x, Trash.TrashSpot.y, Trash.TrashSpot.z))
    if dist > Config.FurtherstBin then print('RecylceJob item') TriggerEvent('angelicxs-RecylceJob:ThatIsAThing', "triggering random item selection more than 50 units away") return end
    if math.random(0,100) <= Config.GetRandomItemChance then
        local item = Randomizer(Config.RandomItemList[colour])
        if Config.UseESX then
            Player = ESX.GetPlayerFromId(src)
            Player.addInventoryItem(item.item, math.random(item.min,item.max))
        elseif Config.UseQBCore then
            Player = QBCore.Functions.GetPlayer(src)
            Player.Functions.AddItem(item.item, math.random(item.min,item.max))
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.item], 'add')
        end
        TriggerClientEvent('angelicxs-RecylceJob:Notify',src, Config.Lang['item_find_1']..item.item..Config.Lang['item_find_2'], Config.LangType['success'])
    end 
end)

RegisterNetEvent('angelicxs-RecylceJob:ThatIsAThing', function(reason)
    local src = source
    DropPlayer(src, "Go hack somewhere else.")
    print("\n\n\n\nWARNING WARNING WARNING\nPlayer ID "..tostring(src).." was kicked for attempting to exploit angelicxs-RecylceJob for "..reason..". It is recommended you ban them.\nnWARNING WARNING WARNING\n\n\n\n")
end)

function ContainerMaker(table)
    local colour = 'unknown'
    local hash = Randomizer(ConModels)
    if hash == -14708062 then
        table.colour = "yellow"
        ActiveColour.yellow = true
    elseif hash == -96647174 then
        table.colour = "blue"
        ActiveColour.blue = true
    elseif hash == 811169045 then
        table.colour = "green"
        ActiveColour.green = true
    end
    table.entity = CreateObject(hash, table.spot.x, table.spot.y, table.spot.z-1, true, true, true)
    SetEntityHeading(table.entity, table.spot.w)
end

function Randomizer(Options)
    local List = Options
    local Number = 0
    math.random()
    local Selection = math.random(1, #List)
    for i = 1, #List do
        Number = Number + 1
        if Number == Selection then
            return List[i]
        end
    end
end

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        PlayersAvailable = {}
        for k, v in pairs (Containers) do
            if DoesEntityExist(v.entity) then
                DeleteEntity(v.entity)
                v.entity = nil
                v.colour = nil
            end
        end
        if DoesEntityExist(Trash.TrashObj) then
            DeleteEntity(Trash.TrashObj)
            Trash.TrashObj = nil
        end
        ActiveColour.yellow = false
        ActiveColour.blue = false
        ActiveColour.green = false
    end
end)