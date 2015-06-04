require("app.tank.GameSprite")
require("app.tank.structure")
require("app.tank.prop")


function newTankPlayer(png, pos)
	local ret = newGameSprite(png)
	
	ret.set_dir = function(self, dir)
		if self.dir==dir then return end

		self.dir = dir
		self:setRotation(dir*90)

		local bd = 15
		local x,y = self:getPosition()
		if x%bd~=0 then 
			local i,p = math.modf(x/bd)
			x = i*bd
			if p>0.5 then x = x+bd end
		end
		if y%bd~=0 then 
			local i,p = math.modf(y/bd)
			y = i*bd
			if p>0.5 then y = y+bd end
		end

		self:setPosition(x,y)
	end

	ret.walk = function(self, grid, lenth)

		local x,y = self:getPosition()

		if self.dir==0 then y = y+lenth
		elseif self.dir==1 then x=x+lenth
		elseif self.dir==2 then y=y-lenth
		elseif self.dir==3 then x=x-lenth
		end

		local can = true

		local rc = cc.rect(x-30,y-30,60,60)
		local ctr = ptToRC(x, y)
		local objs = {}
		for r=ctr.r-1,ctr.r+1 do
			for c=ctr.c-1,ctr.c+1 do --9个周围矩形

				local sou = cc.rect(c*60,r*60,60,60)
				local ins = cc.rectIntersection(sou, rc)

				if ins.width>0 and ins.height>0 then

					if r<0 or r>=13 or c<0 or c>=13 then
						can = false
					end

					local idx = r*13+c+1
					if grid[idx] and grid[idx]:on_collision( self, clone(rc) ) then
						can = false
					end
				end

				if not can then break end
			end
		end
		if not can then return end

		can = collisionObjs( global.game_scene.gl:objs('player'), self, clone(rc) )
		if not can then return end

		can = collisionObjs( global.game_scene.gl:objs('enermy'), self, clone(rc) )
		if not can then return end

		can = collisionObjs( global.game_scene.gl:objs('prop'), self, clone(rc) )

		self:setPosition(x, y)

		return true
	end

	ret.yinshen = function( self, flag )
		if self.yin_sp then
			self.yin_sp:removeSelf()
			self.yin_sp = nil
		end

		if flag then
			self.yin_sp = display.newSprite("#yin.png")
			self.yin_sp:addTo(self)
		end
	end

	ret.bullets = {}
	ret.fire = function( self )
		local maxBullet = global.stars>=2 and 2 or 1
		if #self.bullets>=maxBullet then return end

		local bullet = newTankBullet(self)

		assert(self.blood>0)
		
		self.bullets[#self.bullets+1] = bullet
	end
	ret.removeAllBullets = function( self )
		for k,v in pairs(self.bullets) do
			v.parent = nil
		end
		self.bullets = {}
	end
	ret.removeBullet = function( self, bull )
		for k,v in pairs(self.bullets) do
			if v==bull then
				v.parent = nil
				table.remove(self.bullets, k)
			end
		end
	end

	ret.on_hit = function( self, bullet )
	
		-- assert(ret.blood>0)
		if ret.blood<=0 then return false end

		if self.yin_sp then 
			return true
		end

		local ins = cc.rectIntersection( bullet:bound(), self:bound() )
		if area(ins)<=0 then return false end

		ret.blood = ret.blood - 1 --bullet.damage
		if ret.blood<=0 then

			self:removeAllBullets()

			transition.stopTarget(self)

			self:runAction( cc.CallFunc:create(function()
				self:onDead()
			end))
		end

		return true
	end

	ret.onDead = function(self)
		
		global.lifes = global.lifes - 1
		global.game_scene.il:refresh()

		if global.lifes<0 then
			global.game_scene:changeGS('dead')
		else
			global.game_scene.em:createPlayerDelay()
		end

		global.game_scene.gl:playBlast('enermy', cc.p(self:getPosition()))
		global.game_scene.gl:removeEventObserver(self)

		global.p1 = nil
		global.stars = 0
	end

	-- init
	ret.type = 'player'
	ret.name = 'player'
	ret:setPosition(pos.x+30, pos.y+30)
	ret.dir = 0 	-- 0, 1, 2, 3
	ret.blood = 1
	ret:setLocalZOrder(global.zTank)

	return ret
end

function newNormalEnermy(type, pos)
	local png = string.format("#enermy%d.png", type)
	local ret = newTankPlayer(png, pos)

	ret.onDead = function(self)
		global.game_scene.gl:playBlast( self.type, cc.p(self:getPosition()) )
		global.game_scene.gl:removeEventObserver(self)
	end

	ret.fire = function( self )
		if #self.bullets>0 then return end
		assert(self.blood>0)
		local bullet = newTankBullet(self)
		self.bullets[#self.bullets+1] = bullet
	end

	ret.autoWalk = function(self)
		local can = ret:walk(global.game_scene.gl.grid, 5)

		if not can then
			self:fire()
			self:autoTurn()
		end
	end

	ret.autoTurn = function(self)
		local new_dir = 0
		local per = math.random()*100
		if per<30 then new_dir = 2
		elseif per<50 then new_dir = 1
		elseif per<70 then new_dir = 3
		elseif per<100 then new_dir = 0
		end
		ret:set_dir(new_dir)
	end

	ret.autoFire = function(self)
		self:fire()
	end

	ret.onEventChanged = function( self, event )
		if event.type == 'prop' then 
			if event.value == 'bomb' then
				self:removeAllBullets()
				transition.stopTarget(self)
				self:runAction(cc.CallFunc:create(function()
					self:onDead()
				end))
			elseif event.value == 'timer_begin' then
				self.is_pause = true
			elseif event.value == 'timer_end' then
				self.is_pause = false
			end
		end
	end

	-- init
	local update_diff = 0.04
	if type==2 then update_diff=0.02 end
	if type==3 then ret.blood=4 end

	ret.type = 'enermy'
	ret:set_dir(2)
	
	ret.autowalk = ret:schedule(function()
		if ret.is_pause then return end
		ret:autoWalk()
	end, update_diff)

	ret.autofire = ret:schedule(function()
		if ret.is_pause then return end
		ret:autoFire()
	end, update_diff*40)
	-- end,2)

	ret.autoturn = ret:schedule(function()
		if ret.is_pause then return end
		ret:autoTurn()
	end, update_diff*150)

	if global.game_scene.pm.timer then
		ret.is_pause = true
	end

	ret.name = 'enermy'..global.game_scene.em.remain_enermy
	return ret
end

function newPropEnermy(type, pos)
	local ret = newNormalEnermy(type,pos)

	ret.on_hit = function( self, bullet )

		local ins = cc.rectIntersection( bullet:bound(), self:bound() )
		if area(ins)<=0 then return false end

		assert(ret.blood>0)

		if self.tint then
			createRandProp()
			transition.removeAction(self.tint)
			self:setColor(cc.c3b(255,255,255))
			self.tint = nil
		end

		ret.blood = ret.blood - 1 --bullet.damage
		if ret.blood<=0 then

			self:removeAllBullets()

			transition.stopTarget(self)

			self:runAction( cc.CallFunc:create(function()
				self:onDead()
			end))
		end

		return true
	end

	ret.onDead = function(self)
		global.game_scene.gl:playBlast( self.type, cc.p(self:getPosition()) )
		global.game_scene.gl:removeEventObserver(self)
	end

	-- init
	local acts = {
		cc.TintTo:create(0.5, 255,0,0),
		cc.TintTo:create(0.5, 255,255,255),
	}
	ret.tint = ret:runAction( cc.RepeatForever:create( cc.Sequence:create(acts) ) )

	return ret
end
