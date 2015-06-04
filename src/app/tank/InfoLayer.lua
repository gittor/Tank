require("app.tank.global")
-- require("app.tank.Tank")
-- require("app.tank.map")

local InfoLayer = class("InfoLayer", function()
	local ret = display.newColorLayer(cc:c4b(255,128,128, 128))
	ret:setContentSize(100, display.height)
	return ret
end)

function InfoLayer:refresh()
	local str = string.format("%d", global.game_scene.em.remain_enermy)
	self.enermy_count:setString(str)

	str = string.format("%d", global.lifes>=0 and global.lifes or 0)
	self.life_p1:setString(str)
end

function InfoLayer:onGSChanged( state )
	if state=='prepare' then
		self.stage:setString(global.cur_stage)
	end
end
function InfoLayer:ctor()

	-- enermy
	local sp = display.newSprite("tank2.png")
	sp:setPosition(20,display.height-30)
	sp:addTo(self)

	self.enermy_count = cc.ui.UILabel.new({
		UILabelType = 2,
		text = "20",
		size = 24
	})
	self.enermy_count:setPosition( sp:getContentSize().width+30, sp:getPositionY() )
	self.enermy_count:addTo(self)

	-- life
	sp = cc.ui.UILabel.new({
		UILabelType = 2,
		text = "lifes:",
		size = 24
	})
	sp:setPosition( 10,display.height-100 )
	sp:addTo(self)

	self.life_p1 = cc.ui.UILabel.new({
		UILabelType = 2,
		text = global.lifes,
		size = 24
	})
	self.life_p1:setPosition( sp:getContentSize().width+30, sp:getPositionY() )
	self.life_p1:addTo(self)

	-- stage
	sp = cc.ui.UILabel.new({
		UILabelType = 2,
		text = "stage:",
		size = 24
	})
	sp:setPosition( 6, display.height-200 )
	sp:addTo(self)

	self.stage = cc.ui.UILabel.new({
		UILabelType = 2,
		text = global.cur_stage,
		size = 24
	})
	self.stage:setPosition( sp:getContentSize().width+15, sp:getPositionY() )
	self.stage:addTo(self)

end

return InfoLayer
















