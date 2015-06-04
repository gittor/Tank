require("app.tank.structure")
require("app.tank.global")
require("app.tank.map")
require("app.tank.Block")

local GameLayer = class("GameLayer", function()
	local layer = display.newLayer("GameLayer")
	layer:setContentSize(display.height, display.height)
    return layer
end)

function GameLayer:ctor()
	local layer = display.newColorLayer(cc.c4b(128,0,128,255))
	:addTo(self)
	layer:setContentSize(display.height, display.height)

    self.update_list = {}

    -- self:setTouchEnabled(false)
    -- self:setTouchSwallowEnabled(false)
end

function GameLayer:initMap( level )
	-- print("load map", level)
	local tmp = map:load(level)
	-- print( tmp )

	if self.grid then
		for k,v in pairs(self.grid) do
			v:removeSelf()
		end
	end

	-- print("GameLayer.start")
	self.grid = {}
	for i,v in pairs(tmp) do
		-- print(i, v.name, v.state)
		self.grid[i] = newBlock(v.name)
		self.grid[i]:set_state(v.state)
		self.grid[i]:addTo(self)
		r,c = math.modf((i-1)/13), math.modf((i-1)%13)
		self.grid[i]:align(display.BOTTOM_LEFT, c*60, r*60)
	end
	-- print("GameLayer.start.")

	-- global.game_scene:changeGS('prepare')
end

function GameLayer:onEnter(  )
	-- global.game_scene:changeGS('prepare')
	print("GameLayer:onEnter")
end

function GameLayer:onGSChanged( state )
	if state == 'prepare' then
		
		self:initMap(global.cur_stage)

	elseif state=='dead' then

	end

	self:notifyEvent( { type='state', value=state } )
end

function GameLayer:notifyEvent(event)
	for k,list in pairs(self.update_list) do
		for k2,obj in pairs(list) do
			if obj.onEventChanged then
				obj:onEventChanged(event)
			end
		end
	end
end

function GameLayer:addEventObserver( obj )

	self.update_list[obj.type] = self.update_list[obj.type] or {}

	self:removeEventObserver(obj)

	local list = self.update_list[obj.type]
	list[#list+1] = obj
	obj:addTo(self)
end

function GameLayer:removeEventObserver( obj )
	local type = obj.type

	local list = self.update_list[type] or {}
	for k,v in pairs(list) do
		if v==obj then
			v:removeSelf()
			table.remove(list, k)
			break
		end
	end
end

function GameLayer:objs(type)
	return self.update_list[type] or {}
end

function GameLayer:playBlast( name, pos )
	local frames = display.newFrames("enermy_blast%d.png", 1, 8)
	local animation = display.newAnimation(frames, 0.03)
	local acts = {
		cc.Animate:create(animation),
		cc.RemoveSelf:create()
	}

	local sp = display.newSprite()
	sp:align(display.CENTER, pos.x, pos.y)
	sp:setLocalZOrder(global.zProp)
    sp:runAction( cc.Sequence:create(acts) )
    sp:addTo(self)
end

function GameLayer:playScore( num, pos )
	local label = cc.ui.UILabel.new({
            UILabelType = 2,
            text = "+ "..num,
            size = 24
 	})
 	label:addTo(self)
 	label:setPosition(pos)
 	label:setLocalZOrder(global.zTips)

 	local acts = {
 		cc.MoveBy:create(2, cc.p(0,100)),
 		cc.RemoveSelf:create()
 	}
 	label:runAction(cc.Sequence:create(acts))
end

return GameLayer







