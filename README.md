# connect — Custom Boarding Pass Connecting Screen

A standalone FiveM resource built for **[qb-core](https://github.com/qbcore-fivem/qb-core)**
that replaces the boring default connecting screen with an airline-style

While a player connects, the server generates a personalized boarding pass
(flight number, seat, gate, terminal, class, route, boarding time) using an
[Adaptive Card](https://adaptivecards.io/) shown through FiveM's native
`deferrals.presentCard`. Ban/whitelist checks run first, so rejected players
never see the pass. Once "boarded", players can bring the same pass back up
in-game with a chat command.

## Features

- 🎫 **Boarding pass connecting screen** rendered natively during `playerConnecting`
  (no extra client download screen, works before any other resource starts).
- ✈️ **Deterministic flight details** — flight number, seat, gate, terminal,
  travel class and route are generated per player and stay the same across
  reconnects (seeded from their Rockstar license).
- 🛂 **QB-Core ban & whitelist checks** run before the pass is shown
  (`QBCore.Functions.IsPlayerBanned` / `IsWhitelisted`), with clean rejection
  messages instead of a blank "connection refused".
- 🔒 Optional "Discord account required" gate.
- 🌍 **6 languages included**: English, Spanish, French, German, Italian and
  Hindi — switch with one config line, or add your own in `locales/`.
- 🖥️ **In-game NUI replay** — players can run `/boardingpass` any time after
  joining to view their pass again, styled as a real ticket (perforated tear,
  barcode, seat stub).
- 🔔 Optional Discord webhook "flight log" posted every time someone boards.
- ⚙️ Fully config-driven — server name/logo, airports, gates, seat map, travel
  classes, theme colors, auto-continue timeout, etc.
- 🧩 Works with `Config.Framework = 'standalone'` if you don't run qb-core
  (ban/whitelist checks and notifications are simply skipped).

## How it works

FiveM lets a resource defer a player's connection and show them a native
[Adaptive Card](https://adaptivecards.io/) via `deferrals.presentCard()`
before they ever load into the world. This resource hooks `playerConnecting`,
runs your ban/whitelist checks, then builds and shows the boarding pass card.
When the player clicks **Board Now** (or after `Config.AutoBoardTimeout`
seconds, whichever comes first) the connection is allowed to continue.

```
playerConnecting
   ├─ verify Rockstar license present
   ├─ (optional) require linked Discord
   ├─ (optional) QBCore ban check         -> reject with reason if banned
   ├─ (optional) QBCore whitelist check   -> reject if not whitelisted
   ├─ build boarding pass (flight/seat/gate/route/etc.)
   ├─ deferrals.presentCard(boardingPassCard)
   └─ deferrals.done() once boarded (button click or timeout)
```

## Installation

1. Copy this folder into your server's `resources` directory. You can keep
   the folder name `connect` or rename it — just make sure the name you use
   in `server.cfg` matches the folder name.
2. Add to your `server.cfg`, **above** `qb-core` if you want ban/whitelist
   checks to work as soon as players connect (qb-core still needs to be
   started for `GetCoreObject()` to resolve — the script waits/retries
   gracefully if it isn't ready yet):
   ```cfg
   ensure qb-core
   ensure connect
   ```
3. Edit `config.lua` (see below) — at minimum set `Config.ServerName`,
   `Config.ServerTag` and `Config.ServerLogo`.
4. Restart your server.

## Configuration

All options live in `config.lua`:

| Setting | Description |
| --- | --- |
| `Config.Locale` | `'en'`, `'es'`, `'fr'`, `'de'`, `'it'`, `'hi'` |
| `Config.Framework` | `'qb-core'` or `'standalone'` |
| `Config.ServerName` / `ServerTag` / `ServerLogo` | Branding shown on the pass |
| `Config.CheckBans` / `Config.CheckWhitelist` | Toggle QB-Core gate checks |
| `Config.RequireDiscord` | Reject connections without a linked Discord |
| `Config.AutoBoardTimeout` | Seconds before auto-continuing if the player doesn't click "Board Now" (`0` = require the click) |
| `Config.Airports` / `Gates` / `Terminals` / `SeatRows` / `SeatLetters` / `TravelClasses` | Flavor pools used to build each boarding pass |
| `Config.BoardingWindowMinutes` | How far in the future the printed boarding time is |
| `Config.Command` | Chat command to reopen the pass in-game (default `/boardingpass`) |
| `Config.ShowWelcomeNotify` | Show a "Welcome aboard" notification after spawn |
| `Config.DiscordWebhook` | Optional webhook URL for a "flight boarded" log embed |
| `Config.Theme` | Colors used by the in-game NUI replay |

### Adding a language

Copy `locales/en.lua` to `locales/xx.lua`, translate the values, and set
`Config.Locale = 'xx'`.

### Hooking other resources

An event fires every time a player successfully boards:

```lua
AddEventHandler('connect:playerBoarded', function(source, boardingPassData)
    -- boardingPassData: passengerName, flightNumber, seat, gate, terminal,
    -- travelClass, origin, destination, boardingTime, boardingDate, serverId
end)
```

You can also pull a player's current pass from another resource:

```lua
local pass = exports['connect']:GetBoardingPass(source)
```

## File structure

```
connect/
├── fxmanifest.lua
├── config.lua
├── locales/            -- en, es, fr, de, it, hi
├── server/
│   ├── card.lua         -- builds boarding pass data + the Adaptive Card
│   └── main.lua         -- playerConnecting handler, ban/whitelist checks
├── client/
│   └── main.lua         -- welcome notify + /boardingpass NUI replay
└── html/                -- NUI ticket UI (index.html, style.css, script.js)
```

## Notes & credits

This is an original implementation built for this repository — it does not
reuse code from any paid/closed-source script.
[forum thread](https://forum.cfx.re/t/standalone-sha4ows-boarding-pass-script-new-update/5151906)
linked above) but was written from scratch against FiveM's public
`deferrals`/Adaptive Card API and qb-core's public exports, so you're free to
read, modify and extend every part of it.
