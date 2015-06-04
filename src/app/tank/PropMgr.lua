require("app.tank.global")
-- require("app.tank.Tank")
-- require("app.tank.map")

local PropMgr = class("PropMgr", function()
	return display.newNode("PropMgr")
end)

function PropMgr:onGSChanged(state)
	if state=='prepare' then

	elseif state=='dead' then

	elseif state=='win' then
		
	end
end

function PropMgr:apply( name )
	if name == 'life' then
		global.lifes = global.lifes + 1
		global.game_scene.il:refresh()
	elseif name=='star' then
		global.stars = global.stars + 1
	elseif name=='bomb' then
		global.game_scene.gl:notifyEvent({
			type = 'prop',
			value = 'bomb'
			})
	elseif name=='timer' then
		if self.timer~=nil then
			transition.removeAction(self.timer)
			self.timer = nil
		end

		global.game_scene.gl:notifyEvent({
			type='prop',
			value='timer_begin'
			})
		
		self.timer = self:schedule(function()
			transition.removeAction(self.timer)
			self.timer = nil
			global.game_scene.gl:notifyEvent({
				type = 'prop',
				value = 'timer_end'	
			})
		end, 15)
	elseif name=='yin' then
		assert(global.p1)

		if self.yinshen then
			transition.removeAction(self.yinshen)
			self.yinshen = nil
		end

		global.p1:yinshen(true)

		self.yinshen = self:schedule(function()
			global.p1:yinshen(false)
			transition.removeAction(self.yinshen)
			self.yinshen = nil
		end, 10)
	end
end

return PropMgr





