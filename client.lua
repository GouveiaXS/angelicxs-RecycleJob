ESX = nil
QBcore = nil
OnDuty = false

local AvailableColourName = {
    'yellow',
    'blue',
    'green'
}
local jobBlip = false
local warehouselocation = Config.RecycleDepot
local TrashSpot = Config.TrashBin
local dutySpot = Config.DutySpot
local ActiveColour = {}
local Containers = {}
local CurrentSort = false
local prop = false
local itemSorted = 0
local EntryPed = nil
local ExitPed = nil
local DutyPed = nil
local targetbinlabel = {
    yellow = Config.Lang['place_item']..Config.Lang['yellow']..Config.Lang['sort_item_2'],
    blue = Config.Lang['place_item']..Config.Lang['blue']..Config.Lang['sort_item_2'],
    green = Config.Lang['place_item']..Config.Lang['green']..Config.Lang['sort_item_2'],
}
local OXoptions = {
    yellow = { label = targetbinlabel.yellow, onSelect = function() SortItem('yellow') end, distance = 2, },
    blue = { label = targetbinlabel.blue, onSelect = function() SortItem('blue') end, distance = 2, },
    green = { label = targetbinlabel.green, onSelect = function() SortItem('green') end, distance = 2, },
    trash = { label = Config.Lang['grab_sort_item'], distance = 2, 
        onSelect = function()
            if not OnDuty then
                TriggerEvent('angelicxs-RecylceJob:Notify', Config.Lang['not_on_duty'], Config.LangType['info'])
            elseif CurrentSort then
                TriggerEvent('angelicxs-RecylceJob:Notify', Config.Lang['not_finished'], Config.LangType['error'])
            else
                BeginSorting()
            end
        end,
    },
}
local TargetOptions = {
    yellow = {{ label = targetbinlabel.yellow, action = function() SortItem('yellow') end }},
    blue = {{ label = targetbinlabel.blue, action = function() SortItem('blue') end }},
    green = {{ label = targetbinlabel.green, action = function() SortItem('green') end, }},
    trash = {{ label = Config.Lang['grab_sort_item'],
        action = function()
            if not OnDuty then
                TriggerEvent('angelicxs-RecylceJob:Notify', Config.Lang['not_on_duty'], Config.LangType['info'])
            elseif CurrentSort then
                TriggerEvent('angelicxs-RecylceJob:Notify', Config.Lang['not_finished'], Config.LangType['error'])
            else
                BeginSorting()
            end
        end,  
    }},
}

RegisterNetEvent('angelicxs-RecylceJob:Notify', function(message, type)
	if Config.UseCustomNotify then
        TriggerEvent('angelicxs-RecylceJob:CustomNotify',message, type)
	elseif Config.UseESX then
		ESX.ShowNotification(message)
	elseif Config.UseQBCore then
		QBCore.Functions.Notify(message, type)
	end
end)

CreateThread(function()
    if Config.UseESX then
        ESX = exports["es_extended"]:getSharedObject()   
    elseif Config.UseQBCore then
        QBCore = exports['qb-core']:GetCoreObject()
    end
    if Config.UseThirdEye and Config.ThirdEyeName ~= 'ox_target' then
        
        local op = {
            entry = {
                label = Config.Lang['request_entry'],
                event = 'angelicxs-RecylceJob:Entry',
            },
            exit = {
                label = Config.Lang['request_exit'],
                event ='angelicxs-RecylceJob:Exit',
            },
            duty = {
                label = Config.Lang['sign_in'],
                event = 'angelicxs-RecylceJob:OnDuty',
            },
        }
        exports[Config.ThirdEyeName]:AddBoxZone("RecyleEntry", vector3(Config.EntryPoint.x, Config.EntryPoint.y, Config.EntryPoint.z), 2.0, 2.0, {
            name = "RecyleEntry",
            heading = Config.EntryPoint.w,
            debugPoly = false,
            minZ = Config.EntryPoint.z-1,
            maxZ = Config.EntryPoint.z+1,
            },{ options = {op.entry}, distance = 2.5
        })
        exports[Config.ThirdEyeName]:AddBoxZone("RecyleExit", vector3(warehouselocation.x, warehouselocation.y, warehouselocation.z), 2.0, 2.0, {
            name = "RecyleExit",
            heading = warehouselocation.w,
            debugPoly = false,
            minZ = warehouselocation.z-1,
            maxZ = warehouselocation.z+1,
            },{ options = {op.exit}, distance = 2.5
        })
        exports[Config.ThirdEyeName]:AddBoxZone("RecyleDuty", vector3(dutySpot.x, dutySpot.y, dutySpot.z), 2.0, 2.0, {
            name = "RecyleDuty",
            heading = 0.0,
            debugPoly = false,
            minZ = dutySpot.z-1,
            maxZ = dutySpot.z+1,
            },{ options = {op.duty}, distance = 2.5
        })
    end
    CreateThread(function()
        while true do 
            local dist = #(GetEntityCoords(PlayerPedId())-vector3(Config.EntryPoint.x, Config.EntryPoint.y, Config.EntryPoint.z))
            local pedStatus = DoesEntityExist(EntryPed)
            if dist <= 50 and not pedStatus then
                local hash = HashGrabber(Config.EntryPed)
                EntryPed = CreatePed(3, hash, Config.EntryPoint.x, Config.EntryPoint.y, (Config.EntryPoint.z-1), Config.EntryPoint.w, false, false)
                FreezeEntityPosition(EntryPed, true)
                SetEntityInvincible(EntryPed, true)
                SetBlockingOfNonTemporaryEvents(EntryPed, true)
                TaskStartScenarioInPlace(EntryPed,'WORLD_HUMAN_STAND_IMPATIENT', 0, false)
                SetModelAsNoLongerNeeded(Config.EntryPed)
                if Config.ThirdEyeName == 'ox_target' and Config.UseThirdEye then
                    exports.ox_target:addLocalEntity(EntryPed, {{
                        label = Config.Lang['request_entry'],
                        event = 'angelicxs-RecylceJob:Entry',
                    }})
                end
            elseif dist > 50 and pedStatus then
                DeleteEntity(EntryPed)
                EntryPed = nil
            end
            Wait(1000)
        end
    end)
    if Config.JobBlip then
        jobBlip = AddBlipForCoord(vector3(Config.EntryPoint.x, Config.EntryPoint.y, Config.EntryPoint.z))
        SetBlipSprite(jobBlip, Config.JobBlipSprite)
        SetBlipScale(jobBlip, 0.7)
        SetBlipAsShortRange(jobBlip, true)
        SetBlipColour(jobBlip, Config.JobBlipColour)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Config.JobBlipName)
        EndTextCommandSetBlipName(jobBlip)
    end
    if Config.Use3DText then
        while true do
            local sleep = 2000
            local dist = #(GetEntityCoords(PlayerPedId())-vector3(Config.EntryPoint.x, Config.EntryPoint.y, Config.EntryPoint.z))
            if dist <= 100 then 
                sleep = 1000
                if dist <= 50 then 
                    sleep = 500
                    if dist <= 10 then
                        sleep = 0
                        DrawText3Ds(Config.EntryPoint.x, Config.EntryPoint.y, Config.EntryPoint.z, Config.Lang['request_entry_3d'])
                        if dist <= 3 and IsControlJustReleased(0, 38) then
                            TriggerEvent('angelicxs-RecylceJob:Entry')
                        end
                    end
                end
            end
            Wait(sleep)
        end
    end
end)

RegisterNetEvent('angelicxs-RecylceJob:OnDuty', function()
    local dist = #(GetEntityCoords(PlayerPedId())-vector3(warehouselocation.x, warehouselocation.y, warehouselocation.z))
    if dist >= 50 then TriggerServerEvent('angelicxs-RecylceJob:ThatIsAThing', "triggering duty/payment more then 50 units away") return end
    if not OnDuty then
        OnDuty = true 
        TriggerEvent('angelicxs-RecylceJob:Notify', Config.Lang['onduty'], Config.LangType['success'])
    else
        OnDuty = false
        CurrentSort = false
        TriggerServerEvent('angelicxs-RecylceJob:Payment', itemSorted, GetEntityCoords(PlayerPedId()))
        itemSorted = 0
    end
end)

RegisterNetEvent('angelicxs-RecylceJob:Exit', function()
    itemSorted = 0
    CurrentSort = false
    if OnDuty then OnDuty = false TriggerEvent('angelicxs-RecylceJob:Notify', Config.Lang['early_leave'], Config.LangType['error']) end
    DoScreenFadeOut(100)
    while not IsScreenFadedOut() do Wait (10) end
    SetEntityCoords(PlayerPedId(), Config.EntryPoint.x, Config.EntryPoint.y, Config.EntryPoint.z)
    TriggerServerEvent('angelicxs-RecylceJob:Server:ActivityUpdater', false)
    if DoesEntityExist(prop) then
        DetachEntity(prop, 1, false)
        DeleteObject(prop)
        prop = nil
    end
    if ExitPed then
        DeleteEntity(ExitPed)
        ExitPed = nil
    end
    if DutyPed then
        DeleteEntity(DutyPed)
        DutyPed = nil
    end
    DoScreenFadeIn(1000)
    while not IsScreenFadedIn() do Wait(10) end
    if Config.UseThirdEye then
        if Config.ThirdEyeName == 'ox_target' then
            exports.ox_target:removeModel(-14708062, OXoptions.yellow)
            exports.ox_target:removeModel(-96647174, OXoptions.blue)
            exports.ox_target:removeModel(811169045, OXoptions.green)
            exports.ox_target:removeModel(1748268526, OXoptions.trash)
        else
            exports[Config.ThirdEyeName]:RemoveTargetModel(-14708062, TargetOptions.yellow.label)
            exports[Config.ThirdEyeName]:RemoveTargetModel(-96647174, TargetOptions.blue.label)
            exports[Config.ThirdEyeName]:RemoveTargetModel(811169045, TargetOptions.green.label)
            exports[Config.ThirdEyeName]:RemoveTargetModel(1748268526, TargetOptions.trash.label)
        end
    end
end)

RegisterNetEvent('angelicxs-RecylceJob:Entry', function()
    DoScreenFadeOut(100)
    while not IsScreenFadedOut() do Wait (10) end
    SetEntityCoords(PlayerPedId(), warehouselocation.x+0.5, warehouselocation.y+0.5, warehouselocation.z)
    TriggerServerEvent('angelicxs-RecylceJob:Server:ActivityUpdater', true)
    SetEntityHeading(PlayerPedId(), warehouselocation.w)
    DoScreenFadeIn(1000)
    while not IsScreenFadedIn() do Wait(10) end
    TriggerEvent('angelicxs-RecylceJob:Notify', Config.Lang['inside_warehouse'], Config.LangType['info'])
    Wait(1000)
    ExitPed = CreatePed(3, HashGrabber(Config.ExitPed), warehouselocation.x, warehouselocation.y, (warehouselocation.z-1), warehouselocation.w, false, false)
    FreezeEntityPosition(ExitPed, true)
    SetEntityInvincible(ExitPed, true)
    SetBlockingOfNonTemporaryEvents(ExitPed, true)
    TaskStartScenarioInPlace(ExitPed,'WORLD_HUMAN_STAND_IMPATIENT', 0, false)
    SetModelAsNoLongerNeeded(Config.ExitPed)
    if Config.ThirdEyeName == 'ox_target' and Config.UseThirdEye then
        exports.ox_target:addLocalEntity(ExitPed, {{
            label = Config.Lang['request_exit'],
            event ='angelicxs-RecylceJob:Exit',
        }})
    end
    DutyPed = CreatePed(3, HashGrabber(Config.DutyPed), dutySpot.x, dutySpot.y, (dutySpot.z-1), dutySpot.w, false, false)
    FreezeEntityPosition(DutyPed, true)
    SetEntityInvincible(DutyPed, true)
    SetBlockingOfNonTemporaryEvents(DutyPed, true)
    TaskStartScenarioInPlace(DutyPed,'WORLD_HUMAN_CLIPBOARD', 0, false)
    SetModelAsNoLongerNeeded(Config.DutyPed)
    if Config.ThirdEyeName == 'ox_target' and Config.UseThirdEye then
        exports.ox_target:addLocalEntity(DutyPed, {{
            label = Config.Lang['sign_in'],
            event = 'angelicxs-RecylceJob:OnDuty',
        }})
    end

    if Config.UseThirdEye then
        if Config.ThirdEyeName == 'ox_target' then
            exports.ox_target:addModel(-14708062, OXoptions.yellow)
            exports.ox_target:addModel(-96647174, OXoptions.blue)
            exports.ox_target:addModel(811169045, OXoptions.green)
            exports.ox_target:addModel(1748268526, OXoptions.trash)
        else
            exports[Config.ThirdEyeName]:AddTargetModel(-14708062, { options = TargetOptions.yellow, distance = 2})
            exports[Config.ThirdEyeName]:AddTargetModel(-96647174, { options = TargetOptions.blue, distance = 2})
            exports[Config.ThirdEyeName]:AddTargetModel(811169045, { options = TargetOptions.green, distance = 2})
            exports[Config.ThirdEyeName]:AddTargetModel(1748268526, { options = TargetOptions.trash, distance = 2})
        end
    end
    if Config.Use3DText then
        for k,v in pairs (Containers) do -- BINS
            CreateThread(function()
                local textlabel = Config.Lang['place_item_3d']..Config.Lang[v.colour]..Config.Lang['sort_item_2']
                while true do
                    local sleep = 1000
                    local dist = #(GetEntityCoords(PlayerPedId())-vector3(v.spot.x, v.spot.y, v.spot.z))
                    if dist > 100 then break end
                    if dist <= 25 then
                        sleep = 500
                        if dist <= 10 then
                            sleep = 0
                            if dist <= 2 then
                                DrawText3Ds(v.spot.x, v.spot.y, v.spot.z, textlabel)
                                if IsControlJustReleased(0, 38) then
                                    SortItem(v.colour)
                                end
                            end
                        end
                    end
                    Wait(sleep)
                end
            end)
        end
        CreateThread(function() -- EXIT
            while true do
                local sleep = 1000
                local dist = #(GetEntityCoords(PlayerPedId())-vector3(warehouselocation.x, warehouselocation.y, warehouselocation.z))
                if dist > 100 then break end
                if dist <= 25 then
                    sleep = 500
                    if dist <= 10 then
                        sleep = 0
                        if dist <= 2 then
                            DrawText3Ds(warehouselocation.x, warehouselocation.y, warehouselocation.z, Config.Lang['request_exit_3d'])
                            if IsControlJustReleased(0, 38) then
                                TriggerEvent('angelicxs-RecylceJob:Exit')
                            end
                        end
                    end
                end
                Wait(sleep)
            end
        end)
        CreateThread(function() -- Duty
            while true do
                local sleep = 1000
                local dist = #(GetEntityCoords(PlayerPedId())-vector3(dutySpot.x, dutySpot.y, dutySpot.z))
                if dist > 100 then break end
                if dist <= 25 then
                    sleep = 500
                    if dist <= 10 then
                        sleep = 0
                        if dist <= 2 then
                            DrawText3Ds(dutySpot.x, dutySpot.y, dutySpot.z, Config.Lang['sign_in_3d'])
                            if IsControlJustReleased(0, 38) then
                                TriggerEvent('angelicxs-RecylceJob:OnDuty')
                            end
                        end
                    end
                end
                Wait(sleep)
            end
        end)
        CreateThread(function() -- Garbage
            while true do
                local sleep = 1000
                local dist = #(GetEntityCoords(PlayerPedId())-vector3(TrashSpot.x, TrashSpot.y, TrashSpot.z))
                if dist > 100 then break end
                if dist <= 25 then
                    sleep = 500
                    if dist <= 10 then
                        sleep = 0
                        if dist <= 3 then
                            DrawText3Ds(TrashSpot.x, TrashSpot.y, TrashSpot.z, Config.Lang['grab_sort_item_3d'])
                            if IsControlJustReleased(0, 38) then
                                if not OnDuty then
                                    TriggerEvent('angelicxs-RecylceJob:Notify', Config.Lang['not_on_duty'], Config.LangType['info'])
                                elseif CurrentSort then
                                    TriggerEvent('angelicxs-RecylceJob:Notify', Config.Lang['not_finished'], Config.LangType['error'])
                                else
                                    BeginSorting()
                                end
                            end
                        end
                    end
                end
                Wait(sleep)
            end
        end)
    end
end)

RegisterNetEvent('angelicxs-RecylceJob:Client:ActivityUpdater', function(colours, cons)
    Containers = cons
    ActiveColour = colours
end)

function SortItem(bincolour)
    if not OnDuty then TriggerEvent('angelicxs-RecylceJob:Notify', Config.Lang['not_on_duty'], Config.LangType['error']) return end
    if not CurrentSort then TriggerEvent('angelicxs-RecylceJob:Notify', Config.Lang['need_trash'], Config.LangType['error']) return end
    if CurrentSort ~= bincolour then TriggerEvent('angelicxs-RecylceJob:Notify', Config.Lang['wrong_bin']..Config.Lang[CurrentSort], Config.LangType['error']) return end
    local ped = PlayerPedId()
    LoadAnim('missfbi4prepp1')
    TaskPlayAnim(ped, 'missfbi4prepp1', '_bag_throw_garbage_man', 8.0, 8.0, 1100, 48, 0.0, 0, 0, 0)
    Wait(1250)
    DetachEntity(prop, 1, false)
    DeleteObject(prop)
    TaskPlayAnim(ped, 'missfbi4prepp1', 'exit', 8.0, 8.0, 1100, 48, 0.0, 0, 0, 0)
    prop = nil
    FreezeEntityPosition(ped, false)
    RemoveAnimDict("missfbi4prepp1")
    SortAnimation()
    TriggerEvent('angelicxs-RecylceJob:Notify', Config.Lang['item_sorted'], Config.LangType['success'])
    TriggerServerEvent('angelicxs-RecylceJob:RandomItem', CurrentSort, GetEntityCoords(PlayerPedId()))
    itemSorted = itemSorted+1
    CurrentSort = false
end

function SortAnimation()
    local Player = PlayerPedId()
    FreezeEntityPosition(Player, true)
    LoadAnim("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
    TaskPlayAnim(Player,"anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer",1.0, -1.0, -1, 49, 0, 0, 0, 0)
    Wait(3000)	
    ClearPedTasks(Player)
    FreezeEntityPosition(Player, false)
    RemoveAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
end

function BeginSorting()
    CurrentSort = true
    local info = false
    while not info do
        info = Randomizer(AvailableColourName)
        if not ActiveColour[info] then info = false end
        Wait(0)
    end
    CurrentSort = info
    SortAnimation()
    local ped = PlayerPedId()
    local bag = HashGrabber('prop_cs_rub_binbag_01')
    prop = CreateObject(bag, 0, 0, 0, true, true, true)
    TaskPlayAnim(ped, 'missfbi4prepp1', '_bag_walk_garbage_man', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 57005), 0.12, 0.0, -0.05, 220.0, 120.0, 0.0, true, true, false, true, 1, true)
    TriggerEvent('angelicxs-RecylceJob:Notify', Config.Lang['sort_item_1']..Config.Lang[info]..Config.Lang['sort_item_2'], Config.LangType['info'])
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

function HashGrabber(model)
    local hash = GetHashKey(model)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end
    while not HasModelLoaded(hash) do
      Wait(10)
    end
    return hash
end

function LoadAnim(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end
end

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.30, 0.30)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        if OnDuty then
            SetEntityCoords(PlayerPedId(), Config.EntryPoint.x, Config.EntryPoint.y, Config.EntryPoint.z)
        end
        OnDuty = false
        CurrentSort = false
        itemSorted = 0
        if DoesEntityExist(prop) then
            DetachEntity(prop, 1, false)
            DeleteObject(prop)
            prop = nil
        end
        if DoesBlipExist(jobBlip) then
            RemoveBlip(jobBlip)
            jobBlip = false
        end
        if EntryPed then
            DeleteEntity(EntryPed)
            EntryPed = nil
        end
        if ExitPed then
            DeleteEntity(ExitPed)
            ExitPed = nil
        end
        if DutyPed then
            DeleteEntity(DutyPed)
            DutyPed = nil
        end
        if Config.UseThirdEye then
            if Config.ThirdEyeName == 'ox_target' then
                exports.ox_target:removeModel(-14708062, OXoptions.yellow)
                exports.ox_target:removeModel(-96647174, OXoptions.blue)
                exports.ox_target:removeModel(811169045, OXoptions.green)
                exports.ox_target:removeModel(1748268526, OXoptions.trash)
            else
                exports[Config.ThirdEyeName]:RemoveTargetModel(-14708062, TargetOptions.yellow.label)
                exports[Config.ThirdEyeName]:RemoveTargetModel(-96647174, TargetOptions.blue.label)
                exports[Config.ThirdEyeName]:RemoveTargetModel(811169045, TargetOptions.green.label)
                exports[Config.ThirdEyeName]:RemoveTargetModel(1748268526, TargetOptions.trash.label)
            end
        end
    end
end)
