require("app.tank.global")
require("app.tank.Tank")
require("app.tank.map")
-- require("app.tank.prop")

local EnermyMgr = class("EnermyMgr", function()
	return display.newNode("EnermyMgr")
end)

function EnermyMgr:onGSChanged(state)
	if state=='prepare' then

		-- enermy
		self.tank_type = map:loadTankType(global.cur_stage)
		self.check = self:schedule(function()
			self:checker()
		end, 3)

		self.remain_enermy = #self.tank_type
		self.idx_born = 0

		self.prop_enermy_cnt = rand(7,9)

		-- player
		self:createPlayer()

	elseif state=='dead' then

		transition.removeAction(self.check)

	elseif state=='win' then

		transition.removeAction(self.check)
		
	end
end

function EnermyMgr:checker()

	local active_enermy = #global.game_scene.gl:objs("enermy")
	if active_enermy>=4 then return end

	if self.remain_enermy==0 then
		
		if active_enermy==0 then
			global.game_scene:changeGS("win")
		end

		return 
	end

	self:createEnermy()

end

function EnermyMgr:createPlayer()
	local pos = global.p1_born
	self:generateTank(pos, function()
		global.p1 = newTankPlayer('p1.png', pos)
		global.game_scene.gl:addEventObserver(global.p1)
	end)
end

function EnermyMgr:createPlayerDelay()
	local acts = {
		cc.DelayTime:create(2),
		cc.CallFunc:create(function()
			self:createPlayer()
		end),
	}
	self:runAction(cc.Sequence:create(acts))
end

function EnermyMgr:createEnermy()
	local pos = cc.p(self.idx_born*6*60, 12*60)
	self:generateTank(pos, function()
		local ty = self.tank_type[#self.tank_type-self.remain_enermy+1]

		self.prop_enermy_cnt = self.prop_enermy_cnt - 1

		local enermy = nil
		if self.prop_enermy_cnt==0 then
			self.prop_enermy_cnt = rand(7,9)
			enermy = newPropEnermy(ty, pos)
		else
			enermy = newNormalEnermy(ty, pos)
		end
		global.game_scene.gl:addEventObserver(enermy)

		-- print(enermy.type, enermy.name)

		self.idx_born = (self.idx_born+1)%3
		self.remain_enermy = self.remain_enermy-1

		global.game_scene.il:refresh()
	end)
end

function EnermyMgr:generateTank(pos, fun)
	local frames = display.newFrames("born%d.png", 1, 4)
	local animation = display.newAnimation(frames, 0.4/4)
	local acts = {
		cc.Repeat:create( cc.Animate:create(animation), 3 ),
		cc.CallFunc:create( fun ),
		cc.RemoveSelf:create()
	}

	local sp = display.newSprite()
	sp:align(display.BOTTOM_LEFT, pos.x, pos.y)
    sp:runAction( cc.Sequence:create(acts) )
    sp:addTo(global.game_scene.gl)
end

return EnermyMgr