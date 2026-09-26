--[[
    connect/server/card.lua

    Builds a deterministic-per-player "boarding pass" data set and the
    Adaptive Card table that gets handed to deferrals.presentCard().
]]

-- Cheap, dependency-free string hash so the same player gets a consistent
-- flight/seat between connections (does not touch the global RNG, so it
-- can't desync other resources that rely on math.random).
local function hashString(str)
    local hash = 5381
    for i = 1, #str do
        hash = (hash * 33 + string.byte(str, i)) % 2147483647
    end
    return hash
end

local function pick(list, seed)
    return list[(seed % #list) + 1]
end

-- Builds the flavor data (flight number, seat, gate, route, etc.) for a
-- connecting player. `seedKey` should be something stable like their
-- license identifier so repeat visits get the same seat.
function BuildBoardingPass(src, name, seedKey)
    local seed = hashString(tostring(seedKey))

    local originIndex = (seed % #Config.Airports) + 1
    local destIndex = (math.floor(seed / 7) % #Config.Airports) + 1
    if destIndex == originIndex then
        destIndex = (destIndex % #Config.Airports) + 1
    end

    local origin = Config.Airports[originIndex]
    local destination = Config.Airports[destIndex]

    local gate = pick(Config.Gates, math.floor(seed / 3))
    local terminal = pick(Config.Terminals, math.floor(seed / 5))
    local seatRow = (seed % Config.SeatRows) + 1
    local seatLetter = pick(Config.SeatLetters, math.floor(seed / 11))
    local travelClass = pick(Config.TravelClasses, math.floor(seed / 13))

    local flightNumber = string.format('%s%03d', Config.ServerTag, (seed % 899) + 100)

    local boardingTimestamp = os.time() + (Config.BoardingWindowMinutes * 60)

    local numPlayers = GetPlayers and #GetPlayers() or 0
    local maxPlayers = tonumber(GetConvar('sv_maxclients', '48')) or 48

    return {
        serverId       = src,
        passengerName  = name,
        flightNumber   = flightNumber,
        seat           = string.format('%d%s', seatRow, seatLetter),
        gate           = gate,
        terminal       = terminal,
        travelClass    = travelClass,
        origin         = origin,
        destination    = destination,
        boardingTime   = os.date('%H:%M', boardingTimestamp),
        boardingDate   = os.date('%d %b %Y', boardingTimestamp),
        serverName     = Config.ServerName,
        serverLogo     = Config.ServerLogo,
        playersOnline  = numPlayers,
        maxPlayers     = maxPlayers,
    }
end

-- Builds the Adaptive Card (as a plain Lua table - deferrals.presentCard
-- accepts either a table or a raw JSON string) shown during playerConnecting.
function BuildCardJson(data, Lang)
    local occupancy = string.format('%d / %d', data.playersOnline or 0, data.maxPlayers or 0)

    return {
        type = 'AdaptiveCard',
        ['$schema'] = 'http://adaptivecards.io/schemas/adaptive-card.json',
        version = '1.3',
        body = {
            {
                type = 'Container',
                style = 'emphasis',
                bleed = true,
                items = {
                    {
                        type = 'ColumnSet',
                        columns = {
                            {
                                type = 'Column',
                                width = 'auto',
                                items = {
                                    { type = 'Image', url = data.serverLogo, size = 'Small', style = 'Person' },
                                },
                            },
                            {
                                type = 'Column',
                                width = 'stretch',
                                items = {
                                    { type = 'TextBlock', text = data.serverName, size = 'Large', weight = 'Bolder', wrap = true },
                                    { type = 'TextBlock', text = Lang.title, isSubtle = true, spacing = 'None', wrap = true },
                                },
                            },
                        },
                    },
                },
            },
            {
                type = 'ColumnSet',
                spacing = 'Medium',
                columns = {
                    {
                        type = 'Column',
                        width = 'stretch',
                        items = {
                            { type = 'TextBlock', text = Lang.from, isSubtle = true, size = 'Small' },
                            { type = 'TextBlock', text = data.origin.code, size = 'ExtraLarge', weight = 'Bolder' },
                            { type = 'TextBlock', text = data.origin.name, wrap = true, size = 'Small' },
                        },
                    },
                    {
                        type = 'Column',
                        width = 'auto',
                        verticalContentAlignment = 'Center',
                        items = {
                            { type = 'TextBlock', text = '✈', size = 'Large', horizontalAlignment = 'Center' },
                        },
                    },
                    {
                        type = 'Column',
                        width = 'stretch',
                        items = {
                            { type = 'TextBlock', text = Lang.to, isSubtle = true, size = 'Small', horizontalAlignment = 'Right' },
                            { type = 'TextBlock', text = data.destination.code, size = 'ExtraLarge', weight = 'Bolder', horizontalAlignment = 'Right' },
                            { type = 'TextBlock', text = data.destination.name, wrap = true, size = 'Small', horizontalAlignment = 'Right' },
                        },
                    },
                },
            },
            {
                type = 'FactSet',
                spacing = 'Medium',
                facts = {
                    { title = Lang.passenger, value = data.passengerName },
                    { title = Lang.flight, value = data.flightNumber },
                    { title = Lang.seat, value = data.seat },
                    { title = Lang.gate .. ' / ' .. Lang.terminal, value = string.format('%s / %s', data.gate, tostring(data.terminal)) },
                    { title = Lang.class, value = data.travelClass },
                    { title = Lang.boarding_time, value = string.format('%s - %s', data.boardingDate, data.boardingTime) },
                    { title = 'Occupancy', value = occupancy },
                },
            },
            {
                type = 'TextBlock',
                text = string.format('%s: %s', Lang.status, Lang.status_ready),
                weight = 'Bolder',
                color = 'Good',
                spacing = 'Medium',
            },
            {
                type = 'TextBlock',
                text = string.format(Lang.footer, data.serverName),
                isSubtle = true,
                wrap = true,
                size = 'Small',
                spacing = 'Medium',
            },
        },
        actions = {
            {
                type = 'Action.Submit',
                title = Lang.button_board,
                style = 'positive',
                id = 'board',
                data = { action = 'board' },
            },
        },
    }
end
