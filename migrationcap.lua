-- Tries to limit migration waves to a given cap. Allows gradual increase in popcap.

--[====[

A derivation of fix/population-cap.

This script will try and limit the size of incoming migrant waves (not including the two hardcoded ones), up to a given value that must be less than or equal to the init file popcap.

-Qvatch 2020-11-20: v1.0

Features to add: [TODO]
-address babycap
-just read the init file for the actual popcap
-can we see/use the hardcap?
]====]
local utils = require('utils')
local validArgs = utils.invert({ 'wavecap', 'targetpop', 'help', 'verbose', 'enable', 'disable', 'setup_popcap', 'trialrun', 'persist', 'resume' ,'status'})
local args = utils.processArgs({ ... }, validArgs)

--local ui = df.global.ui
local ui_stats = df.global.ui.tasks
local civ = df.historical_entity.find(df.global.ui.civ_id)

if not civ then
    qerror('Migrationcap cancelled, No active fortress.')
end

local helpme = [===[

migrationcap.lua
================
This script attempts to limit the number of migrants per migration wave. Slower migration lets you get to know the dwarves more without getting overwhelmed.

This script is based on fix/population-cap, and thus shares its' limitations. Of note:  migration waves will have 0-2 bonus dwarves.

Notes: This script cannot override the init file popcap, babycap, etc. It only adjusts the softcap. It is unable to pass the actual popcap, even if you set targetpop > whatever the actual popcap is in the init file.
    Also, the two hardcoded waves are not affected.

You must supply a -setup_popcap on the first run.

Sample call: migrationcap -setup_popcap 200 -targetpop 40 -wavecap 3 -enable -persist
   tells migrationcap that your init file says the popcap is 200, that you want to play with a popcap of 40, limit waves to 3 (always up to 2 more could occur), enable monitoring, save settings to the savegame that they can be resumed on next load with 'migrationcap -resume'.

arguments:
    -help
        print this help message, then exit.

    -status
        Prints a list of the current settings, then exits.

    -verbose
        prints debug data to the dfhack console. Default is false

    -targetpop #
        What is our goal population? (must be <= init file popcap)
        eg. to set the migration goal to 50: "migrationcap -targetpop 50"

    -popcap [TODO]
        set the popcap (init file option) directly.

    -setup_popcap # [default 99999]
        inform the plugin of the init file popcap
        todo: figure out how to read this in.

    -wavecap [default=5]
        Set the maximum (soft) cap per migration wave
        eg. to set the maximum size of a migration wave to 10: "migrationcap -wavecap 10"

    -enable
        Enable monitoring, will keep running (until game exit)  (via a 'repeat ... ' command)
        Otherwise it will be once-off, until the next caravan returns to the mountainhome.

    -disable
        Disable the script (next wave will be applied normally)

    -persist [default=false]
        Save these migrationcap options [popcap, targetpop, wavecap] to the DF savegame you are currently playing.
        If this flag is used, it automatically adds -enable

    -resume
        Load and enable previously set migrationcap for this save. Adding "migrationcap -resume" to your onLoad.init file should allow automatic operation.

]===]

print("\n\n\n")

-- Handle help requests
if args.help then
    print(helpme)
    return
end

if args.status then
    if not _G.migrationcap then
        print("Migration cap is not yet configured")
    end

    local persistopts = dfhack.persistent.get("migrationcap.lua saved options")
    if persistopts == nil then
        print("Migrationcap cannot resume, no saved options found for this savegame.")
    else
        print("\nMigrationcap resume possible, options in this savegame are:")
        print("\tInit file popcap: " .. persistopts.ints[1] .. ", target pop:" .. persistopts.ints[2] .. ", max wave size: " .. persistopts.ints[3]..", monitoring enabled? "..persistopts.ints[4])
        print("\tLoad these with 'migrationcap -resume'. Will resume monitoring if it was saved.")
    end


    if _G.migrationcap ~= nil then
        print("\nCurrent settings are:")
        print("\tsetup_popcap: " .. _G.migrationcap.popcap .. ",   targetpop: " .. _G.migrationcap.targetpopcap ..  ",  wavecap: " .. _G.migrationcap.migrationwavecap)

        if _G.migrationcap.autorepeat then
            print("\nMigrationcap monitoring is enabled.")
            print("\t targetpop: ".._G.migrationcap.autosettings[1]..", wavecap: ".._G.migrationcap.autosettings[2])
            print("\trerun 'migrationcap -enable' if you wish the current settings to be used instead.")
        else
            print("\nMigrationcap monitoring is disabled.")
        end
    end

    print("\nCiv thinks our population is: " .. civ.activity_stats.population)

    return
end



if not _G.migrationcap then
    --first run. Setup persistant memory structure.
    --todo: load/save from actual persistant(between-loads) world memory
    _G.migrationcap = {}
    _G.migrationcap.popcap=99999
    _G.migrationcap.wavecap = 5
    --_G.migrationcap.setup_popcap = 99999
    _G.migrationcap.targetpop = 99999
    _G.migrationcap.civpopreport = civ.activity_stats.population --the last fort pop reported to the civ. So we can undo.
    --todo: detect change in civpopreport from caravan return.
    _G.migrationcap.civpopreport_new=-1 --when we set the civpopreport we copy it here, so that if civpopreport is changed externally (eg caravan reports back) we can detect it.
    _G.migrationcap.civpopreport_old=-1
    _G.migrationcap.autorepeat=false
    _G.migrationcap.autosettings={}
end

--set defaults
local verbose = false
local wavecap=_G.migrationcap.wavecap
local setup_popcap=_G.migrationcap.popcap
local targetpop=_G.migrationcap.targetpop
local trialrun = false
local enable = false
local todisable = false
local persist = false --save to savegame for resume on load
local onresume = false --becomes true when migrationcap called with no options, AND a persistant save exists in this savegame.




--check called options
if (args.verbose) then
    verbose = true
end

if (args.wavecap) then
    wavecap = tonumber(args.wavecap)
    _G.migrationcap.wavecap=wavecap
else
    wavecap=_G.migrationcap.wavecap
end

if (args.targetpop) then
    targetpop = tonumber(args.targetpop)
    _G.migrationcap.targetpop=targetpop
else
    targetpop=_G.migrationcap.targetpop
end

if (args.setup_popcap) then
    setup_popcap = tonumber(args.setup_popcap)
    _G.migrationcap.popcap=setup_popcap
else
    setup_popcap=_G.migrationcap.popcap
end

if (args.enable) then
    enable = true
end
if (args.disable) then
    todisable = true
end

if (args.trialrun) then
    trialrun = true
end

if (args.persist) then
    persist = true
end

if (args.resume) then
    onresume = true
end



--from https://github.com/DFHack/scripts/blob/master/spawnunit.lua#L24
function extend(tbl, tbl2)
    for _, v in pairs(tbl2) do
        table.insert(tbl, v)
    end
end

--Begin
local civ_stats = civ.activity_stats


if (civ_stats.population ~= _G.migrationcap.civpopreport_new) then
    print("Migration update required!")
end



if setup_popcap ~=99999 then
    _G.migrationcap.popcap = setup_popcap --what the init says popcap is
elseif _G.migrationcap.popcap==99999 and not onresume then
    qerror("Please run 'migrationcap -setup_popcap #', where # is the current popcap in your init file.")
    return
end



targetpop = math.min(targetpop, setup_popcap)
_G.migrationcap.targetpopcap = targetpop --what we want the popcap to be (limited by the init file popcap)
_G.migrationcap.migrationwavecap = wavecap --what we want as the max im

if not civ_stats then
    if args[1] ~= 'force' then
        qerror('No caravan report object; use "fix/population-cap force" to create one')
    end
    print('Creating an empty statistics structure...')
    civ.activity_stats = {
        new = true,
        created_weapons = { resize = #ui_stats.created_weapons },
        discovered_creature_foods = { resize = #ui_stats.discovered_creature_foods },
        discovered_creatures = { resize = #ui_stats.discovered_creatures },
        discovered_plant_foods = { resize = #ui_stats.discovered_plant_foods },
        discovered_plants = { resize = #ui_stats.discovered_plants },
    }
    civ_stats = civ.activity_stats
end

local poproom = _G.migrationcap.targetpopcap - ui_stats.population --how many citizens can we allow?

if verbose then
    print("---DEBUG INFO::\tPopcap: " .. _G.migrationcap.popcap .. ",  ourpop: " .. ui_stats.population .. ",  wavecap: " .. _G.migrationcap.migrationwavecap .. ",  civ thinks: " .. civ.activity_stats.population .. ",  we can accept:  " .. poproom .. ",   target pop: " .. _G.migrationcap.targetpopcap.."    ,   civ last set at: ".._G.migrationcap.civpopreport_new)

end

--[[if (civ.activity_stats.population ~= _G.migrationcap.civpopreport) and (civ.activity_stats.population ~= (_G.migrationcap.popcap-wavecap)) then
    print("Migrationcap.lua: civ population report has changed, update required or next wave will be unconstrained.")
    _G.migrationcap.civpopreport=civ.activity_stats.population
end--]]

if not trialrun then
    if persist then
        dfhack.persistent.save({ key = "migrationcap.lua saved options", setup_popcap, targetpop, wavecap })
        local persist = dfhack.persistent.save { key = 'migrationcap.lua saved options' }
        --persist.value=transformation
        persist.ints[1] = setup_popcap
        persist.ints[2] = targetpop
        persist.ints[3] = wavecap
        if _G.migrationcap.autorepeat then
            persist.ints[4] = 1
        end
        --every other int can be used, of course
        persist:save()
        print("Saving migrationcap options to this savegame.")


    elseif onresume then
        enable = true
        local persistopts = dfhack.persistent.get("migrationcap.lua saved options")
        if persistopts == nil then
            print("migrationcap.lua cannot resume, no saved options found for this savegame.")
        end
        setup_popcap = persistopts.ints[1]
        targetpop = persistopts.ints[2]
        wavecap = persistopts.ints[3]
        _G.migrationcap.autorepeat=persistopts.ints[4]
        print("Migrationcap.lua resuming: init file popcap: " .. setup_popcap .. ", target pop:" .. targetpop .. ", max wave size: ~" .. wavecap)
        if _G.migrationcap.autorepeat == 1 then
            print("\tMonitoring resuming")
            _G.migrationcap.autorepeat=true
            dfhack.run_command( "migrationcap -resume")
        else
            _G.migrationcap.autorepeat=false
        end
        _G.migrationcap.popcap=setup_popcap
    end

    if enable then
        print("enabling repeat command")
        --[[local newargs={}
        extend(newargs, {'-name', "migrationcaps"})
        extend(newargs, {'-time', "1"})
        extend(newargs, {'-timeUnits', "days"})
        extend(newargs, {'-command', "[ migrationcap -targetpop " .. targetpop .. " -wavecap " .. wavecap .. " ]"})
        --print_all(newargs)
        --]]
        --local newargs={'repeat','-name', "migrationcaps",'-time', "1",'-timeUnits', "days",'-command', "[ migrationcap -targetpop " .. targetpop .. " -wavecap " .. wavecap .. " ]"}
        --dfhack.run_script('repeat', {'-name', "migrationcaps",'-time', "1",'-timeUnits', "days",'-command', "[ migrationcap -targetpop " .. targetpop .. " -wavecap " .. wavecap .. " ]"})
        --dfhack.run_script_with_env(nil,'repeat',{name="migrationcaps", time="1", timeUnits="days", command="[ migrationcap -targetpop 100 -wavecap 1 ]"})
        --[[local repeatUtil = require 'repeat-util'
        repeatUtil.scheduleEvery("migrationcaps",1,"days","migrationcap -targetpop " .. targetpop .. " -wavecap " .. wavecap .. "")
        --]]
        dfhack.run_command( "repeat -name migrationcaps -time 1 -timeUnits days -command ".."[ migrationcap -targetpop " .. targetpop .. " -wavecap " .. wavecap .. " ]")--table.unpack(newargs))
        _G.migrationcap.autorepeat=true
        _G.migrationcap.autosettings={targetpop,wavecap}
    elseif todisable then
        print("disabling repeat command")
        dfhack.run_script('repeat',  table.unpack({'-cancel', 'migrationcaps'}))--,' -cancel migrationcaps')--
        _G.migrationcap.autorepeat=false
        _G.migrationcap.autosettings={}
    else
        _G.migrationcap.civpopreport_old=civ_stats.population
        civ_stats.population = _G.migrationcap.popcap - math.min(poproom, _G.migrationcap.migrationwavecap)
        _G.migrationcap.civpopreport_new=civ_stats.population

        if verbose then
            print('Home civ notified about current population and wave restriction. Civ thinks we have: ' .. civ_stats.population .. " of " .. _G.migrationcap.popcap)
        end
    end

end

if verbose then
    dfhack.run_command( "migrationcap -status")
end

--repeat -name migrationcaps -time 1 -timeUnits days -command [ migrationcap -targetpop 100 -wavecap 1 ]

