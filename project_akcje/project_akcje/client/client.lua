ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	
	Citizen.Wait(5000)
    PlayerData = ESX.GetPlayerData()
end)

-- ---------------------- MARKER ------------------
--[[Citizen.CreateThread(function()

     while true do
         Citizen.Wait(1)
         local coords = GetEntityCoords(PlayerPedId())

         if GetDistanceBetweenCoords(coords, Config.MarkerCoords.x, Config.MarkerCoords.y, Config.MarkerCoords.z, true) <= 7 then
             DrawMarker(27, Config.MarkerCoords.x, Config.MarkerCoords.y, Config.MarkerCoords.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.5, 0,55, 108, 147, false, false, 2, false, false, false, false)
         end

         if GetDistanceBetweenCoords(coords, Config.MarkerCoords.x, Config.MarkerCoords.y, Config.MarkerCoords.z, true) <= 1.7 then
            ESX.ShowHelpNotification("Naciśnij ~INPUT_CONTEXT~ aby zarządzać swoimi akcjami")
            if IsControlJustPressed(1, 38) then
                
                ESX.TriggerServerCallback('project_akcje:getActions', function(result)
                    ownedActions(result)
                    SetDisplay(true)
                end, PlayerPedId())
             end
         end

         if IsControlJustPressed(1, 200) then
            SetNuiFocus(false, false)
             SetDisplay(false)
         end
    end
end)]]

--------------------- EVENT --------------------
RegisterNetEvent('project_akcje:openMenu')
AddEventHandler('project_akcje:openMenu', function()
    ESX.TriggerServerCallback('project_akcje:getActions', function(result)
        ownedActions(result)
        SetDisplay(true)
    end, PlayerPedId())
end)


function ownedActions(result)
    for i=1, #result do
        SendNUIMessage({
            type = 'actions',
            companyName = result[i].company_name,
            count = result[i].count,
            short = result[i].company_short
        })
    end
end

function SetDisplay(bool)
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool,
    })
end

RegisterCommand('relog', function()
    SetNuiFocus(false,false)
    SetNuiFocusKeepInput(false)
end)

RegisterNUICallback('NUIClose', function()
    SetNuiFocus(false,false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({type = 'ui', status = false})
end)

RegisterNUICallback('insertGielda', function()
    ESX.TriggerServerCallback('project_akcje:getGielda', function(result)
        for i=1, #result do
            SendNUIMessage({
                type = 'showGielda',
                short = result[i].company_short,
                companyName = result[i].company_name,
                changePer = tonumber(result[i].change_per),
                changeDol = tonumber(result[i].change_dol),
                price = tonumber(result[i].price)
            })
        end
    end, PlayerPedId())
end)

RegisterNUICallback('insertAkcje', function()
    ESX.TriggerServerCallback('project_akcje:getActions', function(result)
        ownedActions(result)
    end, PlayerPedId())
end)

RegisterNUICallback('buyActions', function(data, cb)
    TriggerServerEvent('project_akcje:buy', data.name, data.short, data.count)
end)

RegisterNUICallback('sellActions', function(data, cb)
    TriggerServerEvent('project_akcje:sell', data.name, data.short, data.count, data.ownedCount)
end)