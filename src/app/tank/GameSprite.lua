

function newGameSprite(sprite_name)
	ret = display.newSprite(sprite_name)

	-- ret.onEventChanged = function( self, event )
	-- 	print("onEventChanged", event.type, event.value, self.type, self.name)
	-- end

	ret.delayRun = function(self, fun)
		self:runAction(cc.CallFunc:create(fun))
	end

	-- getBoundingBox不准确(有小数)
	ret.bound = function(self)
		local rc = self:getBoundingBox()
		rc.x,rc.y = math.modf(rc.x+0.5), math.modf(rc.y+0.5)
		rc.width,rc.height = math.modf(rc.width+0.5), math.modf(rc.height+0.5)
		return rc
	end

	-- 返回是否可以行走
	ret.on_collision = function(self, who, rc_to)
		return false
	end

	-- 返回是否产生碰撞
	ret.on_hit = function( self, bullet )
		return false
	end

	-- 
	ret.type = 'none'
	return ret
end






