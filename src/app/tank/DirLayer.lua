require("app.tank.structure")
require("app.tank.global")
require("app.tank.map")

local DirLayer = class("DirLayer", function()
	local layer = display.newColorLayer(cc.c4b(50,128,128,128))
	-- layer:setContentSize(100,100)
    return layer
end)

function DirLayer:ctor()
	local size = self:getContentSize()

	sp = display.newSprite("dirbtn.png")
	sp:addTo(self)
	:setPosition(size.width/2, size.height/2)

	self:addNodeEventListener(cc.KEYPAD_EVENT, function( event )
        return self:onKeypad(event.key)
    end)
    self:setKeypadEnabled(true)

    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    	local x,y = self:getPosition()
    	x = x+size.width/2
    	y = y+size.height/2
        return self:onTouch(event.name, event.x-x, event.y-y)
    end)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(false)

    self.moving = nil
 
end

function DirLayer:onKeypad( key )
	if not self.processing then return end
	if global.p1 == nil then return end

	if key=="59" then --space
		global.p1:fire()
	end
end

function DirLayer:onTouch( name, x, y )

	if self.moving~=nil and name=='began' then
		return false
	end

	-- began, moved, ended
	-- print (name)
	if name=='began' then
		self.moving = {
			act = self:schedule(self.MoveTank, 0.05),
			x = x,
			y = y
		}
	elseif name=='moved' then
		-- local dis = cc.pDistance(cc.p(x,y), self.pre_pos)
		-- if dis > 20 then 

		-- end

		self.moving.x = x
		self.moving.y = y
	else
		transition.removeAction(self.moving.act)
		self.moving = nil
	end

	self.pre_pos = cc.p(x,y)

	return true
end

function DirLayer:MoveTank()
	if not self.processing then return end

	local dir = self.moving.dir
	if dir==nil then
		local x,y = self.moving.x, self.moving.y

		x,y = math.modf(x), math.modf(y)
		local angle = cc.pToAngleSelf( cc.p(x,y) )
		angle = angle*180/math.pi
		angle = math.modf(angle)
		angle = (angle-45+360)%360

		dir = math.modf(angle/90)
		dir = (4-dir)%4
	end

	self:walk( dir )
end

function DirLayer:onGSChanged( state )
	if state=='prepare' then
		self.processing = true
	elseif state=='dead' then
		self.processing = false
	end
end

function DirLayer:walk( new_dir )
	if global.p1==nil then return end

	local old_dir = global.p1.dir

	if new_dir~=old_dir then
		global.p1:set_dir(new_dir)
	else
		global.p1:walk(global.game_scene.gl.grid, 5)
	end
end

return DirLayer





