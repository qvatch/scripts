-- Get worshippers per deity
-- deity_list 1.0
-- Courtesy of PatrikLundell's (superior) original
-- http://www.bay12forums.com/smf/index.php?topic=169626.msg7706526#msg7706526
--  Attached as a comment at end of file.


--deity_list 2.0
--from fortunawhisk at http://www.bay12forums.com/smf/index.php?topic=173584.msg7958646#msg7958646

--deity_list 3.0
--Updated by Qvatch
--   -Fixed changes in dfhack's naming of unknown field
--   -Reformmated output to be easier to read
--   -Brought in some of the info from v1
--   -Renamed to 'faith.lua'. I before E except when you change the word to something easier.



--todo: get list of historical events for each god/faith/citizen

local utils = require('utils')

validArgs = utils.invert({
    'help',
    'citizens',
    'temples',
    'gods',
    'cults',
    --'bygod',
    --'bycitizen',
    --'unit',
    'verbose'
})

local args = utils.processArgs({ ... }, validArgs)
local verbose = false
local summary = false

local printcitizens = false
local printtemples = false
local printcults = false
local printgods = false

local helpme = [===[

faith.lua
=========
This script prints the deities and cults with a count of their worshippers, locations, and occupations in the fort.

arguments:
    -help
        print this help message


    -verbose
        prints debug data to the dfhack console. Default is false

    -gods
        print only a list of gods (civ and external), with spheres

    -citizens
        print only a list of citizens, with faith/occupations

    -temples
        print only a list of temple locations, with god/occupations

    -cults
        print only a list of cults (civ and external)

    -unit
        print information for the currently selected unit

    Examples:
        faith
            prints the comprehensive summary
        faith -citizens -temples
            prints information on each citizen, then each temple (Cult or God)

]===]

-- Handle help requests
if args.help then
    print(helpme)
    return
end

if (args.verbose) then
    verbose = true
end

if (args.summary) then
    summary = true
end

if (args.citizens) then
    printcitizens = true
end
if (args.temples) then
    printtemples = true
end
if (args.gods) then
    printgods = true
end
if (args.cults) then
    printcults = true
end

function translateStrength(beliefStrength)
    if (beliefStrength >= 90) then
        return "Ardent"
    elseif (beliefStrength >= 75) then
        return "Faithful"
    elseif (beliefStrength >= 25) then
        return "Normal"
    elseif (beliefStrength >= 10) then
        return "Casual"
    else
        return "Dubious"
    end
end

function printc(color, ...)
    --- dfhack print with color in one function.
    dfhack.color(color)
    dfhack.print(...)
    dfhack.color(COLOR_RESET)
end

function printlnc(color, ...)
    --- dfhack print with color in one function.
    dfhack.color(color)
    dfhack.println(...)
    dfhack.color(COLOR_RESET)
end

function show_deities2 ()


    local deities = {} --list of deities and religions {histfig_id, worshipper_count, worshpper_distribution{ardent, faithful, normal, casual, dubious}, {table of location sites}, type=["god", "cult"], homeciv=true}
    local entities = {} --same as deities, but for entities. index is entity_id; entities[7]=god's hf_id
    local citizens = {} --list of citizens {histfig_id, relation={entity_id/histfig_id, type=["worshipper","member", "priest", "performer"], relation_grade=[nil, "highpriest"]}

    local my_civ = df.global.world.world_data.active_site[0].entity_links[0].entity_id
    if verbose then
        dfhack.println("CivID= " .. my_civ)
    end

    for i, entity in ipairs(df.global.world.entities.all[my_civ].relations.deities) do
        -- Populate the deities table with worshipped deities from my civ
        deities[entity] = { entity, 0, { 0, 0, 0, 0, 0 }, {}, "god", true }
    end


    for i, entity in ipairs(df.global.world.entities.all[my_civ].entity_links) do
        -- Populate the entities table with cults from my civ
        -- Distrib is: ardent, faithful, normal, casual, dubious
        --[lua]# hack.TranslateName(df.global.world.entities.all[df.global.world.entities.all[224].entity_links[i].target].name,true)) end


        entity = df.global.world.entities.all[entity.target]
        if verbose then
            dfhack.println("C[" .. i .. "]: " .. dfhack.TranslateName(entity.name, true) .. " w:" .. entity.relations.worship[0] .. " r:" .. entity.entity_raw.religion[0])
        end

        entities[entity.id] = { entity.id, 0, { 0, 0, 0, 0, 0 }, {}, "cult", true }
    end


    for i, unit in ipairs(df.global.world.units.all) do
        -- Populate the citizens table with cults from my civ
        -- Add any newly referenced gods to the gods table (they'll be the foreign gods)
        if unit.civ_id == my_civ and dfhack.units.isCitizen(unit) then
            local hf = df.historical_figure.find(unit.hist_figure_id)
            citizens[hf.id] = { hf.id, {} }  --list of citizens {histfig_id, {relation={entity_id/histfig_id, type=["worshipper","member", "priest", "performer"], relation_grade=[nil, strength, title: "highpriest"]}}

            if verbose then
                printlnc(COLOR_WHITE, dfhack.TranslateName(df.historical_figure.find(unit.hist_figure_id).name, true) .. " (#" .. unit.hist_figure_id .. ")")
                --df.global.world.belief_systems.all[0].deities
            end

            for k, histfig_link in ipairs(hf.histfig_links) do
                if histfig_link._type == df.histfig_hf_link_deityst then
                    table.insert(citizens[hf.id][2], { histfig_link.target_hf, "worshipper", histfig_link.link_strength })
                    if verbose then
                        if histfig_link.link_strength < 25 then
                            dfhack.color(COLOR_DARKGREY)
                        end

                        dfhack.println("   - Worships " .. dfhack.TranslateName(df.historical_figure.find(histfig_link.target_hf).name, true) .. " | " .. translateStrength(histfig_link.link_strength) .. " (" .. histfig_link.link_strength .. ")")
                        dfhack.color(COLOR_RESET)
                    end
                    --check if religion is foreign(not in list) and needs to be added.
                    if not deities[histfig_link.target_hf] then
                        deities[histfig_link.target_hf] = { histfig_link.target_hf, 0, { 0, 0, 0, 0, 0 }, {}, "god", false }
                    end
                    deities[histfig_link.target_hf][2] = deities[histfig_link.target_hf][2] + 1

                    if (histfig_link.link_strength >= 90) then
                        deities[histfig_link.target_hf][3][1] = deities[histfig_link.target_hf][3][1] + 1
                    elseif (histfig_link.link_strength >= 75) then
                        deities[histfig_link.target_hf][3][2] = deities[histfig_link.target_hf][3][2] + 1
                    elseif (histfig_link.link_strength >= 25) then
                        deities[histfig_link.target_hf][3][3] = deities[histfig_link.target_hf][3][3] + 1
                    elseif (histfig_link.link_strength >= 10) then
                        deities[histfig_link.target_hf][3][4] = deities[histfig_link.target_hf][3][4] + 1
                    else
                        deities[histfig_link.target_hf][3][5] = deities[histfig_link.target_hf][3][5] + 1
                    end

                    for occidx, occ in ipairs(df.global.world.occupations.all) do
                        --Search for any occupations related to this deity
                        if occ.histfig_id == hf.id then
                            --printall(occ)
                            if verbose then
                                printlnc(COLOR_CYAN, "   - Occupation: " .. df.occupation_type[occ.type] .. " at " .. dfhack.TranslateName(df.global.world.world_data.active_site[0].buildings[occ.location_id].name) .. " '" .. dfhack.TranslateName(df.global.world.world_data.active_site[0].buildings[occ.location_id].name, true) .. "'")

                            end
                            table.insert(citizens[hf.id][2], { histfig_link.target_hf, df.occupation_type[occ.type], histfig_link.link_strength })
                        end
                    end
                end-- End deity test
            end -- End citizen relation loop








            for k, entity_link in ipairs(hf.entity_links) do
                -- print(k..": "..entity_link.entity_id)
                local entity = df.global.world.entities.all[entity_link.entity_id]
                --printall(entity)
                --[[                dfhack.print("C["..k.."][#"..entity_link.entity_id.."]: "..dfhack.TranslateName(entity.name,true))
                                if #entity.relations.worship>0 then
                                    dfhack.print(" w:"..entity.relations.worship[0] )
                                end
                                if #entity.entity_raw.religion>0 then
                                    dfhack.print(" r:"..entity.entity_raw.religion[0])
                                end]]

                if #entity.relations.worship > 0 and entity.relations.worship[0] > 0 then
                    --check if target entity is a religion
                    --print("    Religion")

                    if entity_link._type == df.histfig_entity_link_memberst then
                        table.insert(citizens[hf.id][2], { hf.id, entity_link.entity_id, "worshipper", entity_link.link_strength })

                    elseif entity_link._type == df.histfig_entity_link_positionst then
                        table.insert(citizens[hf.id][2], { hf.id, entity_link.entity_id, "position", entity_link.link_strength })
                    end
                    --check if religion is foreign(not in list) and needs to be added.
                    if not entities[entity_link.entity_id] then
                        entities[entity_link.entity_id] = { entity_link.entity_id, 0, { 0, 0, 0, 0, 0 }, {}, "cult", false, -1 }
                    end
                    entities[entity_link.entity_id][2] = entities[entity_link.entity_id][2] + 1
                    entities[entity_link.entity_id][7] = entity.relations.deities[0]

                    if (entity_link.link_strength >= 90) then
                        entities[entity_link.entity_id][3][1] = entities[entity_link.entity_id][3][1] + 1
                    elseif (entity_link.link_strength >= 75) then
                        entities[entity_link.entity_id][3][2] = entities[entity_link.entity_id][3][2] + 1
                    elseif (entity_link.link_strength >= 25) then
                        entities[entity_link.entity_id][3][3] = entities[entity_link.entity_id][3][3] + 1
                    elseif (entity_link.link_strength >= 10) then
                        entities[entity_link.entity_id][3][4] = entities[entity_link.entity_id][3][4] + 1
                    else
                        entities[entity_link.entity_id][3][5] = entities[entity_link.entity_id][3][5] + 1
                    end
                end
                if verbose then
                    printall(entities[entity_link.entity_id])
                end

            end

            if verbose then
                dfhack.println()
            end
        end -- End all my citizens test

    end -- End all units in the world loop

    -- printall(deities)




    local siteNames = { temples = { "Shrine", "Temple", "Temple Complex" } }

    local temples = {}
    local templeduplicates = {}--just a quick list of temples we've seen so we don't print duplicates.

    for i, building in ipairs(df.global.world.buildings.all) do
        if building._type == df.building_civzonest then
            if building.zone_flags.meeting_area and building.location_id ~= -1 and
                    df.global.world.world_data.active_site[0].buildings[building.location_id]._type == df.abstract_building_templest then
                local site = copyall(df.global.world.world_data.active_site[0].buildings[building.location_id])
                site.building_id = i


                --deity temples
                for k, deity in pairs(deities) do
                    if deity[1] == site.deity_data.Deity then
                        --todo: temple to no specific god
                        if not templeduplicates[building.location_id] then

                            --Temple locations
                            if verbose then
                                print("Temple: (#" .. i .. ") (to: " .. site.deity_data.Deity .. ") [allow:" .. (site.flags.AllowVisitors == true and "V" or "") .. (site.flags.AllowResidents == true and "R" or "") .. (site.flags.OnlyMembers == true and "M" or "") .. "], [tier: " .. site.contents.location_tier .. "], [value: " .. site.contents.location_value .. "], [name: " .. dfhack.TranslateName(site.name) .. " '" .. dfhack.TranslateName(site.name, true) .. "' ], ")
                                print("   - (pos: " .. building.centerx .. ", " .. building.centery .. ", " .. building.z .. ")")
                                print(building.location_id)
                                dfhack.println()
                            end
                        end
                        table.insert(deities[k][4], i)
                        table.insert(temples, copyall(site))
                        templeduplicates[building.location_id] = true

                        break --locations only get one deity, move on.
                    end
                end


                --Cult temples
                for k, entity in pairs(entities) do
                    --print(k.." "..entity[1])
                    --printall(site)
                    if entity[1] == site.deity_data.Deity then
                        --todo: temple to no specific god


                        if not templeduplicates[building.location_id] then

                            --Temple locations
                            if verbose then
                                print("Temple: (#" .. i .. ") (to: " .. site.deity_data.Deity .. ") [allow:" .. (site.flags.AllowVisitors == true and "V" or "") .. (site.flags.AllowResidents == true and "R" or "") .. (site.flags.OnlyMembers == true and "M" or "") .. "], [tier: " .. site.contents.location_tier .. "], [value: " .. site.contents.location_value .. "], [name: " .. dfhack.TranslateName(site.name) .. " '" .. dfhack.TranslateName(site.name, true) .. "' ], ")
                                print("   - (pos: " .. building.centerx .. ", " .. building.centery .. ", " .. building.z .. ")")
                                print(building.location_id)
                                --[[                            else
                                                                printc(COLOR_WHITE, ""..dfhack.TranslateName(site.name).." '"..dfhack.TranslateName(site.name,true).."'")
                                                                dfhack.println(" (#" .. i.. ")")

                                                                local hf=df.historical_figure.find(site.deity_data.Deity)
                                                                printc(COLOR_WHITE,"    - Dedicated to: "..dfhack.TranslateName(hf.name) .. " '" .. dfhack.TranslateName(hf.name, true) )

                                                                dfhack.println("    - Allows: "..(site.flags.AllowVisitors==true and "Visitors, " or "")..(site.flags.AllowResidents==true and "Residents " or "")..(site.flags.OnlyMembers==true and "Members only" or ""))
                                                                dfhack.println("    - ".. siteNames.temples[site.contents.location_tier+1].." (value: "..site.contents.location_value..string.char(15)..")")]]

                            end


                            --[[                            --Priests/Performers
                                                        for p = 0,#site.occupations-1 do
                                                            local hf=df.historical_figure.find(site.occupations[p].histfig_id)
                                                            -- print("  "..p)
                                                            if hf then
                                                                dfhack.println("    - "..df.occupation_type[site.occupations[p].type]..": "..dfhack.TranslateName(hf.name))
                                                            end
                                                        end]]
                            --[[                            dfhack.println()]]


                        end
                        table.insert(entities[k][4], i)
                        table.insert(temples, copyall(site))
                        templeduplicates[building.location_id] = true

                        break --locations only get one entity, move on.
                    end
                end

            end
        end
    end

    --todo: cults

    --[[    dfhack.println("")
        dfhack.print("check:")
        printall(deities[5][4])
        dfhack.print("---")
        printall(temples)]]

    if (not summary) or verbose then
        dfhack.println("")
        dfhack.println("")
    end

    if printcitizens then
        printlnc(COLOR_LIGHTRED, "-------------------------------------------------------")
        printlnc(COLOR_LIGHTCYAN, "              Citizens")
        printlnc(COLOR_LIGHTRED, "-------------------------------------------------------")

        for i, row in pairs(citizens) do
--[[            print("**************************")
            printall_recurse(row)
            print()]]
            printCitizen(row)
            --print()
           -- print()
        end

    end

    if printtemples then
        printlnc(COLOR_LIGHTRED, "-------------------------------------------------------")
        printlnc(COLOR_LIGHTCYAN, "              Temples")
        printlnc(COLOR_LIGHTRED, "-------------------------------------------------------")
        if verbose then
            dfhack.println("Locations appear once per designated meeting area.")
            dfhack.println()
        end

        for i, site in pairs(temples) do
            printTemple(site)
        end

    end

    if printgods then
        printlnc(COLOR_LIGHTRED, "-------------------------------------------------------")
        printlnc(COLOR_LIGHTCYAN, "              Deities")
        printlnc(COLOR_LIGHTRED, "-------------------------------------------------------")


        --todo: agreement_details_data_location
        --todo: sort by nworshippers
        --printall(deities)

        for i, row in pairs(deities) do
            if row[5] == "god" then
                printDeity(row)
                for j, erow in pairs(entities) do

                    if erow[5] == "cult" and erow[7] == i then
                        --print("*")
                        printCult(erow)
                    end
                end
            end

        end

    end

    --[[
        --if #df.global.world.entities.all[my_civ].relations.deities < #deities then
        dfhack.println("")
        dfhack.println("")
        printlnc(COLOR_WHITE,"Acquired deities:")

        for i,row in pairs(deities)  do
            if row[5]=="god" and row[6]==false then
                printDeity(row)
            end
        end
    ]]
    if printcults then
        for i, erow in pairs(entities) do
            --printall(erow)
            --print()
        end

        printlnc(COLOR_LIGHTRED, "-------------------------------------------------------")
        printlnc(COLOR_LIGHTCYAN, "              Cults")
        printlnc(COLOR_LIGHTRED, "-------------------------------------------------------")


        --todo: agreement_details_data_location
        --printall(deities)
        printlnc(COLOR_WHITE, "Civ cults:")
        for i, row in pairs(entities) do
            if row[5] == "cult" and row[6] then
                printCult(row)
            end

        end

        --if #df.global.world.entities.all[my_civ].relations.deities < #deities then
        dfhack.println("")
        dfhack.println("")
        printlnc(COLOR_WHITE, "Acquired cults:")

        for i, row in pairs(entities) do
            if row[5] == "cult" and row[6] == false then
                printCult(row)
            end
        end

    end
end

function printCitizen(row)
    local hf = df.historical_figure.find(row[1])

    printc(COLOR_WHITE, dfhack.TranslateName(hf.name))
    dfhack.print(" '" .. dfhack.TranslateName(hf.name, true) .. "' (#" .. row[1] .. ")")
    dfhack.println()

    printall_ipairs(row[2])
    if row[2] == {} then
        dfhack.println("\t- No faith")
        return
    end
    for i,histfig_link in pairs(row[2]) do
        histfig_link=histfig_link[1]
        dfhack.print("    - ")
        dfhack.println(histfig_link)
        dfhack.println("   - Worships " .. dfhack.TranslateName(df.historical_figure.find(histfig_link.target_hf).name, true) .. " | " .. translateStrength(histfig_link.link_strength) .. " (" .. histfig_link.link_strength .. ")")
        --printlnc(COLOR_CYAN,"   - Occupation: "..df.occupation_type[occ.type].." at "..dfhack.TranslateName(df.global.world.world_data.active_site[0].buildings[occ.location_id].name).." '"..dfhack.TranslateName(df.global.world.world_data.active_site[0].buildings[occ.location_id].name,true).."'")

    end
    print()
end

function printTemple(site)

    printc(COLOR_WHITE, "" .. dfhack.TranslateName(site.name) .. " '" .. dfhack.TranslateName(site.name, true) .. "'")
    dfhack.println(" (#" .. i .. ")")

    local hf = df.historical_figure.find(site.deity_data.Deity)
    printc(COLOR_WHITE, "    - Dedicated to: " .. dfhack.TranslateName(hf.name) .. " '" .. dfhack.TranslateName(hf.name, true))

    dfhack.println("    - Allows: " .. (site.flags.AllowVisitors == true and "Visitors, " or "") .. (site.flags.AllowResidents == true and "Residents " or "") .. (site.flags.OnlyMembers == true and "Members only" or ""))
    dfhack.println("    - " .. siteNames.temples[site.contents.location_tier + 1] .. " (value: " .. site.contents.location_value .. string.char(15) .. ")")

    --Priests/Performers
    for p = 0, #site.occupations - 1 do
        local hf = df.historical_figure.find(site.occupations[p].histfig_id)
        -- print("  "..p)
        if hf then
            dfhack.println("    - " .. df.occupation_type[site.occupations[p].type] .. ": " .. dfhack.TranslateName(hf.name))

        end
    end
end

function printCult(row)
    local distrib = "Ardent: " .. row[3][1] .. "; Faithful:" .. row[3][2] .. "; Normal:" .. row[3][3] .. "; Casual:" .. row[3][4] .. "; Dubious:" .. row[3][5]
    if not verbose and row[2] == 0 then
        return --don't print zero worshipper entries unless verbose
    end

    --[[    print("-")
        printall(row)
        print("--")]]
    local entity = df.global.world.entities.all[row[1]]
    local deity = df.historical_figure.find(row[7])

    dfhack.println("")
    --print(dfhack.TranslateName(entity.name))
    printc(COLOR_WHITE, "   * " .. dfhack.TranslateName(entity.name) .. " '" .. dfhack.TranslateName(entity.name, true))
    dfhack.print("' (#" .. row[1] .. ") " .. tostring(row[2]) .. " worshippers")

    dfhack.println("")
    --local god=df.historical_figure.find(entity.relations.deities[0])
    dfhack.println("         - Dedicated to " .. dfhack.TranslateName(deity.name) .. " '" .. dfhack.TranslateName(deity.name, true) .. "'")


    --dfhack.println("    - Founded by (RACE) (NAME) (DATE)" .. "")


    dfhack.println("         - " .. distrib)

    if #row[4] > 0 then
        --we only need to read the first location... for k,sitex in ipairs(row[4]) do
        --print("K:"..k.."/"..#row[4])
        local site = df.global.world.world_data.active_site[0].buildings[df.global.world.buildings.all[row[4][1]].location_id]--site=row[4][k]
        --[[               printall(site)
        -              printall(site.name)
                       print(dfhack.TranslateName(site.name))]]
        print("         - Temple: " .. dfhack.TranslateName(site.name) .. " '" .. dfhack.TranslateName(site.name, true) .. "' (#" .. table.concat(row[4], ", #") .. ") [allow: " .. (site.flags.AllowVisitors == true and "Vis" or "") .. (site.flags.AllowResidents == true and "Res" or "") .. (site.flags.OnlyMembers == true and "MbrsOnly" or "") .. "], [tier: " .. site.contents.location_tier .. "], [value: " .. site.contents.location_value .. "] [sites: " .. #row[4] .. "]")
        for p = 0, #site.occupations - 1 do
            local hf = df.historical_figure.find(site.occupations[p].histfig_id)
            -- print("  "..p)
            if hf then
                dfhack.println("           - " .. df.occupation_type[site.occupations[p].type] .. ": " .. dfhack.TranslateName(hf.name))

            end

        end

    end
end

function printDeity(row)
    local distrib = "Ardent: " .. row[3][1] .. "; Faithful:" .. row[3][2] .. "; Normal:" .. row[3][3] .. "; Casual:" .. row[3][4] .. "; Dubious:" .. row[3][5]

    --dfhack.println(tostring(row[2]) .. " total worshippers for " .. dfhack.TranslateName(df.historical_figure.find(row[1]).name, true) .. "(" .. row[1] .. ") - " .. distrib )
    if not verbose and row[2] == 0 then
        return --don't print zero worshipper entries unless verbose
    end

    local hf = df.historical_figure.find(row[1])

    dfhack.println("")
    printc(COLOR_WHITE, dfhack.TranslateName(hf.name) .. " '" .. dfhack.TranslateName(hf.name, true))
    dfhack.print("' (#" .. row[1] .. ") " .. tostring(row[2]) .. " worshippers")

    if hf.race ~= -1 then
        dfhack.println("")
        dfhack.print("    - Appears as a " .. (hf.sex == 1 and string.char(11) or string.char(12)) .. " " .. df.global.world.raws.creatures.all[hf.race].name[0] .. "")
    end

    dfhack.println("")
    dfhack.print("    - Spheres: ")
    for k, sphere in ipairs(hf.info.spheres.anon_1) do
        dfhack.print(df.sphere_type[sphere] .. ", ")
    end

    dfhack.println("")
    dfhack.println("    - " .. distrib)

    if #row[4] > 0 then
        --we only need to read the first location... for k,sitex in ipairs(row[4]) do
        --print("K:"..k.."/"..#row[4])
        local site = df.global.world.world_data.active_site[0].buildings[df.global.world.buildings.all[row[4][1]].location_id]--site=row[4][k]
        --[[               printall(site)
        -              printall(site.name)
                       print(dfhack.TranslateName(site.name))]]
        print("    - Temple: " .. dfhack.TranslateName(site.name) .. " '" .. dfhack.TranslateName(site.name, true) .. "' (#" .. table.concat(row[4], ", #") .. ") [allow:" .. (site.flags.AllowVisitors == true and "Vis" or ".") .. (site.flags.AllowResidents == true and "Res" or ".") .. (site.flags.OnlyMembers == true and "Mbr" or ".") .. "], [tier: " .. site.contents.location_tier .. "], [value: " .. site.contents.location_value .. "] [sites: " .. #row[4] .. "]")
        for p = 0, #site.occupations - 1 do
            local hf = df.historical_figure.find(site.occupations[p].histfig_id)
            -- print("  "..p)
            if hf then
                dfhack.println("      - " .. df.occupation_type[site.occupations[p].type] .. ": " .. dfhack.TranslateName(hf.name))

            end

        end

    end


end

show_deities2()
------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------
function show_deities ()
    local deities = {}

    local my_civ = df.global.world.world_data.active_site[0].entity_links[0].entity_id

    for i, entity in ipairs(df.global.world.entities.all[my_civ].relations.deities) do
        table.insert(deities, { entity, 0, false })
    end

    for i, unit in ipairs(df.global.world.units.all) do
        if unit.civ_id == my_civ and
                not unit.flags2.visitor and
                unit.training_level == df.animal_training_level.WildUntamed then

            local hf = df.historical_figure.find(unit.hist_figure_id)

            if hf and #hf.histfig_links > 0 then
                for k, histfig_link in ipairs(hf.histfig_links) do
                    if histfig_link._type == df.histfig_hf_link_deityst then
                        local found = false

                        for l, entry in pairs(deities) do
                            if histfig_link.target_hf == entry[1] then
                                entry[2] = entry[2] + 1
                                found = true
                                break
                            end
                        end

                        if not found then
                            table.insert(deities, { histfig_link.target_hf, 1 })
                        end
                    end
                end
            end

        end
    end

    local temples = {}
    for i, building in ipairs(df.global.world.buildings.all) do
        if building._type == df.building_civzonest then
            if building.zone_flags.meeting_area and building.location_id ~= -1 and
                    df.global.world.world_data.active_site[0].buildings[building.location_id]._type == df.abstract_building_templest then

                for k, deity in pairs(deities) do
                    deities[k][3] = {}
                    if deity[1] == df.global.world.world_data.active_site[0].buildings[building.location_id].deity_data.Deity then
                        if verbose then
                            print("Temple: " .. i)

                        end
                        deities[k][3][#deities[k][3] + 1] = i --add buildingID to list of temples for this god.
                        break
                    end
                end
            end
        end
    end

    dfhack.println("Civ deities:")

    for i = 1, #df.global.world.entities.all[my_civ].relations.deities do
        if deities[i][3] then
            dfhack.color(COLOR_LIGHTGREEN)
        else
            dfhack.color(COLOR_YELLOW)
        end

        local hf = df.historical_figure.find(deities[i][1])
        dfhack.print(tostring(deities[i][2]) .. " worshipers for " .. dfhack.TranslateName(hf.name, true) .. " '" .. dfhack.TranslateName(hf.name) .. "'")

        if hf.race ~= -1 then
            dfhack.print("  [" .. df.global.world.raws.creatures.all[hf.race].name[0] .. "]: ")
        end

        dfhack.print(". Spheres: ")
        for k, sphere in ipairs(hf.info.spheres.anon_1) do
            dfhack.print(", " .. df.sphere_type[sphere])
        end

        dfhack.println()

        dfhack.color(COLOR_RESET)
    end

    if #df.global.world.entities.all[my_civ].relations.deities < #deities then
        dfhack.println("Acquired deities:")

        for i = #df.global.world.entities.all[my_civ].relations.deities + 1, #deities do
            if deities[i][3] then
                dfhack.color(COLOR_LIGHTGREEN)
            else
                dfhack.color(COLOR_YELLOW)
            end

            local hf = df.historical_figure.find(deities[i][1])

            dfhack.print(tostring(deities[i][2]) .. " worshipers for " .. dfhack.TranslateName(hf.name, true))

            if hf.race ~= -1 then
                dfhack.print(" : " .. df.global.world.raws.creatures.all[hf.race].name[0])
            end

            if hf.info.spheres.anon_1 then
                for k, sphere in ipairs(hf.info.spheres.anon_1) do
                    dfhack.print(", " .. df.sphere_type[sphere])
                end
            end

            dfhack.println()

            dfhack.color(COLOR_RESET)
        end
    end
end

print("-------------------------------------------------------")
print("-------------------------------------------------------")
--show_deities()









---------------------------------------------------------------------------------------
--histfig_entity_link
--  -histfig_entity_link_memberst
--  -histfig_hf_link_deityst
--  -histfig_entity_link_occupationst
--  -histfig_entity_link
--[[            [lua]# @df.histfig_entity_link_type
        <type: histfig_entity_link_type>
        0                        = MEMBER
        1                        = FORMER_MEMBER
        2                        = MERCENARY
        3                        = FORMER_MERCENARY
        4                        = SLAVE
        5                        = FORMER_SLAVE
        6                        = PRISONER
        7                        = FORMER_PRISONER
        8                        = ENEMY
        9                        = CRIMINAL
        10                       = POSITION
        11                       = FORMER_POSITION
        12                       = POSITION_CLAIM
        13                       = SQUAD
        14                       = FORMER_SQUAD
        15                       = OCCUPATION
        16                       = FORMER_OCCUPATION

[lua]# @df.histfig_hf_link_type
<type: histfig_hf_link_type>
0                        = MOTHER
1                        = FATHER
2                        = SPOUSE
3                        = CHILD
4                        = DEITY
5                        = LOVER
6                        = PRISONER
7                        = IMPRISONER
8                        = MASTER
9                        = APPRENTICE
10                       = COMPANION
11                       = FORMER_MASTER
12                       = FORMER_APPRENTICE
13                       = PET_OWNER
14                       = FORMER_SPOUSE
15                       = DECEASED_SPOUSE


]]

--[[
 hf = df.historical_figure.find(81700)
 1                        = <histfig_entity_link_memberst: 000002D3F9D89AD0>
 [lua]# ~hf.entity_links[0]
        entity_id                = 517
        link_strength            = 93
    [lua]# @df.histfig_entity_link_type
    <type: histfig_entity_link_type>
    0                        = MEMBER
is a member of ~hf.entity_links[1].entity_id

~df.global.world.entities.all[363].
    entity_links ->founding civ
    relations
        ~df.global.world.entities.all[363].relations.worship[0] is not nil -->religion
    entity_raw
        ~df.global.world.entities.all[363].entity_raw.religion[0] is not nil --> a religion
    entity.relations.deities
        histfig referenced is a god --> a religion?
    entity.events[x].type==
             <type: history_event_type> 27                       = ENTITY_CREATED
            <type: entity_event_type> 12                       = founding
    <type: entity_entity_link_type>2                        = RELIGIOUS
  ]]

--[[

hf=df.historical_figure.find(81699)
entity_link=hf.entity_links[1]
entity=df.global.world.entities.all[363]
function t(n) print(dfhack.TranslateName(n)..": "..dfhack.TranslateName(n,true) )end

]]
--[[            for k, entity_link in ipairs(hf.entity_links) do
                local entity=df.global.world.entities.all[entity_link.entity_id]
                if entity_link._type == df.histfig_entity_link_memberst or df.histfig_entity_link_positionst then
                    --printall(entity)
                    dfhack.print("C["..k.."][#"..entity_link.entity_id.."]: "..dfhack.TranslateName(entity.name,true))
                    if #entity.relations.worship>0 then
                        dfhack.print(" w:"..entity.relations.worship[0] )
                    end
                    if #entity.entity_raw.religion>0 then
                        dfhack.print(" r:"..entity.entity_raw.religion[0])
                    end
                    print()

                end

            end]]


--[[                 1792
                building_id              = 214
                site_id                  = 2292
                inhabitants              = <vector<abstract_building.T_inhabitants*>[0]: 000002D3E92C4220>
            parent_building_id       = -1
            contents                 = <abstract_building_contents: 000002D3E92C4348>
            id                       = 2
            site_owner_id            = 4978
            name                     = <language_name: 000002D3E92C42D0>
            deity_data               = <temple_deity_data: 000002D3E92C42CC>
            deity_type               = -1
            flags                    = <BitArray<>: 000002D3E92C4238>
            occupations              = <vector<occupation*>[1]: 000002D3E92C42B0>
            unk2                     = <vector<int32_t>[0]: 000002D3E92C4250>
            pos                      = <coord2d: 000002D3E92C42AC>
            child_building_ids       = <vector<int32_t>[0]: 000002D3E92C4270>]]