# Renewed Duty Blips

Consider supporting me on [ko-fi](https://ko-fi.com/FjamZoo)

## Description
A Dutyblip script that updates blips based on the players job and statebag.

### Features
- Optimized, (1.5-2x faster than similar dutyscripts like qb-policejob)
- Tracking with GPS tracker item
- Configurable blips
- Blips per vehicle class
- Blips per job
- Statebag support (Blips will INSANTLY change to player attached blips as soon as they are close enough)

## Dependencies
- Renewed-Lib
- Ox_Inventory
- Ox_lib
- Esx/Qbox/QB/ox_core

## Installation
1. Download the resource
2. Put it in your resources folder
3. Add `ensure renewed_dutyblips` to your server.cfg
4. Add the following code to your ox_inventory/data/items.lua
```lua
	['gps_tracker'] = {
		label = 'Police Tracker',
		weight = 1000,
		stack = false,
	},
```

### Credits
Thanks to MikeyXB for the tracker image