--[[
    connect/server/main.lua

    Custom QB-Core "boarding pass" connecting screen.
    Shows an Adaptive Card themed like an airline boarding pass while the
    player connects, running ban/whitelist checks before it does.
]]

local Lang = Locales[Config.Locale] or Locales['en']

local QBCore = nil
if Config.Framework == 'qb-core' then
    CreateThread(function()
        local ok, core = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        if ok then
            QBCore = core
        else
            print('^1[connect]^7 Config.Framework is "qb-core" but qb-core could not be reached. Ban/whitelist checks will be skipped.')
        end
    end)
end

-- Stores the most recently generated boarding pass per player so the
-- /boardingpass NUI replay and the discord webhook can reuse it.
local boardingPasses = {}

local function getIdentifier(identifiers, prefix)
    for _, id in ipairs(identifiers) do
        if string.find(id, prefix, 1, true) then
            return id
        end
    end
    return nil
end

local function postDiscordLog(data)
    if not Config.DiscordWebhook or Config.DiscordWebhook == '' then return end

    local embed = {
        {
            title = string.format('✈ Flight %s Boarded', data.flightNumber),
            color = 3900150,
            fields = {
                { name = Lang.passenger, value = data.passengerName, ['short'] = true },
                { name = Lang.seat, value = data.seat, ['short'] = true },
                { name = Lang.gate, value = data.gate, ['short'] = true },
                { name = Lang.from .. ' / ' .. Lang.to, value = string.format('%s -> %s', data.origin.code, data.destination.code), ['short'] = true },
            },
            footer = { text = data.serverName },
            timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        },
    }

    PerformHttpRequest(Config.DiscordWebhook, function() end, 'POST', json.encode({
        username = Config.DiscordWebhookName,
        avatar_url = Config.DiscordWebhookAvatar ~= '' and Config.DiscordWebhookAvatar or nil,
        embeds = embed,
    }), { ['Content-Type'] = 'application/json' })
end

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    local identifiers = GetPlayerIdentifiers(src)

    deferrals.defer()

    -- Mandatory: the game freezes the connecting player's thread until at
    -- least one frame has passed after defer() is called.
    Wait(0)

    deferrals.update(string.format(Lang.connecting, name))
    Wait(300)

    local license = getIdentifier(identifiers, 'license:') or getIdentifier(identifiers, 'license2:')
    local discord = getIdentifier(identifiers, 'discord:')

    if not license then
        deferrals.done(Lang.no_license)
        return
    end

    if Config.RequireDiscord and not discord then
        deferrals.done(Lang.discord_required)
        return
    end

    if Config.CheckBans then
        deferrals.update(Lang.checking_ban)
        Wait(250)

        local banned, reason = false, nil
        if QBCore and QBCore.Functions and QBCore.Functions.IsPlayerBanned then
            banned, reason = QBCore.Functions.IsPlayerBanned(src)
        end

        if banned then
            deferrals.done(reason or Lang.banned_generic)
            return
        end
    end

    if Config.CheckWhitelist then
        deferrals.update(Lang.checking_whitelist)
        Wait(250)

        local whitelisted = true
        if QBCore and QBCore.Functions and QBCore.Functions.IsWhitelisted then
            whitelisted = QBCore.Functions.IsWhitelisted(src)
        end

        if not whitelisted then
            deferrals.done(Lang.not_whitelisted)
            return
        end
    end

    local data = BuildBoardingPass(src, name, license)
    boardingPasses[src] = data

    local card = BuildCardJson(data, Lang)
    local resolved = false

    local function finishBoarding()
        if resolved then return end
        resolved = true
        deferrals.done()
        postDiscordLog(data)
        TriggerEvent('connect:playerBoarded', src, data)
    end

    deferrals.presentCard(card, function(submitData, rawData)
        finishBoarding()
    end)

    if Config.AutoBoardTimeout and Config.AutoBoardTimeout > 0 then
        CreateThread(function()
            Wait(Config.AutoBoardTimeout * 1000)
            finishBoarding()
        end)
    end
end)

AddEventHandler('playerDropped', function()
    boardingPasses[source] = nil
end)

RegisterNetEvent('connect:requestBoardingPass', function()
    local src = source
    local data = boardingPasses[src]
    if data then
        TriggerClientEvent('connect:receiveBoardingPass', src, data)
    end
end)

exports('GetBoardingPass', function(src)
    return boardingPasses[src]
end)
