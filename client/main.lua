--[[
    connect/client/main.lua

    Handles the post-join welcome notification and the /boardingpass NUI
    replay so players can pull their boarding pass back up at any time.
]]

local Lang = Locales[Config.Locale] or Locales['en']

local QBCore = nil
if Config.Framework == 'qb-core' then
    CreateThread(function()
        local ok, core = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        if ok then QBCore = core end
    end)
end

local boardingPassData = nil

local function notify(msg)
    if QBCore and QBCore.Functions and QBCore.Functions.Notify then
        QBCore.Functions.Notify(msg, 'success', 8000)
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(msg)
        EndTextCommandThefeedPostTicker(false, true)
    end
end

RegisterNetEvent('connect:receiveBoardingPass', function(data)
    boardingPassData = data

    if Config.ShowWelcomeNotify then
        notify(string.format(Lang.welcome_notify, data.flightNumber, data.seat))
    end
end)

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(250)
    end
    Wait(1500)
    TriggerServerEvent('connect:requestBoardingPass')
end)

local function openBoardingPass()
    if not boardingPassData then
        TriggerServerEvent('connect:requestBoardingPass')
        Wait(300)
    end

    if not boardingPassData then return end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'show',
        data = boardingPassData,
        labels = Lang,
        theme = Config.Theme,
    })
end

RegisterCommand(Config.Command or 'boardingpass', function()
    openBoardingPass()
end, false)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)
