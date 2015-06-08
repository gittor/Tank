require("app.tank.global")
require("app.tank.structure")
require("app.tank.GameSprite")

local function newBullet()
	local ret = newGameSprite("tankmissile.png")

	ret.walk = function(self, grid)
		local x,y = self:getPosition()
		local rc = self:getBoundingBox()
		rc.x, rc.y = rc.x+self.speed.x, rc.y+self.speed.y
		x,y = x+self.speed.x, y+self.speed.y

		local ctr = ptToRC(x,y)

		local crash = false
		for r=ctr.r-1,ctr.r+1 do
			for c=ctr.c-1,ctr.c+1 do --9个周围矩形

				local sou = cc.rect(c*60,r*60,60,60)
				local ins = cc.rectIntersection(sou, rc)

				if ins.width>0 and ins.height>0 then

					if r<0 or r>=13 or c<0 or c>=13 then
						crash = true
					end

					local idx = r*13+c+1
					if grid[idx] and grid[idx]:on_hit(self) then
						crash = true
					end
				end

			end
		end

		self:setPosition(x, y)

		return crash
	end

	-- 返回是否击中
	ret.on_hit = function(self, bull)
		assert(self~=bull)

		local ins = cc.rectIntersection(self:bound(), bull:bound())
		if area(ins)<=0 then return false end

		assert(self.blood>0)
		-- if self.blood<=0 then return end

		self.blood = 0

		print(self.type, "on_hit")

		self:onDead(false)



		return true
	end

	ret.onDead = function( self, clean )
		if self.parent then
			self.parent:removeBullet(self)
		end
		transition.stopTarget(self)

		-- 爆炸
		-- print("bullet:onDead")
		-- assert(false)

		if clean then
			global.game_scene.gl:removeEventObserver(self)
		else
			self:runAction(cc.CallFunc:create(function()
				global.game_scene.gl:removeEventObserver(self)
			end))
		end
	end

	ret.lazyInit = function(self, arg)
		ret.type = arg.type
		ret.damage = arg.damage
		ret.speed = arg.speed
		ret.blood = 1
		ret:setPosition(arg.pos)
		assert(ret.speed and ret.damage)
		ret.logic = ret:schedule(ret.onLogic, math.max(arg.speed.x,arg.speed.y)/1000)
	end

	-- ret:setLocalZOrder(global.zBullet)
	return ret
end

local function newPlayerBullet( tank )
	local ret = newBullet("tankmissile.png")

	ret.onLogic = function( self )
		local crash = self:walk(global.game_scene.gl.grid)

		if not crash then --collision player
			crash = hitObjs( global.game_scene.gl:objs("enermy_bullet"), self )
		end

		if not crash then
			crash = hitObjs( global.game_scene.gl:objs("enermy"), self )
		end

		if crash then
			self:onDead(true)
		end
	end

	-- init
	local arg = {
		type = 'player_bullet',
		damage = global.stars>=3 and 2 or 1,
		blood = 1,
		pos = cc.p(tank:getPosition())
	}

	local speeds = {
			{ x=0, y=10 },
			{ x=10, y=0 },
			{ x=0, y=-10 },
			{ x=-10, y=0 }
		}
	arg.speed = speeds[tank.dir+1]
	if global.stars<1 then
		arg.speed.x, arg.speed.y = arg.speed.x*0.7, arg.speed.y*0.7
	end
	
	ret:lazyInit(arg)

	return ret
end

function newEnermyBullet( tank )
	local ret = newBullet(arg)

	ret.onLogic = function( self )
		local crash = self:walk(global.game_scene.gl.grid)

		if not crash then --collision player
			crash = hitObjs( global.game_scene.gl:objs("player_bullet"), self )
		end

		if not crash then
			crash = hitObjs( global.game_scene.gl:objs("player"), self )
		end

		assert(self.blood>0)
		if crash then
			self:onDead(true)
		end
	end

	-- init
	local arg = {
		type = 'enermy_bullet',
		damage = 1,
		blood = 1,
		pos = cc.p(tank:getPosition())
	}

	local speeds = {
			{ x=0, y=10 },
			{ x=10, y=0 },
			{ x=0, y=-10 },
			{ x=-10, y=0 }
		}
	arg.speed = speeds[tank.dir+1]

	ret:lazyInit(arg)

	return ret
end

function newTankBullet(tank)
	local bullet = nil
	if tank.type=='player' then
		bullet = newPlayerBullet( tank )
	elseif tank.type=='enermy' then
		bullet = newEnermyBullet( tank )
	else
		assert(false)
	end

	bullet.parent = tank

	global.game_scene.gl:addEventObserver(bullet)

	return bullet
end
