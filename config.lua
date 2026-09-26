Config = {}

-- ============================================================
--  GENERAL
-- ============================================================

-- Locale used for the boarding pass card and NUI replay.
-- Available out of the box: 'en', 'es', 'fr', 'de', 'it', 'hi'
Config.Locale = 'en'

-- Framework used for ban / whitelist checks and player notifications.
-- 'qb-core'  -> uses exports['qb-core']:GetCoreObject()
-- 'standalone' -> skips framework specific checks/notifications
Config.Framework = 'qb-core'

-- ============================================================
--  "AIRLINE" BRANDING
-- ============================================================

Config.ServerName = 'Los Santos International'   -- shown as the "airline" name on the pass
Config.ServerTag  = 'LSI'                          -- 2-4 letter code used to build flight numbers, e.g. LSI482
Config.ServerLogo = 'https://i.imgur.com/2m0y8AT.png' -- square logo/icon shown on the card + NUI replay

-- ============================================================
--  CONNECTION GATE CHECKS
-- ============================================================

Config.CheckBans = true            -- uses QBCore.Functions.IsPlayerBanned(source) when Config.Framework == 'qb-core'
Config.CheckWhitelist = false      -- uses QBCore.Functions.IsWhitelisted(source) when Config.Framework == 'qb-core'
Config.RequireDiscord = false      -- reject connection if no discord identifier is present

-- How long (seconds) the boarding pass stays on screen before the player is
-- automatically let through if they never press "Board Now".
-- Set to 0 to force players to click the button themselves.
Config.AutoBoardTimeout = 12

-- ============================================================
--  FLIGHT DETAILS (used to flavor each boarding pass)
-- ============================================================

Config.Airports = {
    { code = 'LS', name = 'Los Santos International' },
    { code = 'SF', name = 'San Fierro Intl.' },
    { code = 'LV', name = 'Las Venturas Harry Reid' },
    { code = 'BC', name = 'Blaine County Regional' },
    { code = 'PD', name = 'Paleto Bay Airfield' },
}

Config.Gates = { 'A1', 'A2', 'A3', 'B1', 'B2', 'B3', 'C1', 'C2', 'D1', 'D2' }
Config.Terminals = { 1, 2, 3 }
Config.SeatRows = 32
Config.SeatLetters = { 'A', 'B', 'C', 'D', 'E', 'F' }
Config.TravelClasses = { 'Economy', 'Premium Economy', 'Business', 'First Class' }

-- Minutes from "now" that the printed boarding time will show.
Config.BoardingWindowMinutes = 15

-- ============================================================
--  IN-GAME NUI REPLAY
-- ============================================================

-- Chat command that lets a connected player re-open their boarding pass
Config.Command = 'boardingpass'

-- Show a framework notification a few seconds after spawning, reminding
-- players of their seat/flight number.
Config.ShowWelcomeNotify = true

-- ============================================================
--  DISCORD LOGGING (optional)
-- ============================================================

-- Leave empty to disable. When set, a small "flight log" embed is posted
-- every time a player successfully boards (connects).
Config.DiscordWebhook = ''
Config.DiscordWebhookName = 'Boarding Control'
Config.DiscordWebhookAvatar = ''

-- ============================================================
--  THEME (used by the in-game NUI replay, html/style.css)
-- ============================================================

Config.Theme = {
    primaryColor = '#0b3d91',
    accentColor  = '#ffcc00',
    textColor    = '#ffffff',
}
