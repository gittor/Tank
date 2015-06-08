require("app.tank.structure")
require("app.tank.global")
require("app.tank.map")
-- require("LayerEx")

local CtrlLayer = class("CtrlLayer", function()
	-- local layer = display.newColorLayer(cc.c4b(128,128,128,100))
	local layer = display.newLayer("CtrlLayer")
	-- layer:setContentSize(100,100)
    return layer
end)

function CtrlLayer:ctor()

	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if not self.processing then return false end

		local left_pts = {}
		local right_pts = {}
		for k,v in pairs(event.points) do
			if v.x<display.cx then
				left_pts[#left_pts+1] = v
			else
				right_pts[#right_pts+1] = v
			end
		end


		self:onTouchLeft(event.name, left_pts)
		self:onTouchRight(event.name, right_pts)

	 	return true

    end)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(false)
    self:setTouchMode(cc.TOUCHES_ALL_AT_ONCE)

end


function CtrlLayer:onGSChanged( state )
	if state=='prepare' then
		self.processing = true
	elseif state=='dead' then
		self.processing = false
	end
end

-- function CtrlLayer:onKeypad( key )
-- 	if not self.processing then return end
-- 	if global.p1 == nil then return end

-- 	if key=="59" then --space
-- 		global.p1:fire()
-- 	end
-- end

function CtrlLayer:onTouchLeft( name, pts )
	if #pts==0 then return end
	local pt = pts[1]
	if name=='began' or name=='added' then

		if self.pt_start_l == nil then
			self.pt_start_l = pt
			self.dir = nil

			self.movetank = self:schedule(function()
				self:MoveTank()
			end, 0.05)
		end

	elseif name=='moved' then
		if not self.pt_start_l then return end

		local dis = cc.pGetDistance(pt, self.pt_start_l)
		if dis>20 then
			local vec = cc.pSub(pt, self.pt_start_l)
			local angle = cc.pToAngleSelf(vec)
			angle = angle*180/math.pi
			angle = math.modf(angle)
			angle = (angle-45+360)%360

			local dir = math.modf(angle/90)
			dir = (4-dir)%4
			self.dir = dir

			-- print("move", angle, self.dir)
		-- else
			self.pt_start_l = pt
		end

	elseif name=='ended' or name=='removed' then

		if self.movetank then
			transition.removeAction(self.movetank)
			self.movetank = nil
		end

		self.pt_start_l = nil
		self.dir = nil

	end
	
end

function CtrlLayer:onTouchRight( name, pts )
	if #pts==0 then return end

	if name=='began' or name=='added' then
		print(self.click_r, self.longtouch_r)
		if not self.click_r and not self.longtouch_r then
			self.click_r = self:schedule(function()
				self:beginLongTouchRight()
			end, 0.03)
			-- print(self.click_r)
		end

	elseif (name=='ended' or name=='removed') and #pts==1 then

		if self.click_r then

			transition.removeAction(self.click_r)
			self.click_r = nil

			self:onClickRight()

		end

		if self.longtouch_r then
			transition.removeAction(self.longtouch_r)
			self.longtouch_r = nil
		end

	elseif name == 'cancelled' then

		if self.click then
			transition.removeAction(self.click)
			self.click = nil
		end

		if self.longtouch then
			transition.removeAction(self.longtouch)
			self.longtouch = nil
		end
	end

end


function CtrlLayer:MoveTank()
	if not self.processing then return end

	if not self.dir then return end

	-- print('dir', dir)
	self:walk( self.dir )
end


function CtrlLayer:walk( new_dir )
	if global.p1==nil then return end

	local old_dir = global.p1.dir

	if new_dir~=old_dir then
		global.p1:set_dir(new_dir)
	else
		global.p1:walk(global.game_scene.gl.grid, 5)
	end
end

-- 

function CtrlLayer:onClickRight()
	-- print("onClickRight")
	self:onFire()
end

function CtrlLayer:beginLongTouchRight()
	transition.removeAction(self.click_r)
	self.click_r = nil

	self.longtouch_r = self:schedule(function()
		self:onFire()
	end, 0.05)
end

function CtrlLayer:onFire()
	if not self.processing then return end

	if not global.p1 then return end

	global.p1:fire()
end

return CtrlLayer





