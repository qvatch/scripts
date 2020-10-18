--designating tool

--[====[

gui/stamper
===========
allows manipulation of designations by transforms such as translations, reflections, rotations, and inversion.
designations can also be used as brushes to erase other designations and cancel constructions.

]====]
--todo:xor
--[[
-growing
-mouse support


]]
local utils = require "utils"
local gui = require "gui"
local guidm = require "gui.dwarfmode"
local dlg = require "gui.dialogs"
local enabler = df.global.enabler

local noise_rng = dfhack.random.new()

StamperUI = defclass(StamperUI, guidm.MenuOverlay)

StamperUI.ATTRS {
    state="none",
    buffer=nil,
    offsetDirection=0,
    cull=true,
    blink=false,
	mouse=false,
	dragging=false,
    option="normal",
	lastMouse=xyz2pos(0,0,0),
	lerp=true, --lerp is laggy because it repeatedly inefficiently accesses memory; it would be faster if we cached some but thats above my paygrade ;)
	customOffset={x=0,y=0}
}

local digSymbols={" ", "X", "_", 30, ">", "<"}

function StamperUI:init()
    self.saved_mode = df.global.ui.main.mode
	if _G.stamper_saved_buffer then
		self.buffer=_G.stamper_saved_buffer
	end
    df.global.ui.main.mode=df.ui_sidebar_mode.LookAround
	df.global.cursor.z=df.global.window_z
end

function StamperUI:onDestroy()
	_G.stamper_saved_buffer=self.buffer
    df.global.ui.main.mode = self.saved_mode
end

local function paintMapTile(dc, vp, cursor, pos, ...)
    if not same_xyz(cursor, pos) then
        local stile = vp:tileToScreen(pos)
        if stile.z == 0 then
            dc:map(true):seek(stile.x,stile.y):char(...):map(false)
        end
    end
end

local function minToMax(...)
    local args={...}
    table.sort(args,function(a,b) return a < b end)
    return table.unpack(args)
end

local function getMousePos()
    local posx,posy,posz=-30000,0,0

	local mx, my = dfhack.screen.getMousePos()
    local vx, vy, vz=df.global.window_x,df.global.window_y,df.global.window_z

    posx = vx + mx - 1;
    posy = vy + my - 1;
    posz = vz -- - dfhack.gui.getDepthAt(mx,my)
    return xyz2pos(posx,posy,posz)
end

function StamperUI:getCursor()
	if self.mouse then
		return getMousePos()
	else
		return df.global.cursor
	end
end

local function cullBuffer(data) --there's probably a memory saving way of doing this
    local lowerX=math.huge
    local lowerY=math.huge
    local upperX=-math.huge
    local upperY=-math.huge
    for x=0,data.xlen do
        for y=0,data.ylen do
            if data[x][y].dig>0 then
                lowerX=math.min(x,lowerX)
                lowerY=math.min(y,lowerY)
                upperX=math.max(x,upperX)
                upperY=math.max(y,upperY)
            end
        end
    end
    if lowerX==math.huge then lowerX=0 end
    if lowerY==math.huge then lowerY=0 end
    if upperX==-math.huge then upperX=data.xlen end
    if upperY==-math.huge then upperY=data.ylen end
    local buffer={}
    for x=lowerX,upperX do
        buffer[x-lowerX]={}
        for y=lowerY,upperY do
            buffer[x-lowerX][y-lowerY]=data[x][y]
        end
    end
    buffer.xlen=upperX-lowerX
    buffer.ylen=upperY-lowerY
    return buffer
end

local function padBuffer(data,n) --there's probably a memory saving way of doing this
	local n=n or  1
    local buffer={}
    for x=0,data.xlen+(2*n) do
        buffer[x]={}
        for y=0,data.ylen+(2*n) do
			if y>(n-1) and x>(n-1) and y<data.ylen+(n*2) and x<data.xlen+(n*2) then
				buffer[x][y]=data[x-n][y-n]
			else
				buffer[x][y]={dig=0}
			end
        end
    end
    buffer.xlen=data.xlen+(2*n)
    buffer.ylen=data.ylen+(2*n)
    return buffer
end

local function getTiles(p1,p2,cull)
    if cull==nil then cull=true end
    local x1,x2=minToMax(p1.x,p2.x)
    local y1,y2=minToMax(p1.y,p2.y)
    local xlen=x2-x1
    local ylen=y2-y1
    assert(p1.z==p2.z, "only tiles from the same Z-level can be copied")
    local z=p1.z
    local data={}
    for k, block in ipairs(df.global.world.map.map_blocks) do
        if block.map_pos.z==z then
            for block_x, row in ipairs(block.designation) do
                local x=block_x+block.map_pos.x
                if x>=x1 and x<=x2 then
                    if not data[x-x1] then
                        data[x-x1]={}
                    end
                    for block_y, tile in ipairs(row) do
                        local y=block_y+block.map_pos.y
                        if y>=y1 and y<=y2 then
                            data[x-x1][y-y1]=copyall(tile)
							local tiletype = df.tiletype.attrs[block.tiletype[block_x][block_y]]
							local mat = tiletype.material
							if data[x-x1][y-y1].dig==1 and tiletype.shape == df.tiletype_shape.FLOOR or mat == df.tiletype_material.AIR then
								data[x-x1][y-y1].dig=0
							end
                        end
                    end
                end
            end
        end
    end
    data.xlen=xlen
    data.ylen=ylen
    if cull then
        return cullBuffer(data)
    end
    return data
end

function StamperUI:getOffset()
    if self.offsetDirection==0 then --southeast
        return 0, 0
    elseif self.offsetDirection==1 then --northeast
        return 0, -self.buffer.ylen
    elseif self.offsetDirection==2 then --northwest
        return -self.buffer.xlen, -self.buffer.ylen
    elseif self.offsetDirection==3 then --southwest
        return -self.buffer.xlen, 0
	elseif self.offsetDirection==4 then --center
		return -math.floor(self.buffer.xlen/2+.5),math.floor(-self.buffer.ylen/2+.5)
	elseif self.offsetDirection==5 then --custom
		return self.customOffset.x,self.customOffset.y
    else
        error("out of range")
    end
end

function StamperUI:setBuffer(tiles)
    self.buffer=tiles
end

function StamperUI:transformBuffer(callback)
    local newBuffer={}
    local xlen=0
    local ylen=0
    for x=0, self.buffer.xlen do
        for y=0, self.buffer.ylen do
			local tile = copyall(self.buffer[x][y]);
            local x2,y2=callback(x,y,self.buffer.xlen,self.buffer.ylen,tile)
            xlen=math.max(x2,xlen)
            ylen=math.max(y2,ylen)
            if not newBuffer[x2] then
                newBuffer[x2]={}
            end
            if not newBuffer[x2][y2] then
                newBuffer[x2][y2]=tile --self.buffer[x][y]
            end
        end
    end
    newBuffer.xlen=xlen
    newBuffer.ylen=ylen
    return newBuffer
end

function StamperUI:lerpInput(key,start,stop)
  start=copyall(start)
  local dx = math.abs(stop.x-start.x)
  local dy = math.abs(stop.y-start.y)

  local sx = start.x < stop.x and 1 or -1
  local sy = start.y < stop.y and 1 or -1

  local err = math.floor((dx>dy and dx or -dy)/2)
  local err2
  local list = nil
  while true do
	list = self:pasteBuffer({x=start.x,y=start.y,z=df.global.window_z},list)
    if (start.x==stop.x and start.y==stop.y) then
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
    local z=position.z
    local offsetX,offsetY=self:getOffset()
	if self.option=='verbatim' then
		offsetX=0
		offsetY=0
	end
    local x1=position.x+offsetX
    local x2=position.x+self.buffer.xlen+offsetX
    local y1=position.y+offsetY
    local y2=position.y+self.buffer.ylen+offsetY
	local newList = blockList or {} --cached list of  blocks for bresenham (not sure if this helps but oh well)
    for k, block in ipairs(blocklist or df.global.world.map.map_blocks) do
      if block.map_pos.z==z then
		 if not blockList then table.insert(newList, block) end
         for block_x, row in ipairs(block.designation) do
            local x=block_x+block.map_pos.x
            if x>=x1 and x<=x2 then
                for block_y, tile in ipairs(row) do
                    local y=block_y+block.map_pos.y
                    if y>=y1 and y<=y2 and (self.buffer[x-x1] and self.buffer[x-x1][y-y1] and self.buffer[x-x1][y-y1].dig and (self.buffer[x-x1][y-y1].dig>0 or self.option=='verbatim')) then
						local tiletype = df.tiletype.attrs[block.tiletype[block_x][block_y]]
						local mat = tiletype.material
                        if self.option=="erase" then
                            tile.dig=0
                        elseif self.option=="construction" then
                            dfhack.constructions.designateRemove(x,y,z)
                        elseif not (self.buffer[x-x1][y-y1].dig==1 and tiletype.shape == df.tiletype_shape.FLOOR or mat == df.tiletype_material.AIR) then
								tile.dig=self.buffer[x-x1][y-y1].dig
								block.occupancy[block_x][block_y].dig_marked = false
								block.dsgn_check_cooldown = 0;
								block.flags.designated = true;
                        end
                    end
                end
            end
         end
      end
    end
	return newList
end

function StamperUI:invertBuffer() --this modifies the buffer instead of copying it
    self.buffer = self:transformBuffer(function(x,y,xlen,ylen,tile) if tile.dig>0 then tile.dig=0 else tile.dig=1 end return x,y end)
end

function StamperUI:renderOverlay()
    local vp=self:getViewport()
    local dc = gui.Painter.new(self.df_layout.map)
    local visible = gui.blink_visible(500)

    if gui.blink_visible(120) and self.marking then
        paintMapTile(dc, vp, nil, self.mark, "+", COLOR_LIGHTGREEN)
        --perhaps draw a rectangle to the point
    elseif not marking and (gui.blink_visible(750) or not self.blink) and self.buffer~=nil and (self.state=="brush" or self.state=="convert") then
        --draw over (self:getCursor()) in these circumstances
        local offsetX,offsetY=self:getOffset()
        for x=0, self.buffer.xlen do
            for y=0, self.buffer.ylen do
                local tile=self.buffer[x][y]
                if tile.dig>0 then
                    if not (gui.blink_visible(750) and x==-offsetX and y==-offsetY) then
                        local fg=COLOR_BLACK
                        local bg=COLOR_CYAN
                        if self.option=="erase" then
                            bg=COLOR_RED
                            fg=COLOR_BLACK
                        elseif self.option=="construction" then
                            bg=COLOR_GREEN
                            fg=COLOR_BLACK
                        end
                        local symbol=digSymbols[tile.dig]
                        if self.option~="normal" then
                            symbol=" "
                        end
                        dc:pen(fg,bg)
                        paintMapTile(dc, vp, nil, xyz2pos((self:getCursor()).x+x+offsetX,(self:getCursor()).y+y+offsetY,(self:getCursor()).z), symbol, fg)
                    end
                end
            end
        end
    end
end

function StamperUI:onRenderBody(dc)
    self:renderOverlay()


    dc:clear():seek(1,1):pen(COLOR_WHITE):string("Stamper - "..self.state:gsub("^%a",function(x)return x:upper()end))
    dc:seek(2,3)

    if self.state=="brush" then
        dc:key_string("CUSTOM_S", "Set Brush",COLOR_GREY)
        dc:newline():newline(1)
        dc:key_string("CUSTOM_H", "Flip Horizontal",COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_V", "Flip Vertical",COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_R", "Rotate 90",COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_T", "Rotate -90",COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_G", "Cycle Corner",COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_I", "Invert",COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_C", "Convert to...",COLOR_GREY):newline(1)
        dc:newline(1)
        dc:key_string("CUSTOM_X", (self.option=="erase" and "Erasing" or "Erase"),self.option=="erase" and COLOR_RED or COLOR_GREY):newline(1) --make red
        dc:key_string("CUSTOM_F", (self.option=="construction" and "Removing" or "Remove").." Constructions",self.option=="construction" and COLOR_GREEN or COLOR_GREY):newline(1) --make red
        dc:newline():newline(1)
        dc:key_string("CUSTOM_B", "Blink Brush",self.blink and COLOR_WHITE or COLOR_GREY):newline(1)
		dc:key_string("CUSTOM_M", (self.mouse and "Disable" or "Enable").." Mouse",self.mouse and COLOR_WHITE or COLOR_GREY):newline(1)
		if self.mouse then
		    dc:key_string("CUSTOM_N", (self.dragging and "Disable" or "Enable").." Mouse Dragging",self.dragging and COLOR_WHITE or COLOR_GREY):newline(1)
		else
		    dc:newline(1)
		end
		if self.mouse and self.dragging then
		    dc:key_string("CUSTOM_L", (self.lerp and "Disable" or "Enable").." Drag Lerp",self.lerp and COLOR_WHITE or COLOR_GREY):newline(1)
		else
			dc:newline(1)
		end
		dc:key_string("CUSTOM_P", "Flood (Digshape)",COLOR_GREY):newline(1)
		if self.option=="normal" or self.option=="erase" or self.undobuffer=="digshape" then
			dc:key_string("CUSTOM_Z", "Undo"..(self.undobuffer=="digshape" and " Digshape" or ""),self.undobuffer~=nil and COLOR_WHITE or COLOR_GREY):newline(1)
		end
		dc:newline(1)
		dc:key_string("SECONDSCROLL_DOWN", "Grow Brush",COLOR_GREY):newline(1)
		dc:key_string("SECONDSCROLL_UP", "Shrink Brush",COLOR_GREY):newline(1)
		dc:newline(1)
		dc:key_string("STRING_A091", "Cell Bridge Remove",COLOR_GREY):newline(1)
		dc:key_string("STRING_A092", "Cell Passages",COLOR_GREY):newline(1)
		dc:key_string("STRING_A093", "Cell Rooms",COLOR_GREY):newline(1)
        dc:newline()

    elseif self.state=="mark" then
        if self.buffer==nil then
            dc:string("Select two corners.")
        end
        dc:newline():newline(1)
		dc:key_string("CUSTOM_M", (self.mouse and "Disable" or "Enable").." Mouse",self.mouse and COLOR_WHITE or COLOR_GREY):newline(1)
        dc:key_string("CUSTOM_P", "Cull Selections",self.cull and COLOR_WHITE or COLOR_GREY)
    elseif self.state=="convert" then
        dc:key_string("CUSTOM_D","Mine",COLOR_GREY):newline(2)
        dc:key_string("CUSTOM_H", "Channel",COLOR_GREY):newline(2)
        dc:key_string("CUSTOM_U", "Up Stair",COLOR_GREY):newline(2)
        dc:key_string("CUSTOM_J", "Up Stair",COLOR_GREY):newline(2)
        dc:key_string("CUSTOM_I", "U/D Stair",COLOR_GREY):newline(2)
        dc:key_string("CUSTOM_R", "Up Ramp",COLOR_GREY):newline(2):newline(2)
		dc:key_string("CUSTOM_N", "Random Noise",COLOR_RED):newline(4)
		dc:string("for cellular automata",COLOR_GREY):newline(1);
        dc:newline(1)
        dc:string("To undesignate use the erase mode",COLOR_WHITE)
    end

    dc:newline():newline():key_string("LEAVESCREEN", "Back")
end



function StamperUI:onIdle()
	if self.mouse and self.dragging then
		local pos=getMousePos()
		if enabler.mouse_lbut_down==1 then
			if self.lastMouse.x~=pos.x or self.lastMouse.y~=pos.y or self.lastMouse.z~=pos.z then
				if self.lerp and (math.abs(self.lastMouse.x-pos.x)>1 or math.abs(self.lastMouse.y-pos.y)>1 or math.abs(self.lastMouse.z-pos.z)>1) then
					self:lerpInput({_MOUSE_L_DOWN=true,_MOUSE_L=true},pos,self.lastMouse)
				else
					self:onInput({_MOUSE_L_DOWN=true,_MOUSE_L=true},true)
				end
			end
		end
		self.lastMouse=pos
	end
end
function StamperUI:onInput(keys,drag,tempcursor)
    if df.global.cursor.x==-30000 then
        local vp=self:getViewport()
        df.global.cursor=xyz2pos(math.floor((vp.x1+math.abs((vp.x2-vp.x1))/2)+.5),math.floor((vp.y1+math.abs((vp.y2-vp.y1)/2))+.5), df.global.window_z)
        return
    end

    if self.state=="brush" then
        if keys.CUSTOM_S then
            self.state="mark"
		elseif (keys.SECONDSCROLL_DOWN or keys._STRING==61 or keys._STRING==43) and self.buffer then -- + or =
			local offsetX, offsetY = self:getOffset()
			self.buffer=padBuffer(self.buffer,1)
			local newbuffer={}
			for x=0,self.buffer.xlen do
				newbuffer[x]={}
				for y=0,self.buffer.ylen do
					newbuffer[x][y]=copyall(self.buffer[x][y])
					if newbuffer[x][y].dig==0 then
						for ix=x-1,x+1 do
							for iy=y-1,y+1 do
								if ix>=0 and ix<=self.buffer.xlen and iy>=0 and iy<=self.buffer.ylen and self.buffer[ix][iy].dig>0 then

									newbuffer[x][y].dig=self.buffer[ix][iy].dig
									break
								end
							end
						end
					end
				end
			end
			newbuffer.xlen=self.buffer.xlen
			newbuffer.ylen=self.buffer.ylen
			local offCenterX=(math.floor(self.buffer.xlen/2+.5))-offsetX
			offCenterX=offCenterX+(offCenterX==0 and 0 or (offCenterX/math.abs(offCenterX)))
			offsetX=(math.floor(self.buffer.xlen/2+.5))-offCenterX

			local offCenterY=(math.floor(self.buffer.ylen/2+.5))-offsetY
			offCenterY=offCenterY+(offCenterY==0 and 0 or (offCenterY/math.abs(offCenterY)))
			offsetY=(math.floor(self.buffer.ylen/2+.5))-offCenterY

			self.customOffset={x=offsetX,y=offsetY}
			self.offsetDirection=5
			self.buffer=newbuffer
		elseif (keys.SECONDSCROLL_UP or keys._STRING==95 or keys._STRING==45) and self.buffer then -- - or _
			local offsetX, offsetY = self:getOffset()
			--self.buffer=padBuffer(self.buffer,0)
			local newbuffer={}
			for x=1,self.buffer.xlen-1 do
				newbuffer[x-1]={}
				for y=1,self.buffer.ylen-1 do
					newbuffer[x-1][y-1]=copyall(self.buffer[x][y])
					if newbuffer[x-1][y-1].dig~=0 then
						for ix=x-1,x+1 do
							for iy=y-1,y+1 do
								if self.buffer[ix][iy].dig==0 then
									newbuffer[x-1][y-1].dig=0
									break
								end
							end
						end
					end
					if y==0 or x==0 or y==self.buffer.ylen or x==self.buffer.xlen then
						newbuffer[x-1][y-1].dig=0
					end
				end
			end
			newbuffer.xlen=self.buffer.xlen-2
			newbuffer.ylen=self.buffer.ylen-2
			local offCenterX=(math.floor(self.buffer.xlen/2+.5))-offsetX
			offCenterX=offCenterX-(offCenterX==0 and 0 or (offCenterX/math.abs(offCenterX)))
			offsetX=(math.floor(self.buffer.xlen/2+.5))-offCenterX

			local offCenterY=(math.floor(self.buffer.ylen/2+.5))-offsetY
			offCenterY=offCenterY-(offCenterY==0 and 0 or (offCenterY/math.abs(offCenterY)))
			offsetY=(math.floor(self.buffer.ylen/2+.5))-offCenterY

			self.customOffset={x=offsetX,y=offsetY}
			self.offsetDirection=5
			self.buffer=newbuffer
        elseif keys.CUSTOM_D then
            self.state="brush"
        elseif keys.CUSTOM_H then
            self.buffer=self:transformBuffer(function(x,y,xlen,ylen,tile) return xlen-x, y end)
        elseif keys.CUSTOM_V then
            self.buffer=self:transformBuffer(function(x,y,xlen,ylen,tile) return x, ylen-y end)
        elseif keys.CUSTOM_R then
            self.buffer=self:transformBuffer(function(x,y,xlen,ylen,tile) return y, xlen-x end)
            self.offsetDirection=(self.offsetDirection+1)%4
        elseif keys.CUSTOM_T then
            self.buffer=self:transformBuffer(function(x,y,xlen,ylen,tile) return ylen-y,x  end)
            self.offsetDirection=(self.offsetDirection-1)%4
        elseif keys.CUSTOM_G then
            self.offsetDirection=(self.offsetDirection+1)%5
        elseif keys.CUSTOM_X then
            self.option=self.option=="erase" and "normal" or "erase"
        elseif keys.CUSTOM_F then
            self.option=self.option=="construction" and "normal" or "construction"
		elseif keys.CUSTOM_P then
			if self.mouse then df.global.cursor=self:getCursor() end
			dfhack.run_command("digshape","flood")
			self.undobuffer="digshape"
        elseif keys.CUSTOM_I then
            self:invertBuffer()
        elseif keys.CUSTOM_C then
            self.state="convert"
        elseif keys.CUSTOM_B then
            self.blink = not self.blink
		elseif keys.CUSTOM_M then
			self.mouse = not self.mouse
		elseif keys.CUSTOM_N and self.mouse then
			self.dragging = not self.dragging
		elseif keys.CUSTOM_L and self.mouse and self.dragging then
			self.lerp = not self.lerp
		elseif keys.STRING_A091 then -- [, bridge removal
			self.buffer=self:transformBuffer(function(x,y,xlen,ylen,tile)
				local aliveXm,aliveXp,aliveYm,aliveYp = 0,0,0,0,0
				for px=x-6,x+6 do
					for py=y-1,y+1 do
							if self.buffer[px] and self.buffer[px][py] then
								if self.buffer[px][py].dig ~= 0 then
										if px<x then
											aliveXm = aliveXm + 1
										elseif px>x then
											aliveXp = aliveXp + 1
										end
								end
							end
					end
				end
				for py=y-6,y+6 do
					for px=x-1,x+1 do
						if self.buffer[px] and self.buffer[px][py] then
							if self.buffer[px][py].dig ~= 0 then
									if py<y then
										aliveYm = aliveYm + 1
									elseif py>y then
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
				local ratio = maxAlive/minAlive
				--[[
				algorithm:
					in circle around us, divided into 8ths do this:
					if both sides of the circle are roughly equally long
					delete ourselves
				]]
				local alive2 = 0
				for px=x-3,x+3 do
					for py=y-3,y+3 do
						if self.buffer[px] and self.buffer[px][py] then
							if self.buffer[px][py].dig ~= 0 then
									alive2 = alive2 + 1
							end
						end
					end
				end


				local cond = (ratio > 3)
				if minAlive == aliveX and minAlive == aliveY then
					cond = false
				elseif maxAlive == aliveX and math.abs(aliveXm-aliveXp)<3 then
					cond = false
				elseif maxAlive == aliveY and math.abs(aliveYm-aliveYp)<3 then
					cond = false
					--x
				end

				local left = self.buffer[x-1] and self.buffer[x-1][y].dig~=0
				local right = self.buffer[x+1] and self.buffer[x+1][y].dig~=0
				local top = self.buffer[x] and self.buffer[x][y+1] and self.buffer[x][y+1].dig~=0
				local bottom = self.buffer[x] and self.buffer[x][y-1] and self.buffer[x][y-1].dig~=0

				if ((not left) and (not right)) or ((not top) and (not bottom)) then
					cond = true
				end
				if alive2==5 then
					cond = false
				end
				if cond then
					tile.dig = 0
				end
				--this will mess up if its anything but mining designations but anyways
				return x,y
			end)
		elseif keys.STRING_A093 then -- ], rooms
			self.buffer=self:transformBuffer(function(x,y,xlen,ylen,tile)
				local neighbors,alive1,alive2 = 0,0,0
				for px=x-1,x+1 do
					for py=y-1,y+1 do
						if self.buffer[px] and self.buffer[px][py] then
							neighbors = neighbors + 1
							if self.buffer[px][py].dig ~= 0 then
									alive1 = alive1 + 1
							end
						end
					end
				end
				for px=x-4,x+4 do
					for py=y-4,y+4 do
						if self.buffer[px] and self.buffer[px][py] then
							neighbors = neighbors + 1
							if self.buffer[px][py].dig ~= 0 then
									alive2 = alive2 + 1
							end
						end
					end
				end
				local alive3 = 0
				for px=x-3,x+3 do
					for py=y-3,y+3 do
						if self.buffer[px] and self.buffer[px][py] then
							if self.buffer[px][py].dig ~= 0 then
									alive3 = alive3 + 1
							end
						end
					end
				end
				if alive3 ~= 5 then
					tile.dig = ((alive1 >= 5 ) or alive2 <= 4) and (tile.dig==0 and 1 or tile.dig) or 0
				end


				--this will mess up if its anything but mining designations but anyways

				return x,y
			end)
		elseif keys.STRING_A092 then -- |, passages
		self.buffer=self:transformBuffer(function(x,y,xlen,ylen,tile)
			local neighbors,alive,alive2 = 0,0,0
			for px=x-1,x+1 do
				for py=y-1,y+1 do
					if self.buffer[px] and self.buffer[px][py] then
						neighbors = neighbors + 1
						if self.buffer[px][py].dig ~= 0 then
								alive = alive + 1
						end
					end
				end
			end
			for px=x-3,x+3 do
				for py=y-3,y+3 do
					if self.buffer[px] and self.buffer[px][py] then
						neighbors = neighbors + 1
						if self.buffer[px][py].dig ~= 0 then
								alive2 = alive2 + 1
						end
					end
				end
			end
			local cond = (alive == 0)
			if cond then
				tile.dig = 1
			end
			--this will mess up if its anything but mining designations but anyways

			return x,y
		end)
		elseif keys.CUSTOM_Z and ((self.option=='normal' or self.option=='erase') or self.undobuffer=="digshape") and self.undobuffer~=nil then
			if self.undobuffer=="digshape" then
				dfhack.run_command("digshape","undo")
				self.undobuffer=nil
			else --todo: make another undo to undo your undo (yo dawg....)
				local stop=xyz2pos(self.undocoords.x+self.undobuffer.xlen,self.undocoords.y+self.undobuffer.ylen,self.undocoords.z)
				local oldundo=getTiles(self.undocoords,stop,false)
				local oldbuffer=self.buffer
				local oldoption=self.option
				self.buffer=self.undobuffer
				self.option='verbatim'
				self:pasteBuffer(self.undocoords)
				self.option=oldoption
				self.buffer=oldbuffer
				self.undobuffer=oldundo
			end
        elseif keys.SELECT then
			if self.option=="normal" or self.option=="erase" then --only undo regular designations
				local cursor=copyall(self:getCursor())
				local offsetX,offsetY=self:getOffset()

				cursor.x=cursor.x+offsetX
				cursor.y=cursor.y+offsetY
				self.undocoords=copyall(cursor)
				self.undobuffer=getTiles(xyz2pos(cursor.x+self.buffer.xlen,cursor.y+self.buffer.ylen,cursor.z),copyall(cursor),false)
			end
            self:pasteBuffer(copyall(self:getCursor()))
		elseif keys._MOUSE_L_DOWN and self.mouse then
			if self.option=="normal" or self.option=="erase" then
			    if drag~=true then
					if not self.dragging then
						self.undocoords=copyall(self:getCursor())
						self.undobuffer=getTiles(xyz2pos((self:getCursor()).x+self.buffer.xlen,(self:getCursor()).y+self.buffer.ylen,(self:getCursor()).z),copyall(self:getCursor()),false)
					else

						local vp=self:getViewport()
						self.undocoords=xyz2pos(vp.x1,vp.y1,df.global.window_z)
						self.undobuffer=getTiles({x=vp.x1,y=vp.y1,z=df.global.window_z},{x=vp.x2,y=vp.y2,z=df.global.window_z},false)
					end
				end
			end
            self:pasteBuffer(copyall(tempcursor or self:getCursor()))
        end
    elseif self.state=="mark" then
        if keys.SELECT then
            if self.marking then
                --set the table
                self.state="brush"
                self.marking = false
                self:setBuffer(getTiles(self.mark,copyall(df.global.cursor),self.cull))
            else
                self.marking = true
                self.mark = copyall(df.global.cursor)
            end
		elseif (self.mouse and keys._MOUSE_L_DOWN) then
            if self.marking then
                --set the table
                self.state="brush"
                self.marking = false
                self:setBuffer(getTiles(self.mark,copyall(self:getCursor()),self.cull))
            else
                self.marking = true
                self.mark = copyall(self:getCursor())
            end
		elseif keys.CUSTOM_M then
			self.mouse = not self.mouse
        elseif keys.LEAVESCREEN and self.buffer~=nil then
            self.state="brush"
            return
        elseif keys.CUSTOM_P then
            self.cull = not self.cull
        end
    elseif self.state=="convert" then
        if keys.LEAVESCREEN then
            self.state="brush"
            return
        elseif keys.CUSTOM_D then
            self.buffer=self:transformBuffer(function(x,y,xlen,ylen,tile) if tile.dig>0 then tile.dig=1 end return x,y end)
            self.state="brush"
        elseif keys.CUSTOM_H then
            self.buffer=self:transformBuffer(function(x,y,xlen,ylen,tile) if tile.dig>0 then tile.dig=3 end  return x,y end)
            self.state="brush"
        elseif keys.CUSTOM_U then
            self.buffer=self:transformBuffer(function(x,y,xlen,ylen,tile) if tile.dig>0 then tile.dig=6 end  return x,y end)
            self.state="brush"
        elseif keys.CUSTOM_J then
            self.buffer=self:transformBuffer(function(x,y,xlen,ylen,tile) if tile.dig>0 then tile.dig=5 end  return x,y end)
            self.state="brush"
        elseif keys.CUSTOM_I then
            self.buffer=self:transformBuffer(function(x,y,xlen,ylen,tile) if tile.dig>0 then tile.dig=2 end  return x,y end)
            self.state="brush"
        elseif keys.CUSTOM_R then
            self.buffer=self:transformBuffer(function(x,y,xlen,ylen,tile) if tile.dig>0 then tile.dig=4 end  return x,y end)
            self.state="brush"
        elseif keys.CUSTOM_N then
            self.buffer=self:transformBuffer(function(x,y,xlen,ylen,tile) tile.dig = noise_rng:drandom()< .40 and 1 or 0; return x,y end)
            self.state="brush"
        end
    end

    if keys.LEAVESCREEN then
        self:dismiss()
    elseif self:propagateMoveKeys(keys) then
        return
    end
end

if not (dfhack.gui.getCurFocus():match("^dwarfmode/Default") or dfhack.gui.getCurFocus():match("^dwarfmode/Designate") or dfhack.gui.getCurFocus():match("^dwarfmode/LookAround"))then
    qerror("This screen requires the main dwarfmode view or the designation screen")
end

local list = StamperUI{state=_G.stamper_saved_buffer and "brush" or "mark", blink=false,cull=true}
list:show()