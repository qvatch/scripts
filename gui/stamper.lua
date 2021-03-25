--designating tool
--v1: Original stamper: copy/paste/transform designations
--v2: grow/shrink and some digshape integration
--v3: ~2019-06-21 Cellular automata, mouse
--v4 [2020-09-27]:bloated with new features by Qvatch.
--    -place constructions
--         -simplistic material choice
--         -variably map designations -> constructions
--    -set brush can optionally also read already dug/placed stuff
--    -erase can now choose between designations/built constructions/placed const. jobs
--v4.1 [2020-10-08]: Added some meta-commands to construction:pasteAs, removed display of cursor on brush if not blinking (brush is a cursor)
--v4.1.1 [2020-10-09]: bugfix.
--v4.1.2 [2020-10-15]: Fixed resuming by adding pcall and a resume function. add unbuilt constructions to select menu.
--todo: materials: brick

--[====[

gui/stamper
===========
allows manipulation of designations by transforms such as translations, reflections, rotations, and inversion.
designations can also be used as brushes to erase other designations and cancel constructions.

designations can be pasted as construction orders, with mutable mapping between dig designation and construction type. Material can be set. Constructions and designated constructions can be erased.

brushes can be saved/loaded to a file (currently only one at a time)

]====]


--[[
--------------------------------------------------------
            Example constructions workflow:
--------------------------------------------------------
Illustrated: <insert web address when hosted, until then, stamper.zip>

====  I want to build an above ground elliptical tower.  ====

==Workflow 1: simple

=Preparation
*Make sure your build site is clear of constructions, trees, and other junk that would interfere with normal construction placement.
*Make sure you have enough of the material you want to build with (eg. quartizite blocks). If you don't they'll just cancel the construction with a message and you'll have to re-stamp (or fill in with the normal way).
*This example assumes stamper is in it's default state (designation mode, no existing selection).

=In regular dig designation mode:
1. On some random underground patch, designate an ellipse[or whatever] of <h> channel designation to be the exterior walls.  [*digshape makes this easy]
2. Fill the shape with <d> dig designation to be the interior floors. [*with digshape, just use the flood command]
3. Place some stairways <i>

=Switch to stamper, (designation mode)
In the dfhack console (not the Ctrl-Shift-P prompt, it just makes a black screen) enter: gui/stamper

1. Draw the select box around your designations. (If you've already got a selection made, use <s> to begin a new selection.
    1a. Move the cursor to one corner of the designation, press enter to mark
    1b. Move cursor to the opposite corner, press enter to make the selection
2. Move the view up to where you want to build the tower.  You should see your design in cyan moving with your cursor.
3. Switch stamper to constructions mode <f>
4. Change your material if desired
  4a. Change material, <SHIFT+F>. A popup appears, type in the material name (all caps). To find the material name, consult the wiki for the material, view the raw, and it's the name at the top like [INORGANIC:NATIVE_COPPER] -> NATIVE_COPPER (for the ore), or [PLANT:OAK] -> OAK, or [INORGANIC:COPPER] -> COPPER (for the metal)
  4b. Change the item type <SHIFT+B>. A popup appears, type in the item type you want (a list of valid entries is shown).
  NOTE: no error checking or consistency checking will be done (eg making vertical bars with limestone boulders), the placement will just silently fail. I assume you know what the thing you're trying to build needs. No harm should occur, worst case the construction designation will appear, but a dwarf will cancel it with no material available.
5. Press enter to stamp the constructions into the world. If the stamp is very large a small delay will occur as the jobs are generated. This seems to be less than the equivalent box-designate constructions. No progress indicatior will appear.

6. Exit stamper and designations menu, unpause, let the dwarves build. (you may need to unpause constructions if the dwarves interfere with each other, as normal)
7. Move up a z level, go back into stamper, align and place the next level of your tower.
  7a. You can press <b> to blink the stamp to make alignment easier, if it helps.
  NOTE: your dwarves may strand themselves by walking out along the wall and cutting off their retreat, then they'll cancel the builds adjacent. This is why the fancy features of stamper exist, and I'll demonstrate in workflow 2.
8. goto 6, repeat as desired.


==Workflow 2: Advanced options
This will be the same as workflow 1, but we'll add a little extra in to make the construction nicer.

We'll do a 5 level tower all at once, but you can skip multiple floors if you want.

=In regular dig designation mode:
Do regular designations 1..3 as per workflow 1.
NOTE: A great way to make walls in a shape is to make the shape of the whole thing as a solid designation of channel, select it as a stamp, shrink it once, convert it to dig, paste it.
4. For the outside wall corners, that when built above ground will be unreachable if built in the wrong order, pick one wall tile <h> that is orthogonal to a floor tile <d> to be our 'scaffolding' stage. We'll build this as floor first, then remove it, then build it as wall. Designate these as ramp <r>. A good choice are inside corners, but there's plenty of flexibility.
  WARNING: make sure there won't be any segments that are unsupported if all the <r> tiles are removed at the same time.
  NOTE: of course, if everything is nicely lined up on the layer below, the walls below will provide sufficient walkable places.
  NOTE: A doorway is left as an exercise to the reader. Perhaps using DownStair?

=Switch to stamper, (designation mode)
Do stamper steps 1..4 as workflow 1.
Press <f> to switch to construction mode, and move to an open spot on the surface.
Make sure you've cleared trees out first.

5. For the ground level, we can get to all the outside corner walls (r's in our pattern), so we'll place them as walls. Press <c> to open the paste as.. submenu.
  5a. press <r> to cycle what designated ramps will be pasted as until it turns up as floor.
  5b. lets change the updown stair to an upstair for the ground floor. Press <i> until it cycles to UpStair.
  5c. we'll build the floors in the first pass so dwarves can't strand themselves. Press <h> to cycle the walls to Skip/Ignore. This is more important on the higher floors.
  5d. Press <ESC> to return to the main stamper menu.
  NOTE: changing what things "paste as" does not modify the actual stamp. You can return stamper to designations mode to see it unchanged. Switching between designations and constructions, or making a new selection will not cause it to forget, though reloading the game will.

6. Press <ENTER> to stamp floor one of the tower into the world.
    NOTE: you could let the dwarves build this floor first, but it's not required. We can designate in open space using dfhack.
7. Move up a z level, open the paste as submenu <c>
  7a. Since we're no longer on the first floor, reset our updown stairs, press <SHIFT+I> (you could also just press <i> until it gets back to updown.
8. Press <ENTER> to stamp the brush.
  8a. move up a z level, and press <ENTER> again
  8b. do this for a few floors (make sure you have enough of the material you are using)
  NOTE: if you're having trouble aligning the brush on higher levels, press <ESC> to exit the paste as menu, then press <b> to blink the brush, and go back into the paste as menu <c>

9. Press <ESC> until you are back at the main DF menu, unpause and let them build.
    NOTE: they'll build on many levels at once rather than one at a time, but they can't get stuck because there are no walls being built yet.


11. Lets go back and place the walls we ignored. Open stamper and move the brush to the first floor.
  11a. Press <c> to open the "Paste as" submenu.
  11a. Press <SHIFT+H> to reset channel designations to paste as walls
  11b. Press <ESC> to exit this submenu
  NOTE: Constructions won't be placed where constructions already exist, so we can just let the ramps/floors get stamped
12. Stamp it <ENTER>, move up in z, stamp <ENTER>, etc. Unpause, let the dwarves build.

13. Now let's fix those 'scaffolding' floors. Open stamper.
  13a. Let's set the ramps to be deconstruct.  Press <c> to open the "Paste as" submenu.
  13b. Cycle ramps (<r> several times) to be Deconstruct.
  13c. Press <ESC> to exit this submenu
14. Stamp it <ENTER>, unpause, let the dwarves deconstruct.

15. Finalize the walls. Open stamper. Press (c) to open the "Paste as" submenu.
  15a. Cycle ramps (<r> several times) to be Walls.
  15b. Press <ESC> to exit this submenu
  15c. Cancel/deconstruct at least one wall on the ground floor as a door, or it's a sealed tower.
16. Stamp it <ENTER> and repeat on the above levels, unpause, let the dwarves build.

17. Let's build a quick path up to our tower. Open stamper
  17a. press <s> to start a new selection. We'll copy a 2x2 section of floor.
  17b. press <c> to select existing constructions
  17c. move to a spot of floor, press <ENTER> to mark, and move down and over to select a 2x2 section <ENTER>

18. Enable mouse input, <m> and dragging <n>
  NOTE: Lerping is interpolation as the mouse moves, but it's too slow to be useful most of the time.
  18a. click and drag (slowly) to paint constructions. Fancy.
  18b. Unpause and let them build.

19. Finished.

Ok, I hope you can see how this saves time when you have a lot of floors to do (you can do each stage for all floors at the same time), or a lot of funny corners to fix.



==== TROUBLESHOOTING ====

1. Only part of a design got placed as construction jobs!
  -You probably didn't have enough of the chosen material. It will just stop placing when it runs out.
  -You can just repeat the stamp when you have acquired more of that material, or change the material.

2. Things collapsed when I was building!
  -Either you placed constructions where they would have no support (like building walls off the middle of a bridge), or you removed support. Maybe you placed constructions in trees (don't do that).

3. I called gui/stamper but the df window just went black
  -You can't call stamper from the Ctrl-Shift-P in game command prompt, use the dfhack console window.
  -Try pressing enter in the console, worst case if the stamper menu is shown but you can't exit: devel/pop-screen.

]]

--[[
NOTE: DFhack scripts to help dev:

devel/pop-screen: exit an active gui script
devel/clear-script-env SCRIPTNAME
:lua _G.stamper_saved_options=nil   : clears stamper's special save
devel/click-monitor start|stop : prints coordinates of mouse clicks to console
]]


--todo:xor
--todo:copy air as designation (copy already dug areas)
--todo: save buffer(s) to persistant (see stockpiles.lua?)
--todo: tracks.
--todo: filter create brush by things like construction type, material
--todo: for constructions, process the buffer multiple times to put in all stairs/floors/ramps so they are built first. (how is first decided?)
--todo: *PLACING* status bar while constructions are getting stamped, as it takes longer than is comfortable, and there's no notice when it finishes.  (like quicksave does)
--todo: Save/load needs a filename popup and a job-complete notice.
--todo: matrix transformations
--todo: paste with digshape nfold symmetry
--todo: arbitrary rotation (buffer---rotate-->pastebuffer so that each rotation does not corrupt the orig, overwrite buffer each 90deg)




--BUG [cant repro]: ***CRASH TO DESKTOP*** (vrare) reopening stamper after a quicksave? maybe only done with ctrl-shift-p? associated with moving up a z level?
--bug: if dwarf gets stranded, will cancel touching jobs with "no block" rather than suspend.
--bug: cannot erase a deconstruct order (d-n job) when it is in progress, but d-x works fine.


local utils = require "utils"
local gui = require "gui"
local guidm = require "gui.dwarfmode"
local dlg = require "gui.dialogs"
--local script=require "gui.scripts"
local widgets = require 'gui.widgets'
local enabler = df.global.enabler
local json = require "json"
--local buildings = "gui.create-item"
require('dfhack.buildings') --for buildings.constructBuilding()

local noise_rng = dfhack.random.new()

StamperUI = defclass(StamperUI, guidm.MenuOverlay)

StamperUI.ATTRS {
    state = "none", --{"none", "brush": applying the brush [main menu], "mark": select the brush,  "convert": map the values in the brush, "transform": rotate, invert, grow, etc the brush, "create": programmatic brush invention
    option = "normal", --{"normal": brush makes things, "erase": brush deletes things, "mark1": when state="mark", option="mark1" when we have marked one.
    --todo: nowerasing=false, --brush erases or places?
    mode = "dig", -- {"dig": default; "construction": place constructions; "designate[TODO]": normal d menu stuff like smooth, remove, etc.}
    erasemode = { 2, "all", "existing", "designated" }, -- for deleting constructions, do we delete existing constructions, or only designated?
    selectmode = { designations = true, empty = false, constructions = false, constructionWallsAsChannels = true, constructionsPlaced = false }, --what kind of things does the set-brush function capture? ie, what can we copy?

    buffer = nil, --a 2d array of df:tile, the designation buffer is taken from the buffer[x][y].dig attribute
    savedbuffers = nil, --we can save a set of buffers. Each is given a name. TODO: enable more than 0..9  (see buildings.lua for proc. menu assembly)
    offsetDirection = 0,
    mark = {}, --the first selection marker (copy of df.global.cursor)
    cull = true, --cull makes the brush select shrink to the minimum bounding rectangle of the selected objects.
    blink = false, --should the brush blink?
    blinkrate = { 4, 750, 350, 125 }, --how fast do we blink. blinkrate[1] is the index of the chosen rate.

    --Mouse variables
    mouse = false,
    dragging = false,
    lastMouse = xyz2pos(0, 0, 0),
    lerp = true, --lerp is laggy because it repeatedly inefficiently accesses memory; it would be faster if we cached some but thats above my paygrade ;)
    customOffset = { x = 0, y = 0 },

    --Designation mode variables
    designateMarking = false, --are we designating "marking" rather than standard?

    --Construction mode variables
    constructionmaterial = { mat_type = 0, mat_index = 180, mat_name = "QUARTZITE", item_type = df.item_type.BLOCKS, item_name = "BLOCKS" }, --if we're not copying material from the world, this is what we designate constructions with.
    constructMapping = { 1, 2, 3, 4, 5, 6 }, --{y...y}: digSymbol[x] -> constructSymbol[y]; For translating digsymbols into constructsymbols, and allowing remapping of said.
}

local digSymbols = { " ", "X", "_", 30, ">", "<" } --in the order of @df.tile_dig_designation
local constructSymbols = { "+", "X", "O", 30, ">", "<", 206, "T", 240, 019, "R", 176 } -- types of constructions {floor, udstair, wall, ramp, downstair,upstair, fortification(ascii 206)} These are directly (as much as possible) analagous to the digSymbols, so we can translate a dig to a build. "n": designate-remove/construction-cancel
local constructNames = { "Floor", "UpDownStair", "Wall", "Ramp", "DownStair", "UpStair", "Fortification", "Track(TODO)", "BarsFloor", "BarsVertical", "Deconstruct", "Skip/Ignore" } --TODO: Suspend (suspend construction)
local constructENUM = { df.construction_type.Floor, df.construction_type.UpDownStair, df.construction_type.Wall, df.construction_type.Ramp, df.construction_type.DownStair, df.construction_type.UpStair, df.construction_type.Fortification, -30000, df.building_type.BarsFloor, df.building_type.BarsVertical, -30000, -30000 } --https://peridexiserrant.neocities.org/docs-structures-test/docs/_auto/structures/buildings.html @ buildings.construction_type

--[[
local selectmapping = {
    tiletype = { WALL = { 4 }, FLOOR = { 1, 0, 2, 3, 10, 11, 12, 13, 14, 15, 16, 17, 18 }, UPSTAIR = { 6 }, DOWNSTAIR = { 7 }, UPDOWNSTAIR = { 8 }, RAMP = { 9 } }, --Which df.tiletype_shape do we map to designations?
    constructiontype = { WALL = { 1 }, FLOOR = { 2, 7 }, UPSTAIR = { 3 }, DOWNSTAIR = { 4 }, UPDOWNSTAIR = { 5 }, RAMP = { 6 } }, --map constructionat() to designations
    tilematerial = { SOLID = { 1, 2, 5, 6, 7 }, HOLLOW = { 0, 8, 9, 10, 11, 12, 14, 15, 17, 19, 20, 21, 22, 23, 24 }, UNKNOWN = { 3, 4, 13, 18, 25 } } --map df.tiletype.material to designations
}
]]



function constructions_findAt(x, y, z)
    --more or less a copy of the cpp version: https://github.com/DFHack/dfhack/blob/develop/library/modules/Constructions.cpp
    --[[    df::construction * Constructions::findAtTile(df::coord pos)
                {
                for (auto it = world->constructions.begin(); it != world->constructions.end(); ++it) {
                    if ((*it)->pos == pos)
                    return *it;
                    }
                return NULL;
                }]]
    local bld
    for idx = 0, #df.global.world.constructions - 1 do
        bld = df.global.world.constructions[idx]
        if bld.pos.x == x and bld.pos.y == y and bld.pos.z == z then
            --print("find construction at [" .. x .. "," .. y .. "," .. z .. "] index: ", idx)
            return bld
        end
    end
end

--function constructions_findAt2(x,y,z)
--
--    print("find construction2 at ["..x..","..y..","..z.."]")
--    local bld
--    for idx =0,#df.global.world.buildings.all-1 do
--        bld=df.global.world.buildings.all[idx]
--        if df.building_constructionst:is_instance(bld) then
--
--            if bld.x1==x and bld.y1==y and bld.z==z then--if bld.centerx==x and bld.centery==y and bld.z==z then
--                print("find construction2 at ["..x..","..y..","..z.."] index: ",idx)
--                return bld
--            end
--        end
--    end
--    --print("find construction failed.")
--end

function StamperUI:init()
    self.saved_mode = df.global.ui.main.mode
    local status, attr = pcall(self.resume)

    if status then
        for k, v in pairs(attr) do
            self[k] = v
        end
    else
        print("stamper..2020-10-14..v4.1.2 prerelease")
        self.state = "mark"
    end

    df.global.ui.main.mode = df.ui_sidebar_mode.LookAround
    df.global.cursor.z = df.global.window_z
    self.blinkcursor = true
end

function StamperUI:resume()
    local attr = {}
    attr.buffer = _G.stamper_saved_options.buffer
    attr.constructionmaterial = _G.stamper_saved_options.constructionmaterial
    attr.constructMapping = _G.stamper_saved_options.constructMapping
    attr.mode = _G.stamper_saved_options.mode
    attr.blinkrate = _G.stamper_saved_options.blinkrate
    attr.selectmode = _G.stamper_saved_options.selectmode
    attr.erasemode = _G.stamper_saved_options.erasemode
    attr.state = _G.stamper_saved_options.state
    return attr
end

function StamperUI:onDestroy()
    _G.stamper_saved_options = { buffer = self.buffer, constructionmaterial = self.constructionmaterial, constructMapping = self.constructMapping, mode = self.mode, blinkrate = self.blinkrate, selectmode = self.selectmode, erasemode = self.erasemode, state = self.state }
    df.global.ui.main.mode = self.saved_mode
end

local function paintMapTile(dc, vp, cursor, pos, ...)
    if not same_xyz(cursor, pos) then
        local stile = vp:tileToScreen(pos)
        if stile.z == 0 then
            dc:map(true):seek(stile.x, stile.y):char(...):map(false)
        end
    end
end

local function minToMax(...)
    local args = { ... }
    table.sort(args, function(a, b)
        return a < b
    end)
    return table.unpack(args)
end

local function getMousePos()
    local posx, posy, posz = -30000, 0, 0
    local mx, my = dfhack.screen.getMousePos()
    local vx, vy, vz = df.global.window_x, df.global.window_y, df.global.window_z

    posx = vx + mx - 1;
    posy = vy + my - 1;
    posz = vz -- - dfhack.gui.getDepthAt(mx,my)
    return xyz2pos(posx, posy, posz)
end

function StamperUI:getCursor()
    if self.mouse then
        return getMousePos()
    else
        return df.global.cursor
    end
end

local function cullBuffer(data)
    --there's probably a memory saving way of doing this
    local lowerX = math.huge
    local lowerY = math.huge
    local upperX = -math.huge
    local upperY = -math.huge
    for x = 0, data.xlen do
        for y = 0, data.ylen do
            if data[x][y].dig > 0 then
                lowerX = math.min(x, lowerX)
                lowerY = math.min(y, lowerY)
                upperX = math.max(x, upperX)
                upperY = math.max(y, upperY)
            end
        end
    end
    if lowerX == math.huge then
        lowerX = 0
    end
    if lowerY == math.huge then
        lowerY = 0
    end
    if upperX == -math.huge then
        upperX = data.xlen
    end
    if upperY == -math.huge then
        upperY = data.ylen
    end
    local buffer = {}
    for x = lowerX, upperX do
        buffer[x - lowerX] = {}
        for y = lowerY, upperY do
            buffer[x - lowerX][y - lowerY] = data[x][y] --reduce data[][].dig to just buffer[][]
        end
    end
    buffer.xlen = upperX - lowerX
    buffer.ylen = upperY - lowerY
    return buffer
end

local function padBuffer(data, n)
    --there's probably a memory saving way of doing this
    local n = n or 1
    local buffer = {}
    for x = 0, data.xlen + (2 * n) do
        buffer[x] = {}
        for y = 0, data.ylen + (2 * n) do
            if y > (n - 1) and x > (n - 1) and y < data.ylen + (n * 2) and x < data.xlen + (n * 2) then
                buffer[x][y] = data[x - n][y - n]
            else
                buffer[x][y] = 0 --{dig=0}
            end
        end
    end
    buffer.xlen = data.xlen + (2 * n)
    buffer.ylen = data.ylen + (2 * n)
    return buffer
end

local function getTiles(p1, p2, cull, selectmode)
    if selectmode == nil then
        --print("gettiles with nil selectmode.")
        --TODO: is this the best thing to do here? figure where the nils are passed from and consider passing something better there.
        selectmode = { designations = true, empty = false, constructions = false, constructionWallsAsChannels = true }
    end
    if cull == nil then
        cull = true
    end
    local x1, x2 = minToMax(p1.x, p2.x)
    local y1, y2 = minToMax(p1.y, p2.y)
    local xlen = x2 - x1
    local ylen = y2 - y1
    assert(p1.z == p2.z, "only tiles from the same Z-level can be copied")
    local z = p1.z
    local data = {}

    for k, block in ipairs(df.global.world.map.map_blocks) do
        if block.map_pos.z == z then
            for block_x, row in ipairs(block.designation) do
                local x = block_x + block.map_pos.x
                if x >= x1 and x <= x2 then
                    if not data[x - x1] then
                        data[x - x1] = {}
                    end
                    for block_y, tile in ipairs(row) do
                        local y = block_y + block.map_pos.y
                        if y >= y1 and y <= y2 then
                            data[x - x1][y - y1] = copyall(tile)
                            data[x - x1][y - y1].occ = copyall(block.occupancy[block_x][block_y])
                            local tiletype = df.tiletype.attrs[block.tiletype[block_x][block_y]]
                            local mat = tiletype.material
                            --print("tt:"..data[x-x1][y-y1].dig..","..tiletype.shape.."," ..mat)
                            --print("block: "..k.."bx: "..block_x.."by: "..block_y)
                            local selected = false --only process select checkings until we get a result, skip the rest.
                            if selectmode.designations then
                                --data[x-x1][y-y1].dig is the current dig designation, we can just copy it straight.
                                if data[x - x1][y - y1].dig == 1 then
                                    selected = true
                                    if tiletype.shape == df.tiletype_shape.FLOOR or mat == df.tiletype_material.AIR then
                                        --clear dig designation on invalid tiles
                                        data[x - x1][y - y1].dig = 0
                                    end
                                end
                            else
                                data[x - x1][y - y1].dig = 0
                            end

                            if selectmode.empty then
                                if (tiletype.shape == df.tiletype_shape.WALL or tiletype.shape == df.tiletype_shape.FORTIFICATION) and not selected then
                                    -- designate fortifications as walls. TODO: figure the way of designating 'carve fortifications'.
                                    data[x - x1][y - y1].dig = df.tile_dig_designation.No
                                elseif tiletype.shape == df.tiletype_shape.STAIR_DOWN then
                                    data[x - x1][y - y1].dig = df.tile_dig_designation.DownStair

                                elseif tiletype.shape == df.tiletype_shape.STAIR_UP then
                                    data[x - x1][y - y1].dig = df.tile_dig_designation.UpStair

                                elseif tiletype.shape == df.tiletype_shape.STAIR_UPDOWN then
                                    data[x - x1][y - y1].dig = df.tile_dig_designation.UpDownStair

                                elseif tiletype.shape == df.tiletype_shape.RAMP_TOP then
                                    data[x - x1][y - y1].dig = df.tile_dig_designation.Channel

                                elseif tiletype.shape == df.tiletype_shape.RAMP then
                                    data[x - x1][y - y1].dig = df.tile_dig_designation.Ramp

                                else
                                    data[x - x1][y - y1].dig = df.tile_dig_designation.Default
                                end
                            end
                            if selectmode.constructions then
                                --currently should get existing and planned constructions. Use the building flag "exists" to differentiate
                                if not selected then
                                    if selectmode.constructionsPlaced then
                                        local building = dfhack.buildings.findAtTile(x, y, z)
                                        selected = true

                                        if building and building.construction_stage then
                                            if (building.type == df.construction_type.Wall or building.type == df.construction_type.Fortification) then
                                                -- designate fortifications as walls. todo: figure the way of designating 'carve fortifications'.
                                                if selectmode.constructionWallsAsChannels then
                                                    data[x - x1][y - y1].dig = df.tile_dig_designation.Channel
                                                else
                                                    data[x - x1][y - y1].dig = df.tile_dig_designation.No
                                                end

                                            elseif building.type == df.construction_type.Stair_down then
                                                data[x - x1][y - y1].dig = df.tile_dig_designation.Downstair
                                            elseif building.type == df.construction_type.Stair_up then
                                                data[x - x1][y - y1].dig = df.tile_dig_designation.Upstair
                                            elseif building.type == df.construction_type.Stair_updown then
                                                data[x - x1][y - y1].dig = df.tile_dig_designation.Updownstair
                                            elseif building.type == df.construction_type.Ramp then
                                                data[x - x1][y - y1].dig = df.tile_dig_designation.Ramp
                                            elseif building.type == df.construction_type.Ramp_top then
                                                data[x - x1][y - y1].dig = df.tile_dig_designation.Channel
                                            elseif building.type == df.construction_type.Floor then
                                                data[x - x1][y - y1].dig = df.tile_dig_designation.Default
                                            end

                                        end
                                    elseif mat == df.tiletype_material.CONSTRUCTION then
                                        data[x - x1][y - y1].dig = 1

                                        selected = true
                                        if (tiletype.shape == df.tiletype_shape.WALL or tiletype.shape == df.tiletype_shape.FORTIFICATION) then
                                            -- designate fortifications as walls. TODO: figure the way of designating 'carve fortifications'.

                                            if selectmode.constructionWallsAsChannels then
                                                data[x - x1][y - y1].dig = df.tile_dig_designation.Channel
                                            else
                                                data[x - x1][y - y1].dig = df.tile_dig_designation.No
                                            end

                                        elseif tiletype.shape == df.tiletype_shape.STAIR_DOWN then
                                            data[x - x1][y - y1].dig = df.tile_dig_designation.DownStair
                                        elseif tiletype.shape == df.tiletype_shape.STAIR_UP then
                                            data[x - x1][y - y1].dig = df.tile_dig_designation.UpStair
                                        elseif tiletype.shape == df.tiletype_shape.STAIR_UPDOWN then
                                            data[x - x1][y - y1].dig = df.tile_dig_designation.UpDownStair
                                        elseif tiletype.shape == df.tiletype_shape.RAMP then
                                            data[x - x1][y - y1].dig = df.tile_dig_designation.Ramp
                                        elseif tiletype.shape == df.tiletype_shape.RAMP_TOP then
                                            data[x - x1][y - y1].dig = df.tile_dig_designation.Channel
                                        elseif tiletype.shape == df.tiletype_shape.FLOOR then
                                            data[x - x1][y - y1].dig = df.tile_dig_designation.Default
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    data.xlen = xlen
    data.ylen = ylen
    if cull then
        return cullBuffer(data)
    end
    return data
end

function StamperUI:getOffset()
    if self.offsetDirection == 0 then
        --southeast
        return 0, 0
    elseif self.offsetDirection == 1 then
        --northeast
        return 0, -self.buffer.ylen
    elseif self.offsetDirection == 2 then
        --northwest
        return -self.buffer.xlen, -self.buffer.ylen
    elseif self.offsetDirection == 3 then
        --southwest
        return -self.buffer.xlen, 0
    elseif self.offsetDirection == 4 then
        --center
        return -math.floor(self.buffer.xlen / 2 + .5), math.floor(-self.buffer.ylen / 2 + .5)
    elseif self.offsetDirection == 5 then
        --custom
        return self.customOffset.x, self.customOffset.y
    else
        error("out of range")
    end
end

function StamperUI:setBuffer(tiles)
    --self.buffer=tiles
    --print(json.encode(tiles))
    self.buffer = {}

    local buffer = {}
    for x = 0, tiles.xlen do
        if not buffer[x] then
            buffer[x] = {}
        end
        for y = 0, tiles.ylen do
            buffer[x][y] = tiles[x][y].dig --getting tile
        end
    end
    self.buffer = buffer
    self.buffer.xlen = tiles.xlen
    self.buffer.ylen = tiles.ylen
    --print(json.encode(self.buffer))
end

function StamperUI:transformBuffer(callback)
    local newBuffer = {}
    local xlen = 0
    local ylen = 0
    for x = 0, self.buffer.xlen do
        for y = 0, self.buffer.ylen do
            --local tile = self.buffer[x][y]--copyall(self.buffer[x][y]);
            local x2, y2, tile = callback(x, y, self.buffer.xlen, self.buffer.ylen, self.buffer[x][y])
            --print("%d %d %d",x,y,tile)
            xlen = math.max(x2, xlen)
            ylen = math.max(y2, ylen)
            if not newBuffer[x2] then
                newBuffer[x2] = {}
            end
            if not newBuffer[x2][y2] then
                newBuffer[x2][y2] = tile --self.buffer[x][y]
            end
        end
    end
    newBuffer.xlen = xlen
    newBuffer.ylen = ylen
    return newBuffer
end

function StamperUI:lerpInput(key, start, stop)
    start = copyall(start)
    local dx = math.abs(stop.x - start.x)
    local dy = math.abs(stop.y - start.y)

    local sx = start.x < stop.x and 1 or -1
    local sy = start.y < stop.y and 1 or -1

    local err = math.floor((dx > dy and dx or -dy) / 2)
    local err2
    local list = nil
    while true do
        list = self:pasteBuffer({ x = start.x, y = start.y, z = df.global.window_z }, list)
        if (start.x == stop.x and start.y == stop.y) then
            break
        end
        err2 = err
        if err2 > -dx then
            err = err - dy
            start.x = start.x + sx
        end
        if err2 < dy then
            err = err + dx
            start.y = start.y + sy
        end
    end
end

function StamperUI:pasteBuffer(position, blockList)
    local z = position.z
    local offsetX, offsetY = self:getOffset()
    if self.option == 'verbatim' then
        offsetX = 0
        offsetY = 0
    end
    local x1 = position.x + offsetX
    local x2 = position.x + self.buffer.xlen + offsetX
    local y1 = position.y + offsetY
    local y2 = position.y + self.buffer.ylen + offsetY
    local newList = blockList or {} --cached list of  blocks for bresenham (not sure if this helps but oh well)
    for k, block in ipairs(blocklist or df.global.world.map.map_blocks) do
        if block.map_pos.z == z then
            if not blockList then
                table.insert(newList, block)
            end
            for block_x, row in ipairs(block.designation) do
                local x = block_x + block.map_pos.x
                if x >= x1 and x <= x2 then
                    for block_y, tile in ipairs(row) do
                        local y = block_y + block.map_pos.y
                        if y >= y1 and y <= y2 and (self.buffer[x - x1] and self.buffer[x - x1][y - y1] and (self.buffer[x - x1][y - y1] > 0 or self.option == 'verbatim')) then
                            local tiletype = df.tiletype.attrs[block.tiletype[block_x][block_y]]
                            local mat = tiletype.material
                            local buildtype = df.building_type.Construction
                            local buildsubtype_idx = self.constructMapping[self.buffer[x - x1][y - y1]] --Translate with "paste as" conversions
                            local buildsubtype = constructENUM[buildsubtype_idx]

                            if buildsubtype == df.building_type.BarsVertical or buildsubtype == df.building_type.BarsFloor then
                                buildtype = buildsubtype
                                buildsubtype = -1
                            end

                            if constructNames[buildsubtype_idx] == "Skip/Ignore" and self.mode == "construction" then
                                --continue
                            elseif self.option == "erase" or (self.option == "normal" and constructNames[buildsubtype_idx] == "Deconstruct") then
                                if self.mode == "construction" then
                                    local buildinghere = dfhack.buildings.findAtTile(x, y, z)

                                    if buildinghere == nil then
                                        --we are possibly on an existing construction, or no construction at all.
                                        --TODO: should we remove vertical/floor bars here? if so that needs dfhack.buildings, rather than .constructions..
                                        if (self.erasemode[self.erasemode[1]] == "all" or self.erasemode[self.erasemode[1]] == "existing") then
                                            dfhack.constructions.designateRemove(x, y, z)
                                        end
                                    elseif (self.erasemode[self.erasemode[1]] == "all" or self.erasemode[self.erasemode[1]] == "designated") then
                                        --we are on a designated construction, or no construction.
                                        dfhack.constructions.designateRemove(x, y, z)
                                    end


                                else
                                    tile.dig = 0 --setting tile
                                end
                            elseif self.mode == "dig" then
                                if not (self.buffer[x - x1][y - y1] == 1 and tiletype.shape == df.tiletype_shape.FLOOR or mat == df.tiletype_material.AIR) then
                                    --working on designations, don't designate air, don't designate dig on floor.
                                    tile.dig = self.buffer[x - x1][y - y1] --setting tile
                                    block.occupancy[block_x][block_y].dig_marked = self.designateMarking
                                    block.dsgn_check_cooldown = 0;
                                    block.flags.designated = true;
                                end
                            else

                                --Check if site already has a building (and if so, if it is only the wall below providing a 'floor')
                                local consthere = constructions_findAt(x, y, z)
                                local legalplacement = true
                                if consthere then
                                    --there is a construction here
                                    if consthere.flags.top_of_wall then
                                        --ok
                                        legalplacement = true
                                        --elseif constructNames[buildsubtype_idx]=="Deconstruct" then
                                        --    legalplacement=true
                                    else
                                        --not ok
                                        legalplacement = false
                                    end
                                elseif buildhere then
                                    --not ok
                                    legalplacement = false
                                end
                                if legalplacement then
                                    --Sort out materials for the build
                                    local mats = dfhack.matinfo.find(self.constructionmaterial.mat_name .. (self.constructionmaterial.item_name == "WOOD" and ":WOOD" or ""))
                                    --print(tostring(mats))
                                    --local buildmatfilter=dfhack.buildings.input_filter_defaults
                                    if self.constructionmaterial.item_name == "BLOCKS" then
                                        self.constructionmaterial.item_type = df.item_type.BLOCKS
                                    elseif self.constructionmaterial.item_name == "BOULDERS" then
                                        self.constructionmaterial.item_type = df.item_type.BOULDER
                                    elseif self.constructionmaterial.item_name == "BARS" then
                                        self.constructionmaterial.item_type = df.item_type.BAR
                                    elseif self.constructionmaterial.item_name == "WOOD" then
                                        self.constructionmaterial.item_type = df.item_type.WOOD
                                    end
                                    --print("item_type="..self.constructionmaterial.item_type..", mat_type="..mats.type..", mat_index="..mats.index)

                                    --Build the construction!
                                    --local buildreturn=dfhack.constructions.designateNew(xyz2pos(x,y,z),buildtype,df.item_type.BLOCKS,dfhack.matinfo.find("QUARTZITE").index) --Old way of doing this, has some bugs (details at end of file)
                                    local buildreturn = dfhack.buildings.constructBuilding({ pos = xyz2pos(x, y, z), type = buildtype, subtype = buildsubtype, filters = { { item_type = self.constructionmaterial.item_type, mat_type = mats.type, mat_index = mats.index } } }) --see also list-filters.lua

                                    --if buildreturn==0 then
                                    --    --some error occurred, fish for diagnostic info..
                                    --    print("constructions.designatenew returned: "..tostring(buildreturn)..",  xyz["..x..", "..y..", "..z.."] ")
                                    --end


                                    --future idea: dfhack.buildings.hasSupport(pos,size) to ensure support..? Useful for removing in stages.

                                    --df.building_type.Construction, df.building_subtype.WALL
                                    --BAR, BLOCKS, BOULDER, WOOD

                                    --dfhack.constructions.designateNew(pos,type,item_type,mat_index)
                                    --Designates a new construction at given position. If there already is a planned but not completed construction there, changes its type. Returns true, or false if obstructed. Note that designated constructions are technically buildings.
                                    --DFHACK_EXPORT bool designateNew(df::coord pos, df::construction_type type,df::item_type item = df::item_type::NONE, int mat_index = -1);

                                    --from https://github.com/DFHack/dfhack/blob/develop/library/modules/Constructions.cpp and https://github.com/DFHack/dfhack/blob/develop/library/modules/Buildings.cpp:
                                    --bool Constructions::designateNew(df::coord pos, df::construction_type type, df::item_type item, int mat_index)
                                    --    new df::job_item();
                                    --       filter->item_type = item;
                                    --       filter->mat_index = mat_index;
                                    --newinst = Buildings::allocInstance(pos, building_type::Construction);
                                    --auto newcons = strict_virtual_cast<df::building_constructionst>(newinst);
                                    --    newcons->type = type;

                                    --Instead try dfhack.buildings.constructBuilding  (see: https://docs.dfhack.org/en/stable/docs/Lua%20API.html#high-level)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return newList
end

function StamperUI:invertBuffer()
    --this modifies the buffer instead of copying it
    self.buffer = self:transformBuffer(function(x, y, xlen, ylen, tile)
        if tile > 0 then
            tile = 0
        else
            tile = 1
        end
        return x, y, tile
    end)
end

function StamperUI:renderOverlay()
    local vp = self:getViewport()
    local dc = gui.Painter.new(self.df_layout.map)
    local visible = gui.blink_visible(500)


    --blink_visible(delay)::: Returns true or false, with the value switching to the opposite every delay msec. This is intended for rendering blinking interface objects.

    if self.option == "mark1" and gui.blink_visible(120) then
        paintMapTile(dc, vp, nil, self.mark, "+", COLOR_LIGHTGREEN)
        --TODO: perhaps draw a rectangle to the point
    elseif (gui.blink_visible(self.blinkrate[self.blinkrate[1]]) or not self.blink) and self.buffer ~= nil and (self.state ~= "mark" or (self.state == "mark" and self.option == "create")) then
        local fg = COLOR_BLACK
        local bg = COLOR_LIGHTCYAN

        local offsetX, offsetY = self:getOffset()
        for x = 0, self.buffer.xlen do
            for y = 0, self.buffer.ylen do
                local tile = self.buffer[x][y]

                if self.option == "erase" then
                    fg = COLOR_BLACK
                    if self.mode == "construction" then
                        bg = COLOR_YELLOW
                    else
                        bg = COLOR_RED
                    end
                else
                    if self.mode == "construction" then
                        bg = COLOR_GREEN
                    else
                        bg = COLOR_LIGHTCYAN
                    end
                end

                if tile > 0 then
                    local symbol = digSymbols[tile]
                    if self.mode == "construction" then
                        symbol = constructSymbols[self.constructMapping[tile]]
                    end
                    if self.option ~= "normal" then
                        symbol = " "
                    end

                    if self.mode == "construction" and self.option == "erase" and constructNames[self.constructMapping[tile]] == "Skip/Ignore" then
                        symbol = constructSymbols[12]
                    end

                    if self.mode == "construction" and self.option == "normal" and constructNames[self.constructMapping[tile]] == "Deconstruct" then
                        symbol = " "
                        bg = COLOR_YELLOW
                    end
                    if not (gui.blink_visible(self.blinkrate[self.blinkrate[1]]) and x == -offsetX and y == -offsetY) then
                        paintMapTile(dc, vp, nil, xyz2pos((self:getCursor()).x + x + offsetX, (self:getCursor()).y + y + offsetY, (self:getCursor()).z), symbol, fg, bg)
                    end
                    if (x == -offsetX and y == -offsetY) then
                        --draw the tile under the cursor (lazy overpaint)
                        paintMapTile(dc, vp, nil, xyz2pos((self:getCursor()).x + x + offsetX, (self:getCursor()).y + y + offsetY, (self:getCursor()).z), symbol, fg, bg)
                    end
                else
                    if self.state == "mark" and self.option == "create" then
                        --this is lazy overdrawing
                        local symbol = "+"
                        paintMapTile(dc, vp, nil, xyz2pos((self:getCursor()).x + x + offsetX, (self:getCursor()).y + y + offsetY, (self:getCursor()).z), symbol, fg, bg)
                    end
                end
            end
        end
    end
end

function StamperUI:onRenderBody(dc)
    if df.global.cursor.x == -30000 then
        --and not self.hello then
        local vp = self:getViewport()
        df.global.cursor = xyz2pos(math.floor((vp.x1 + math.abs((vp.x2 - vp.x1)) / 2) + .5), math.floor((vp.y1 + math.abs((vp.y2 - vp.y1) / 2)) + .5), df.global.window_z)
        return
    end
    --self.hello = true --a flag to indicate the first run, so we can print the version# to console
    self:renderOverlay()

    dc:clear():seek(1, 1):pen(COLOR_WHITE):string("stamper - " .. self.state:gsub("^%a", function(x)
        return x:upper()
    end) .. " - " .. self.mode)
    dc:seek(1, 3)

    if self.state == "brush" then
        dc:key_string("CUSTOM_S", "Set Brush (Copy)", COLOR_GREY):newline(1)

        if self.busy == true then
            -- and gui.blink_visible(300) then
            dc:key_string("SELECT", "** WORKING **", COLOR_LIGHTRED):newline(1)
            --todo: make this work :)  We must draw it before calling pastebuffer, and update it in there.
        else
            dc:key_string("SELECT", "Place Brush (Paste)", COLOR_WHITE):newline(1)
        end
        dc:newline(1)

        dc:key_string("CUSTOM_F", "Working on " .. (self.mode == "construction" and "Constructions" or "Designations"), self.mode == "construction" and COLOR_LIGHTGREEN or COLOR_YELLOW):newline(1):newline(1)

        dc:key_string("CUSTOM_H", "Flip Horizontal", COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_V", "Flip Vertical", COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_R", "Rotate 90", COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_T", "Rotate -90", COLOR_GREY):newline(1)
        dc:key_string("SECONDSCROLL_DOWN", "Grow", COLOR_GREY):newline(1)
        dc:key_string("SECONDSCROLL_UP", "Shrink", COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_I", "Invert", COLOR_GREY):newline(1)

        dc:newline(1)
        dc:key_string("CUSTOM_C", (self.mode == "construction" and "Paste As..." or "Convert to..."), COLOR_GREY):newline(1)
        dc:newline(1)

        local erasestring = "Erasing "
        if self.mode == "construction" then
            erasestring = erasestring .. self.erasemode[self.erasemode[1]] .. " constructions"
        end
        dc:key_string("CUSTOM_X", (self.option == "erase" and erasestring or "Erase"), self.option == "erase" and COLOR_LIGHTRED or COLOR_GREY):newline(1)
        if self.mode == "construction" and self.option == "erase" then
            dc:key_string("CUSTOM_SHIFT_X", "Change erase type", COLOR_GREY):newline(1)
        else
            dc:newline(1)
        end

        if self.mode == "construction" then

            dc:key_string("CUSTOM_SHIFT_F", "Set material: " .. self.constructionmaterial.mat_name, COLOR_GREY):newline(1)
            dc:key_string("CUSTOM_SHIFT_B", "Set type: " .. self.constructionmaterial.item_name, COLOR_GREY):newline(1)
        end

        if self.mode == "dig" then
            --undo and flood are designation mode only, not implemented in construction mode.
            dc:key_string("CUSTOM_P", "Flood (Digshape)", COLOR_GREY):newline(1)
            if (self.option == "normal" or self.option == "erase" or self.undobuffer == "digshape") then
                dc:key_string("CUSTOM_Z", "Undo" .. (self.undobuffer == "digshape" and " Digshape" or ""), self.undobuffer ~= nil and COLOR_WHITE or COLOR_GREY):newline(1)
            end
            --dc:newline(1)
        end

        dc:newline(1)
        dc:key_string("CUSTOM_B", "Blink Brush", self.blink and COLOR_WHITE or COLOR_GREY):newline(1)
        if self.blink then
            dc:key_string("CUSTOM_ALT_B", "Blink Speed: " .. self.blinkrate[self.blinkrate[1]], self.blink and COLOR_WHITE or COLOR_GREY):newline(1)
        end
        dc:key_string("CUSTOM_M", (self.mouse and "Disable" or "Enable") .. " Mouse", self.mouse and COLOR_WHITE or COLOR_GREY):newline(1)
        if self.mouse then
            dc:key_string("CUSTOM_N", (self.dragging and "Disable" or "Enable") .. " Mouse Dragging", self.dragging and COLOR_WHITE or COLOR_GREY):newline(1)
        else
            dc:newline(1)
        end
        if self.mouse and self.dragging then
            dc:key_string("CUSTOM_L", (self.lerp and "Disable" or "Enable") .. " Drag Lerp", self.lerp and COLOR_WHITE or COLOR_GREY):newline(1)
        else
            dc:newline(1)
        end

        dc:key_string("STRING_A091", "Cell Bridge Remove", COLOR_GREY):newline(1)
        dc:key_string("STRING_A092", "Cell Passages", COLOR_GREY):newline(1)
        dc:key_string("STRING_A093", "Cell Rooms", COLOR_GREY):newline(1)
        dc:newline(1)

        if self.mode == "dig" then
            dc:key_string("CUSTOM_SHIFT_M", "Designating: " .. (self.designateMarking and "Marking" or "Standard"), self.designateMarking and COLOR_CYAN or COLOR_GREY):newline(1)
        end

        dc:key_string("CUSTOM_G", "Cycle Corner", COLOR_GREY):newline(1):newline(1)
        dc:key_string("CUSTOM_SHIFT_S", "Save Brush", COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_SHIFT_L", "Load Brush", COLOR_GREY)


    elseif self.state == "mark" then
        if self.buffer == nil then
            dc:string("Select two corners.")
        end
        dc:newline():newline(1)
        --selection options
        dc:key_string("CUSTOM_D", (self.selectmode.designations and "" or "Not ") .. "Selecting Designations", self.selectmode.designations and COLOR_WHITE or COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_C", (self.selectmode.constructions and "" or "Not ") .. "Selecting Constructions", self.selectmode.constructions and COLOR_WHITE or COLOR_GREY)
        if self.selectmode.constructions then
            dc:newline(3):key_string("CUSTOM_ALT_C", "Walls: " .. (self.selectmode.constructionWallsAsChannels and "as channels" or "No designation"), self.selectmode.constructions and COLOR_WHITE or COLOR_GREY)
            dc:newline(3):key_string("CUSTOM_U", (self.selectmode.constructions and "" or "Not ") .. "Selecting Unbuilt Constructions", self.selectmode.constructions and COLOR_WHITE or COLOR_GREY):newline(1)
        else
            dc:newline(1)
        end
        dc:key_string("CUSTOM_E", (self.selectmode.empty and "" or "Not ") .. "Selecting Exisiting", self.selectmode.empty and COLOR_WHITE or COLOR_GREY):newline(1)

        if not (self.selectmode.designations or self.selectmode.constructions or self.selectmode.empty) then
            dc:newline(1):string("!! NO SELECTIONS SET !!", COLOR_BLACK, (gui.blink_visible(250) and COLOR_LIGHTRED or COLOR_RED))
            dc:newline(1):string("Enable at least one, ", COLOR_GREY)
            dc:newline(1):string(" or nothing can be marked.", COLOR_GREY):newline(1):newline(1)
        end

        dc:key_string("CUSTOM_M", (self.mouse and "Disable" or "Enable") .. " Mouse", self.mouse and COLOR_WHITE or COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_P", "Cull Selections", self.cull and COLOR_WHITE or COLOR_GREY)
        dc:newline(2)
        --if self.savedbuffers~=nil then
        --		for i in 0,savedbuffers.maxn,1 do
        --			dc:key_string(string.format("CUSTOM_%i",i), "Load buffer: xxxxx",COLOR_WHITE):newline(1)
        --		end
        --end
    elseif self.state == "convert" and self.mode == "dig" then
        dc:string("Convert whole brush to...", COLOR_WHITE):newline():newline(1)
        dc:key_string("CUSTOM_D", "Mine", COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_H", "Channel", COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_U", "Up Stair", COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_J", "Down Stair", COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_I", "U/D Stair", COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_R", "Up Ramp", COLOR_GREY):newline(1):newline(1)
        --dc:key_string("CUSTOM_F", "Swap construct wall/fort [now "..(self.digwallforh and "WALL" or "FORTI").."]",COLOR_RED):newline(4)
        dc:key_string("CUSTOM_N", "Random Noise", COLOR_RED):newline(4)

        dc:string("for cellular automata", COLOR_GREY):newline(1);
        dc:newline(1)
        dc:string("To undesignate use the erase mode", COLOR_WHITE)


    elseif self.state == "convert" and self.mode == "construction" then
        dc:string("Brush will paste with...", COLOR_WHITE):newline():newline(1)
        dc:key_string("CUSTOM_D", "Mine -> " .. constructNames[self.constructMapping[1]], COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_H", "Channel -> " .. constructNames[self.constructMapping[3]], COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_U", "Up Stair -> " .. constructNames[self.constructMapping[6]], COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_J", "Down Stair -> " .. constructNames[self.constructMapping[5]], COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_I", "U/D Stair -> " .. constructNames[self.constructMapping[2]], COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_R", "Up Ramp -> " .. constructNames[self.constructMapping[4]], COLOR_GREY):newline(1):newline(1)

        dc:key_string("CUSTOM_X", "Reset Convert to default", COLOR_RED):newline(1):newline(1)

        dc:string("These will not change the", COLOR_GREY):newline(2)
        dc:string("designations brush, only", COLOR_GREY):newline(2)
        dc:string("constructions paste.", COLOR_GREY):newline(1)

        dc:newline(1):string("Brush will not change", COLOR_GREY)
        dc:newline(2):string("exisiting placements", COLOR_GREY)

        dc:newline():newline(1):string("Shift+", COLOR_LIGHTGREEN):color(COLOR_LIGHTGREEN, true, COLOR_LIGHTGREEN):char(000):color(COLOR_LIGHTGREEN, true, COLOR_BLACK):string(": Reset KEY to default", COLOR_GREY)
        dc:newline(1):string("Alt+", COLOR_LIGHTGREEN):color(COLOR_LIGHTGREEN, true, COLOR_LIGHTGREEN):char(000):color(COLOR_LIGHTGREEN, true, COLOR_BLACK):string(": Set KEY to Floor", COLOR_GREY)
        dc:newline(1):string("Ctrl+", COLOR_LIGHTGREEN):color(COLOR_LIGHTGREEN, true, COLOR_LIGHTGREEN):char(000):color(COLOR_LIGHTGREEN, true, COLOR_BLACK):string(": Set KEY to Wall", COLOR_GREY)
        dc:newline():newline(1):key_string("CUSTOM_SHIFT_S", "Set ALL to Skip/Ignore", COLOR_GREY)
        dc:newline(1):key_string("CUSTOM_SHIFT_F", "Set ALL to Floor", COLOR_GREY)
        dc:newline(1):key_string("CUSTOM_SHIFT_W", "Set ALL to Wall", COLOR_GREY)

        dc:newline():newline():key_string("SELECT", "Place Brush (Paste)", COLOR_WHITE):newline(1)
    end

    dc:newline():newline():key_string("LEAVESCREEN", "Back")
end

function StamperUI:onIdle()
    if self.mouse and self.dragging then
        local pos = getMousePos()
        if enabler.mouse_lbut_down == 1 then
            if self.lastMouse.x ~= pos.x or self.lastMouse.y ~= pos.y or self.lastMouse.z ~= pos.z then
                if self.lerp and (math.abs(self.lastMouse.x - pos.x) > 1 or math.abs(self.lastMouse.y - pos.y) > 1 or math.abs(self.lastMouse.z - pos.z) > 1) then
                    self:lerpInput({ _MOUSE_L_DOWN = true, _MOUSE_L = true }, pos, self.lastMouse)
                else
                    self:onInput({ _MOUSE_L_DOWN = true, _MOUSE_L = true }, true)
                end
            end
        end
        self.lastMouse = pos
    end
end

function invpXY(x, y)
    return x >= df.global.window_x and x <= df.global.window_x + df.global.gps.clipx[1]
            and y >= df.global.window_y and y <= df.global.window_y + df.global.gps.clipy[1]
end

function StamperUI:onInput(keys, drag, tempcursor)
    invpXY(df.global.cursor.x, df.global.cursor.y)
    if df.global.cursor.x == -30000 then
        local vp = self:getViewport()
        df.global.cursor = xyz2pos(math.floor((vp.x1 + math.abs((vp.x2 - vp.x1)) / 2) + .5), math.floor((vp.y1 + math.abs((vp.y2 - vp.y1) / 2)) + .5), df.global.window_z)
        return
    end

    if self.state == "brush" then
        if keys.CUSTOM_S then
            self.state = "mark"
        elseif keys.CUSTOM_SHIFT_S then
            local file = io.open("stamperPattern.txt", "w")
            io.output(file)
            io.write(self.buffer.xlen, "\n")
            io.write(self.buffer.ylen, "\n")
            for x = 0, self.buffer.xlen do
                for y = 0, self.buffer.ylen do
                    io.write(self.buffer[x][y], " ")
                end
                io.write("\n")
            end
            io.close(file)
            print("Saved gui/stamper buffer to <<StamperPattern.txt>> in the main df folder")

        elseif keys.CUSTOM_SHIFT_L then
            local file = io.open("stamperPattern.txt", "r")
            io.input(file)
            self.buffer = {}
            self.buffer.xlen = io.read("n")
            self.buffer.ylen = io.read("n")
            for x = 0, self.buffer.xlen do
                if not self.buffer[x] then
                    self.buffer[x] = {}
                end
                for y = 0, self.buffer.ylen do
                    self.buffer[x][y] = io.read("n")
                end
                io.read(1)
            end
            io.close(file)
            print("Restored gui/stamper buffer from <<stamperPattern.txt>> in the main df folder")

        elseif (keys.SECONDSCROLL_DOWN or keys._STRING == 61 or keys._STRING == 43) and self.buffer then
            -- + or =
            local offsetX, offsetY = self:getOffset()
            self.buffer = padBuffer(self.buffer, 1)
            local newbuffer = {}
            for x = 0, self.buffer.xlen do
                newbuffer[x] = {}
                for y = 0, self.buffer.ylen do
                    newbuffer[x][y] = self.buffer[x][y] --copyall(self.buffer[x][y])
                    if newbuffer[x][y] == 0 then
                        --.dig==0 then
                        for ix = x - 1, x + 1 do
                            for iy = y - 1, y + 1 do
                                if ix >= 0 and ix <= self.buffer.xlen and iy >= 0 and iy <= self.buffer.ylen and self.buffer[ix][iy] > 0 then

                                    newbuffer[x][y] = self.buffer[ix][iy]
                                    break
                                end
                            end
                        end
                    end
                end
            end
            newbuffer.xlen = self.buffer.xlen
            newbuffer.ylen = self.buffer.ylen
            local offCenterX = (math.floor(self.buffer.xlen / 2 + .5)) - offsetX
            offCenterX = offCenterX + (offCenterX == 0 and 0 or (offCenterX / math.abs(offCenterX)))
            offsetX = (math.floor(self.buffer.xlen / 2 + .5)) - offCenterX

            local offCenterY = (math.floor(self.buffer.ylen / 2 + .5)) - offsetY
            offCenterY = offCenterY + (offCenterY == 0 and 0 or (offCenterY / math.abs(offCenterY)))
            offsetY = (math.floor(self.buffer.ylen / 2 + .5)) - offCenterY

            self.customOffset = { x = offsetX, y = offsetY }
            self.offsetDirection = 5
            self.buffer = newbuffer
        elseif (keys.SECONDSCROLL_UP or keys._STRING == 95 or keys._STRING == 45) and self.buffer then
            -- - or _
            local offsetX, offsetY = self:getOffset()
            --self.buffer=padBuffer(self.buffer,0)
            local newbuffer = {}
            for x = 1, self.buffer.xlen - 1 do
                newbuffer[x - 1] = {}
                for y = 1, self.buffer.ylen - 1 do
                    newbuffer[x - 1][y - 1] = self.buffer[x][y] --copyall(self.buffer[x][y])
                    if newbuffer[x - 1][y - 1] ~= 0 then
                        for ix = x - 1, x + 1 do
                            for iy = y - 1, y + 1 do
                                if self.buffer[ix][iy] == 0 then
                                    newbuffer[x - 1][y - 1] = 0
                                    break
                                end
                            end
                        end
                    end
                    if y == 0 or x == 0 or y == self.buffer.ylen or x == self.buffer.xlen then
                        newbuffer[x - 1][y - 1] = 0
                    end
                end
            end
            newbuffer.xlen = self.buffer.xlen - 2
            newbuffer.ylen = self.buffer.ylen - 2
            local offCenterX = (math.floor(self.buffer.xlen / 2 + .5)) - offsetX
            offCenterX = offCenterX - (offCenterX == 0 and 0 or (offCenterX / math.abs(offCenterX)))
            offsetX = (math.floor(self.buffer.xlen / 2 + .5)) - offCenterX

            local offCenterY = (math.floor(self.buffer.ylen / 2 + .5)) - offsetY
            offCenterY = offCenterY - (offCenterY == 0 and 0 or (offCenterY / math.abs(offCenterY)))
            offsetY = (math.floor(self.buffer.ylen / 2 + .5)) - offCenterY

            self.customOffset = { x = offsetX, y = offsetY }
            self.offsetDirection = 5
            self.buffer = newbuffer

        elseif keys.CUSTOM_H then
            self.buffer = self:transformBuffer(function(x, y, xlen, ylen, tile)
                return xlen - x, y, tile
            end)
        elseif keys.CUSTOM_V then
            self.buffer = self:transformBuffer(function(x, y, xlen, ylen, tile)
                return x, ylen - y, tile
            end)
        elseif keys.CUSTOM_R then
            self.buffer = self:transformBuffer(function(x, y, xlen, ylen, tile)
                return y, xlen - x, tile
            end)
            self.offsetDirection = (self.offsetDirection + 1) % 4
        elseif keys.CUSTOM_T then
            self.buffer = self:transformBuffer(function(x, y, xlen, ylen, tile)
                return ylen - y, x, tile
            end)
            self.offsetDirection = (self.offsetDirection - 1) % 4
        elseif keys.CUSTOM_G then
            self.offsetDirection = (self.offsetDirection + 1) % 5
        elseif keys.CUSTOM_X then
            self.option = self.option == "erase" and "normal" or "erase"
        elseif keys.CUSTOM_SHIFT_X and self.option == "erase" then
            self.erasemode[1] = 2 + (self.erasemode[1] - 1) % 3 --cycle through all 3 erasemodes. (index of selected mode is in [1])

        elseif keys.CUSTOM_F then
            self.mode = self.mode == "construction" and "dig" or "construction"
        elseif keys.CUSTOM_SHIFT_M then
            self.designateMarking = not self.designateMarking


        elseif keys.CUSTOM_SHIFT_F then
            --local matok,mattype,matindex=dfhack.buildings.showMaterialPrompt('Wish','And what material should it be made of?',matFilter)
            --print(matok, mattype, matindex)
            --print(StamperUI.ATTRS.constructionmaterial.mat_name)
            showMatDialog('Choose Material',
                    'Enter a material name (eg. QUARTZITE) for constructions:',
                    self.constructionmaterial.mat_name,
                    function(newval)
                        self.constructionmaterial.mat_name = newval:upper()
                    end)
            --TODO: do some error checking here to make sure it's valid..
            --print("mattext:"..tostring(StamperUI.ATTRS.constructionmaterial.mat_name))
        elseif keys.CUSTOM_SHIFT_B then
            showMatDialog('Choose item type',
                    'Enter a item name (BLOCKS, BOULDERS, WOOD, BARS) for constructions:',
                    self.constructionmaterial.item_name,
                    function(newval)
                        self.constructionmaterial.item_name = newval:upper()
                    end)

            --TODO: do some error checking here to make sure it's valid..


        elseif keys.CUSTOM_P then
            if self.mouse then
                df.global.cursor = self:getCursor()
            end
            dfhack.run_command("digshape", "flood")
            self.undobuffer = "digshape"
        elseif keys.CUSTOM_I then
            self:invertBuffer()
        elseif keys.CUSTOM_C then
            self.state = "convert"

        elseif keys.CUSTOM_B then
            self.blink = not self.blink
        elseif keys.CUSTOM_ALT_B then
            self.blinkrate[1] = 2 + (self.blinkrate[1] - 1) % (#self.blinkrate - 1)
        elseif keys.CUSTOM_M then
            self.mouse = not self.mouse
        elseif keys.CUSTOM_N and self.mouse then
            self.dragging = not self.dragging
        elseif keys.CUSTOM_L and self.mouse and self.dragging then
            self.lerp = not self.lerp
        elseif keys.STRING_A091 then
            -- [, bridge removal
            self.buffer = self:transformBuffer(function(x, y, xlen, ylen, tile)
                local aliveXm, aliveXp, aliveYm, aliveYp = 0, 0, 0, 0
                for px = x - 6, x + 6 do
                    for py = y - 1, y + 1 do
                        if self.buffer[px] and self.buffer[px][py] then
                            if self.buffer[px][py] ~= 0 then
                                if px < x then
                                    aliveXm = aliveXm + 1
                                elseif px > x then
                                    aliveXp = aliveXp + 1
                                end
                            end
                        end
                    end
                end
                for py = y - 6, y + 6 do
                    for px = x - 1, x + 1 do
                        if self.buffer[px] and self.buffer[px][py] then
                            if self.buffer[px][py] ~= 0 then
                                if py < y then
                                    aliveYm = aliveYm + 1
                                elseif py > y then
                                    aliveYp = aliveYp + 1
                                end
                            end
                        end
                    end
                end

                local aliveX = aliveXm + aliveXp
                local aliveY = aliveYm + aliveYp
                local maxAlive = math.max(aliveX, aliveY)
                local minAlive = math.min(aliveX, aliveY)
                local ratio = maxAlive / minAlive
                --[[
                algorithm:
                    in circle around us, divided into 8ths do this:
                    if both sides of the circle are roughly equally long
                    delete ourselves
                ]]
                local alive2 = 0
                for px = x - 3, x + 3 do
                    for py = y - 3, y + 3 do
                        if self.buffer[px] and self.buffer[px][py] then
                            if self.buffer[px][py] ~= 0 then
                                alive2 = alive2 + 1
                            end
                        end
                    end
                end

                local cond = (ratio > 3)
                if minAlive == aliveX and minAlive == aliveY then
                    cond = false
                elseif maxAlive == aliveX and math.abs(aliveXm - aliveXp) < 3 then
                    cond = false
                elseif maxAlive == aliveY and math.abs(aliveYm - aliveYp) < 3 then
                    cond = false
                    --x
                end

                local left = self.buffer[x - 1] and self.buffer[x - 1][y] ~= 0
                local right = self.buffer[x + 1] and self.buffer[x + 1][y] ~= 0
                local top = self.buffer[x] and self.buffer[x][y + 1] and self.buffer[x][y + 1] ~= 0
                local bottom = self.buffer[x] and self.buffer[x][y - 1] and self.buffer[x][y - 1] ~= 0

                if ((not left) and (not right)) or ((not top) and (not bottom)) then
                    cond = true
                end
                if alive2 == 5 then
                    cond = false
                end
                if cond then
                    tile = 0
                end
                --this will mess up if its anything but mining designations but anyways
                return x, y, tile
            end)
        elseif keys.STRING_A093 then
            -- ], rooms
            self.buffer = self:transformBuffer(function(x, y, xlen, ylen, tile)
                local neighbors, alive1, alive2 = 0, 0, 0
                for px = x - 1, x + 1 do
                    for py = y - 1, y + 1 do
                        if self.buffer[px] and self.buffer[px][py] then
                            neighbors = neighbors + 1
                            if self.buffer[px][py] ~= 0 then
                                alive1 = alive1 + 1
                            end
                        end
                    end
                end
                for px = x - 4, x + 4 do
                    for py = y - 4, y + 4 do
                        if self.buffer[px] and self.buffer[px][py] then
                            neighbors = neighbors + 1
                            if self.buffer[px][py] ~= 0 then
                                alive2 = alive2 + 1
                            end
                        end
                    end
                end
                local alive3 = 0
                for px = x - 3, x + 3 do
                    for py = y - 3, y + 3 do
                        if self.buffer[px] and self.buffer[px][py] then
                            if self.buffer[px][py] ~= 0 then
                                alive3 = alive3 + 1
                            end
                        end
                    end
                end
                if alive3 ~= 5 then
                    tile = ((alive1 >= 5) or alive2 <= 4) and (tile == 0 and 1 or tile) or 0
                end


                --this will mess up if its anything but mining designations but anyways

                return x, y, tile
            end)
        elseif keys.STRING_A092 then
            -- |, passages
            self.buffer = self:transformBuffer(function(x, y, xlen, ylen, tile)
                local neighbors, alive, alive2 = 0, 0, 0
                for px = x - 1, x + 1 do
                    for py = y - 1, y + 1 do
                        if self.buffer[px] and self.buffer[px][py] then
                            neighbors = neighbors + 1
                            if self.buffer[px][py] ~= 0 then
                                alive = alive + 1
                            end
                        end
                    end
                end
                for px = x - 3, x + 3 do
                    for py = y - 3, y + 3 do
                        if self.buffer[px] and self.buffer[px][py] then
                            neighbors = neighbors + 1
                            if self.buffer[px][py] ~= 0 then
                                alive2 = alive2 + 1
                            end
                        end
                    end
                end
                local cond = (alive == 0)
                if cond then
                    tile = 1
                end
                --this will mess up if its anything but mining designations but anyways

                return x, y, tile
            end)
        elseif keys.CUSTOM_Z and ((self.option == 'normal' or self.option == 'erase') or self.undobuffer == "digshape") and self.undobuffer ~= nil then
            if self.undobuffer == "digshape" then
                dfhack.run_command("digshape", "undo")
                self.undobuffer = nil
            else
                --todo: make another undo to undo your undo (yo dawg....)
                local stop = xyz2pos(self.undocoords.x + self.undobuffer.xlen, self.undocoords.y + self.undobuffer.ylen, self.undocoords.z)
                local oldundo = getTiles(self.undocoords, stop, false)
                local oldbuffer = self.buffer
                local oldoption = self.option
                self.buffer = self.undobuffer
                self.option = 'verbatim'
                self:pasteBuffer(self.undocoords)
                self.option = oldoption
                self.buffer = oldbuffer
                self.undobuffer = oldundo
            end
        end
    elseif self.state == "mark" then
        local cursor = df.global.cursor --we'll store a copy of the cursor here, depending on how we interact (key or mouse)
        local markingSelection = false

        if keys.SELECT then
            cursor = copyall(df.global.cursor)
            markingSelection = true
        elseif (self.mouse and keys._MOUSE_L_DOWN) then
            cursor = copyall(self:getCursor())
            markingSelection = true
        end

        if markingSelection then
            if self.option == "mark1" then
                --set the table
                self.state = "brush"
                self.option = "normal" --self.marking = false
                self:setBuffer(getTiles(self.mark, cursor, self.cull, self.selectmode))
                self.savedbuffers = { { "testbuffer", copyall(self.buffer) } }
                -- move the cursor so the brush lines up with where we were copying.
                df.global.cursor.x = math.min(self.mark.x, df.global.cursor.x)
                df.global.cursor.y = math.min(self.mark.y, df.global.cursor.y)
                if keys.SELECT or keys._MOUSE_L_DOWN then
                    --do nothing, this is just to clear them so we don't immediately paste. Since we switch back to brush:normal, we'd get caught.
                    keys = {}
                end

            else
                self.option = "mark1" --self.marking = true
                self.mark = cursor
            end
        end

        if keys.CUSTOM_D then
            self.selectmode.designations = not self.selectmode.designations
        elseif keys.CUSTOM_C then
            self.selectmode.constructions = not self.selectmode.constructions
        elseif keys.CUSTOM_ALT_C then
            self.selectmode.constructionWallsAsChannels = not self.selectmode.constructionWallsAsChannels
        elseif keys.CUSTOM_U then
            self.selectmode.constructionsPlaced = not self.selectmode.constructionsPlaced
            print("sm:" .. tostring(self.selectmode.constructionsPlaced))
        elseif keys.CUSTOM_E then
            self.selectmode.empty = not self.selectmode.empty

        elseif keys.CUSTOM_M then
            self.mouse = not self.mouse

        elseif keys.CUSTOM_P then
            self.cull = not self.cull
        end
    elseif self.state == "convert" then
        if self.mode == "dig" then
            if keys.CUSTOM_D then
                self.buffer = self:transformBuffer(function(x, y, xlen, ylen, tile)
                    if tile > 0 then
                        tile = 1
                    end
                    return x, y, tile
                end)
                self.state = "brush"
            elseif keys.CUSTOM_H then
                self.buffer = self:transformBuffer(function(x, y, xlen, ylen, tile)
                    if tile > 0 then
                        tile = 3
                    end
                    return x, y, tile
                end)
                self.state = "brush"
            elseif keys.CUSTOM_U then
                self.buffer = self:transformBuffer(function(x, y, xlen, ylen, tile)
                    if tile > 0 then
                        tile = 6
                    end
                    return x, y, tile
                end)
                self.state = "brush"
            elseif keys.CUSTOM_J then
                self.buffer = self:transformBuffer(function(x, y, xlen, ylen, tile)
                    if tile > 0 then
                        tile = 5
                    end
                    return x, y, tile
                end)
                self.state = "brush"
            elseif keys.CUSTOM_I then
                self.buffer = self:transformBuffer(function(x, y, xlen, ylen, tile)
                    if tile > 0 then
                        tile = 2
                    end
                    return x, y, tile
                end)
                self.state = "brush"
            elseif keys.CUSTOM_R then
                self.buffer = self:transformBuffer(function(x, y, xlen, ylen, tile)
                    if tile > 0 then
                        tile = 4
                    end
                    return x, y, tile
                end)
                self.state = "brush"
            elseif keys.CUSTOM_N then
                self.buffer = self:transformBuffer(function(x, y, xlen, ylen, tile)
                    tile = noise_rng:drandom() < .40 and 1 or 0;
                    return x, y, tile
                end)
                --self.state = "brush"
            end

        elseif self.mode == "construction" then
            if keys.CUSTOM_D then
                self.constructMapping[1] = self.constructMapping[1] % #constructNames + 1
            elseif keys.CUSTOM_H then
                self.constructMapping[3] = self.constructMapping[3] % #constructNames + 1
            elseif keys.CUSTOM_U then
                self.constructMapping[6] = self.constructMapping[6] % #constructNames + 1
            elseif keys.CUSTOM_J then
                self.constructMapping[5] = self.constructMapping[5] % #constructNames + 1
            elseif keys.CUSTOM_I then
                self.constructMapping[2] = self.constructMapping[2] % #constructNames + 1
            elseif keys.CUSTOM_R then
                self.constructMapping[4] = self.constructMapping[4] % #constructNames + 1
            elseif keys.CUSTOM_X then
                self.constructMapping = { 1, 2, 3, 4, 5, 6 }
            elseif keys.CUSTOM_SHIFT_D then
                self.constructMapping[1] = 1
            elseif keys.CUSTOM_SHIFT_H then
                self.constructMapping[3] = 3
            elseif keys.CUSTOM_SHIFT_U then
                self.constructMapping[6] = 6
            elseif keys.CUSTOM_SHIFT_J then
                self.constructMapping[5] = 5
            elseif keys.CUSTOM_SHIFT_I then
                self.constructMapping[2] = 2
            elseif keys.CUSTOM_SHIFT_R then
                self.constructMapping[4] = 4
            elseif keys.CUSTOM_CTRL_D then
                self.constructMapping[1] = 3
            elseif keys.CUSTOM_CTRL_H then
                self.constructMapping[3] = 3
            elseif keys.CUSTOM_CTRL_U then
                self.constructMapping[6] = 3
            elseif keys.CUSTOM_CTRL_J then
                self.constructMapping[5] = 3
            elseif keys.CUSTOM_CTRL_I then
                self.constructMapping[2] = 3
            elseif keys.CUSTOM_CTRL_R then
                self.constructMapping[4] = 3
            elseif keys.CUSTOM_ALT_D then
                self.constructMapping[1] = 1
            elseif keys.CUSTOM_ALT_H then
                self.constructMapping[3] = 1
            elseif keys.CUSTOM_ALT_U then
                self.constructMapping[6] = 1
            elseif keys.CUSTOM_ALT_J then
                self.constructMapping[5] = 1
            elseif keys.CUSTOM_ALT_I then
                self.constructMapping[2] = 1
            elseif keys.CUSTOM_ALT_R then
                self.constructMapping[4] = 1
            elseif keys.CUSTOM_SHIFT_S then
                self.constructMapping = { 12, 12, 12, 12, 12, 12 }
            elseif keys.CUSTOM_SHIFT_F then
                self.constructMapping = { 1, 1, 1, 1, 1, 1 }
            elseif keys.CUSTOM_SHIFT_W then
                self.constructMapping = { 3, 3, 3, 3, 3, 3 }
            end
        end
    end


    --Paste the brush. This is a separate chunk so it can apply to the various submenus too.
    if self.state == "brush" or self.state == "transform" or (self.state == "convert" and self.mode == "construction") then
        if keys.SELECT then
            if self.option == "normal" or self.option == "erase" or self.option == "" then
                --only undo regular designations
                local cursor = copyall(self:getCursor())
                local offsetX, offsetY = self:getOffset()

                cursor.x = cursor.x + offsetX
                cursor.y = cursor.y + offsetY
                self.undocoords = copyall(cursor)
                self.undobuffer = getTiles(xyz2pos(cursor.x + self.buffer.xlen, cursor.y + self.buffer.ylen, cursor.z), copyall(cursor), false, nil)
            end
            self:pasteBuffer(copyall(self:getCursor()))
        elseif keys._MOUSE_L_DOWN and self.mouse then
            if self.option == "normal" or self.option == "erase" then
                if drag ~= true then
                    if not self.dragging then
                        self.undocoords = copyall(self:getCursor())
                        self.undobuffer = getTiles(xyz2pos((self:getCursor()).x + self.buffer.xlen, (self:getCursor()).y + self.buffer.ylen, (self:getCursor()).z), copyall(self:getCursor()), false)
                    else
                        local vp = self:getViewport()
                        self.undocoords = xyz2pos(vp.x1, vp.y1, df.global.window_z)
                        self.undobuffer = getTiles({ x = vp.x1, y = vp.y1, z = df.global.window_z }, { x = vp.x2, y = vp.y2, z = df.global.window_z }, false)
                    end
                end
            end
            self.busy = true
            self:pasteBuffer(copyall(tempcursor or self:getCursor()))
            self.busy = false
        end
    end

    if keys.LEAVESCREEN then
        if self.state == "brush" then
            self:dismiss() --exit stamper
        elseif self.state == "mark" and self.option == "create" then
            self.option = "normal" --clear create, or we can't get back to the regular select submenu.
            self.state = "brush" --back to main menu
        else
            self.state = "brush" --back to main menu
        end

    elseif self:propagateMoveKeys(keys) then
        return
    end
end

if not (dfhack.gui.getCurFocus():match("^dwarfmode/Default") or dfhack.gui.getCurFocus():match("^dwarfmode/Designate") or dfhack.gui.getCurFocus():match("^dwarfmode/LookAround")) then
    qerror("This screen requires the main dwarfmode view or the designation screen")
end

local list = StamperUI { state = _G.stamper_saved_options and "brush" or "mark", blink = false, cull = true }
list:show()





--Material popup dialog cribbed from rename.lua
MatDialog = defclass(MatDialog, dlg.InputBox)
function MatDialog:init(info)
    self:addviews {
        widgets.Label {
            view_id = 'controls',
            text = {
                {
                    key = 'CUSTOM_ALT_C',
                    text = ': Clear, ',
                    on_activate = function()
                        self.subviews.edit.text = ''
                    end
                },
                --{key = 'CUSTOM_ALT_S', text = ': Special chars', on_activate = curry(dfhack.run_script, 'gui/cp437-table')},
                --{key = 'CUSTOM_ALT_B', text = ': toggle item: '..(StamperUI.ATTRS.item_type==df.item_type.BLOCKS and 'blocks/BOULDERS' or 'BLOCKS/boulders'),
                -- on_activate = function()
                --     if StamperUI.ATTRS.item_type==df.item_type.BLOCKS then
                --         StamperUI.ATTRS.item_type=df.item_type.BOULDERS
                --     else
                --         StamperUI.ATTRS.item_type=df.item_type.BLOCKS
                --     end
                --     show()
                -- end},
            },
            frame = { b = 0, l = 0, r = 0, w = 70 },
        }
    }
    -- calculate text_width once
    self.subviews.controls:getTextWidth()
end

--function MatDialog:onRenderFrame(dc)
--    MatDialog.super.onRenderFrame(self,dc)
--dc:key('CUSTOM_ALT_B'):string(': toggle item: '..(StamperUI.ATTRS.item_type==df.item_type.BLOCKS and 'blocks/BOULDERS' or 'BLOCKS/boulders'), COLOR_DARKGREY)
--end

function MatDialog:getWantedFrameSize()
    local x, y = self.super.getWantedFrameSize(self)
    x = math.max(x, self.subviews.controls.text_width)
    return x, y + 2
end

function showMatDialog(title, text, input, on_input)
    MatDialog {
        frame_title = title,
        text = text,
        text_pen = COLOR_GREEN,
        input = input,
        on_input = on_input,
        -- on_input = scripts.mkresume(true),
        -- on_cancel = scripts.mkresume(false),
        -- on_close = scripts.qresume(nil)
    }:show()
    --return scripts.wait()
end



---------------------------------
-- fixed bugs



--bug: will not place constructions on top of walls on layer below.
--      -Constructions::designateNew() returns false here
--      -probe shows identical returns for a floor on this level or a wall on level below, therefore there will already be a building here.
--      -works ok for other constructions on level below
--      --From automaterial.cpp:
--          // Can build on top of a wall, but not on other construction
--            auto construction = Constructions::findAtTile(site.pos);
--            if (construction)
--            {
--                if (construction->flags.bits.top_of_wall==0)
--                    return false;
--            }


--bug: may display incorrectly (and show to q as 'construction' rather than 'ramp' or 'wall'.
--      -Save/load corrects the display.
--      -using the alternate build construction method avoids this

--FIXED. bug: can place(stack) constructions on top of exisiting constructions.
--FIXED. bug: having current paste as translations messes up stamping dig designations (eg h->skip will not always stamp h)
--PROB.FIXED bug: stamp doesn't appear until a key is pressed when stamper reopened.
--PROB.FIXED bug: stamp doesn't move with view (when called from main screen rather than designation menu)





--[lua]# @df.construction_type
--<type: construction_type>
-- -1                       = NONE
--0                        = Fortification
--1                        = Wall
--2                        = Floor
--3                        = UpStair
--4                        = DownStair
--5                        = UpDownStair
--6                        = Ramp

--
--@df.tiletype_shape
--0                      	 = EMPTY
--1                      	 = FLOOR
--2                      	 = BOULDER
--3                      	 = PEBBLES
--10                     	 = RAMP_TOP
--11                     	 = BROOK_BED
--12                     	 = BROOK_TOP
--13                     	 = BRANCH
--14                     	 = TRUNK_BRANCH
--15                     	 = TWIG
--16                     	 = SAPLING
--17                     	 = SHRUB
--18                     	 = ENDLESS_PIT
--
--4                      	 = WALL
--5                      	 = FORTIFICATION
--6                      	 = STAIR_UP
--7                      	 = STAIR_DOWN
--8                      	 = STAIR_UPDOWN
--9                      	 = RAMP
--10                     	 = RAMP_TOP