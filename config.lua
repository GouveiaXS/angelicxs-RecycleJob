----------------------------------------------------------------------
-- Thanks for supporting AngelicXS Scripts!							--
-- Support can be found at: https://discord.gg/tQYmqm4xNb			--
-- More paid scripts at: https://angelicxs.tebex.io/ 				--
-- More FREE scripts at: https://github.com/GouveiaXS/ 				--
-- Images are provided for new items if you choose to add them 		--
----------------------------------------------------------------------

-- Model info: https://docs.fivem.net/docs/game-references/ped-models/
-- Blip info: https://docs.fivem.net/docs/game-references/blips/

Config = {}

Config.UseESX = false						-- Use ESX Framework
Config.UseQBCore = true						-- Use QBCore Framework (Ignored if Config.UseESX = true)

Config.UseCustomNotify = false				-- Use a custom notification script, must complete event below.
-- Only complete this event if Config.UseCustomNotify is true; mythic_notification provided as an example
RegisterNetEvent('angelicxs-RecylceJob:CustomNotify')
AddEventHandler('angelicxs-RecylceJob:CustomNotify', function(message, type)
    --exports.mythic_notify:SendAlert(type, message, 4000)
    --exports['okokNotify']:Alert('', Message, 4000, type, false)
end)

-- Visual Preference
Config.Use3DText = true 					-- Use 3D text for NPC/Job interactions; only turn to false if Config.UseThirdEye is turned on and IS working.
Config.UseThirdEye = true 					-- Enables using a third eye (third eye requires the following arguments debugPoly, useZ, options {event, icon, label}, distance)
Config.ThirdEyeName = 'qb-target' 			-- Name of third eye aplication
Config.JobBlip = true                                       -- Puts a blip on the map of where to enter the recycle map
Config.JobBlipSprite = 478                                  -- Blip Sprite
Config.JobBlipColour = 12                                   -- Colour of blip on map
Config.JobBlipName = "AngelicXS' Recycling Depot"           -- Name of blip on map


Config.AccountMoney = 'cash'                -- What type of money they will get ('money', 'cash', 'bank' etc.)
Config.FlatAmount = 100                     -- How much money they will receive per sort turn in, only applies if Config.RandomAmount = false
Config.RandomAmount = true                  -- If true, randomizes the amount of money that will be paid per sort turn in
Config.MinAmount = 50                       -- If Config.RandomAmount = true, is the minimum amount paid per sort turn in
Config.MaxAmount = 150                      -- If Config.RandomAmount = true, is the maximum amount paid per sort turn in

Config.EntryPoint = vector4(850.36, -1995.43, 29.98, 78.68) -- Entry spot to get to recycle depot
Config.EntryPed = 'u_m_y_smugmech_01'                       -- Entry ped model
Config.RecycleDepot = vector4(1087.34, -3099.42, -39.0, 270.00) -- Entrance to actual interior
Config.ExitPed = 's_m_y_garbage'                            -- Exit ped model
Config.DutySpot = vector4(1088.38, -3102.97, -39.0, 328.57)     -- Where players clock in/out to do job
Config.DutyPed = 's_m_y_airworker'                          -- Duty ped model
Config.TrashBin = vector4(1095.69, -3102.79, -39.0, 180.00)     -- Where players get inital trash to sort
Config.FurtherstBin = 20                                        -- How far away in units the trash bin is from the furthest recycle bin (anti-cheat protection)
Config.RecycleBins = {                                          -- Bins where players sort trash, you may add or remove spots by copying the format below !! ONLY CHANGE THE VECTOR4 !!!
    { spot = vector4(1088.73, -3096.62, -39.0, 0.0), entity = nil, colour = nil },
    { spot = vector4(1091.25, -3096.56, -39.0, 0.0), entity = nil, colour = nil },
    { spot = vector4(1095.04, -3096.53, -39.0, 0.0), entity = nil, colour = nil },
    { spot = vector4(1097.59, -3096.51, -39.0, 0.0), entity = nil, colour = nil },
    { spot = vector4(1101.19, -3096.56, -39.0, 0.0), entity = nil, colour = nil },
    { spot = vector4(1103.81, -3096.68, -39.0, 0.0), entity = nil, colour = nil },
}
Config.GetRandomItemChance = 50             -- Change to receive an item when sorting
Config.RandomItemList = {                   -- List of items that can be recieved, you can customize what items can be found in each bin by putting them in the correct category (yellow, blue, green) below.
    ['yellow'] = {
        {item = 'metalscrap', min = 1, max = 5},
        {item = 'plastic', min = 1, max = 5},
    },
    ['blue'] = {
        {item = 'metalscrap', min = 1, max = 5},
        {item = 'plastic', min = 1, max = 5},
    },
    ['green'] = {
        {item = 'metalscrap', min = 1, max = 5},
        {item = 'plastic', min = 1, max = 5},
    },
}

-- Language Configuration
Config.LangType = {
	['error'] = 'error',
	['success'] = 'success',
	['info'] = 'primary'
}

Config.Lang = {
	['request_entry_3d'] = "Press ~r~[E]~w~ to enter recycling depot",
    ['request_entry'] = "Enter Recycling Depot",
    ['request_exit_3d'] = "Press ~r~[E]~w~ to exit recycling depot",
    ['request_exit'] = "Exit Recycling Depot",
    ['inside_warehouse'] = "You have entered the recycling depot!",
    ['grab_sort_item_3d'] = "Press ~r~[E]~w~ to grab item to sort",
    ['grab_sort_item'] = "Grab Item to Sort",
    ['place_item_3d'] = "Press ~r~[E]~w~ to place item in ",
    ['sign_in'] = "Clock In/Out",
    ['sign_in_3d'] = "Press ~r~[E]~w~ to clock in or out ",
    ['place_item'] = "Place Item in ",
    ['wrong_bin'] = "This is the wrong bin! The bin you are looking for is ",
    ['right_bin'] = "You have correctly sorted the item and can grab another!",
    ['not_finished'] = "You have not sorted the last item you picked up!",
    ['onduty'] = "You have clocked in to work at the recycling depot, you will get paid when you clock out!",
    ['offduty'] = "You have clocked off at the recycling depot and have been paid $",
    ['not_on_duty'] = "You need to be clocked in to do this, clock in at the clipboard manager!",
    ['early_leave'] = "You left the recycling depot without clocking out, all your hard work has been lost.",
    ['sort_item_1'] = "The items you picked up need to go to a ",
    ['sort_item_2'] = " bin!",
    ['item_sorted'] = 'You placed the item in the correct recycling bin!',
    ["yellow"] = "YELLOW",
    ["blue"] = "BLUE",
    ["green"] = "GREEN",
    ['item_find_1'] = "You found some perfectly good " ,
    ['item_find_2'] = "might as well keep it!" ,
    ['need_trash'] = "Grab trash to sort from the trash bin first!",
}