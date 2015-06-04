require("app.tank.GameSprite")
require("app.tank.global")
require("app.tank.structure")

function newProp( type_name )
	local ret = newGameSprite('#'..type_name..'.png')

	ret.on_collision = function( self, tank )

		if tank.type ~= 'player' then return end

		if area( cc.rectIntersection( self:bound(), tank:bound() ) )<= 0 then return end

		self:delayRun(function()
			self:onDead()
		end)
	end

	ret.onDead = function(self)
		global.game_scene.pm:apply( self.name )
		global.game_scene.gl:playScore(500, cc.p(self:getPosition()))
		global.game_scene.gl:removeEventObserver(self)
	end

	-- init
	local acts = {
		cc.DelayTime:create(30),
		cc.Blink:create(3,3),
		cc.CallFunc:create(function()
			global.game_scene.gl:removeEventObserver(ret)
		end)
	}
	ret:runAction(cc.Sequence:create(acts))

	ret.type = 'prop'
	ret.name = type_name
	-- ret:setOpacity(180)

	return ret
end


function createRandProp()
	local pt_type = {"timer", "life", "star", "bomb", "yin"}
	local pt = math.random() * 10
	pt = math.modf(pt)
	pt = pt%5+1

	-- print("pt_type[pt]", pt)

	local prop = newProp( pt_type[pt] )
	local size = prop:getContentSize()

	while( true )
	do
		local r,c = math.random()*100, math.random()*100
		r = math.modf(r)%13
		c = math.modf(c)%13
		-- print("r,c", r, c)
		local block = global.game_scene.gl.grid[r*13+c+1]
		if not block or
		 (block.name~='brick' and block.name~='iron' and block.name~='water' and block.name~='symbol') or
		 block.state~=0 then
			prop:setPosition(c*60+size.width/2, r*60+size.height/2)
			break
		end
	end

	prop:setLocalZOrder(global.zProp)
	global.game_scene.gl:addEventObserver(prop)
end