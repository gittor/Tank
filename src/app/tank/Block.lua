-- require("app.tank.global")
require("app.tank.Bullet")
require("app.tank.GameSprite")

function newTile(name)
	-- print("name", name)
	local ret = newGameSprite("tile/"..name..'.png')

	-- 返回是否死亡
	function ret.on_hit(self, bullet)
		if bullet.damage>=2 then
			return true
		elseif self.name=='brick' then
			self.state = self.state+1
			return (self.state>1)
		end
		return false
	end

	-- init
	display.align(ret, display.BOTTOM_LEFT)
	ret.state = 0 --只对brick有效，是否被攻击过一次
	ret.name = name

	return ret
end

--fun
function newBlock(name)
	local ret = display.newNode()

	ret.set_state = function(self, state)
		-- print("state=", self, state)
		self.state = state
		self:refreshView()
	end

	ret.resetBlock = function(self)

		self.state = 0

		if self.name=='brick' or self.name=='iron' then
			for i=1,4 do
				self.tiles[i] = newTile(name)
			end
		else
			self.tiles[1] = newTile(name)
		end

		-- print(self.tiles[1])
		for i,v in ipairs(self.tiles) do
			v:addTo(self)
			v:align(display.BOTTOM_LEFT, math.modf((i-1)%2)*30, math.modf((i-1)/2)*30)
		end

		-- self:setNodeSize(60,60)
	end

	ret.refreshView = function(self)
		-- if self.name=='brick' or self.name=='iron' then
			local states = {    {true, true, 
								 true, true},

								 {true, false,
								 true, false,},

							 	{true, true,
							 	false, false,},

							 	{false, true,
								 false, true, },

								 {false, false,
								 true,true,}, --5

								 {true, false,
								 false, false, },
								 {false, true,
								 false, false, },
								 {false, false,
								 false, true, },
								 {false, false,
								 true, false, },

							}
			local ss = states[ ret.state+1 ]
			for i=1,4 do
				if self.tiles[i] ~= nil then
					self.tiles[i]:setVisible(ss[i])
				end
			end
		-- end
	end

	ret.roll_state = function(self)
		local tile_names = {"brick", "iron", "grass", "water", "empty"}
		local tile_state = {brick=5, iron=5, grass=1, water=1, empty=1}
		-- local index = tile_names[ ret.name ]
		local state = tile_state[ self.name ]

		-- print(ret.name, ret.state, index, state)

		self.state = self.state + 1
		if self.state >= state then
			local next_idx = 1
			for i,v in ipairs(tile_names) do
				if v==self.name then
					next_idx = (i)%5+1
				end
			end
			return {name=tile_names[ next_idx ], state=0}
		else
			self.refreshView()
			return {state=self.state}
		end
	end

	ret.on_hit = function(self, bullet)
		local rc_self = {}
		rc_self.x, rc_self.y = self:getPosition()
		rc_self.width, rc_self.height = 60, 60

		local rc_bullet = bullet:getBoundingBox()

		rc_bullet.x = rc_bullet.x - rc_self.x
		rc_bullet.y = rc_bullet.y - rc_self.y
		rc_self.x, rc_self.y  = 0, 0

		local rc = cc.rectIntersection(rc_bullet, rc_self)
		if rc.width<=0 or rc.height<=0 then return false end

		if self.name=='grass' then return false end

		if self.name=='water' then return false end

		if self.name=='symbol' then 
			if global.game_scene.gs~='dead' then
				if global.game_scene.gs~='dead' then
					self.tiles[1]:setSpriteFrame("destroy.png")
					global.game_scene:changeGS('dead')
				end
			end
			return true 
		end

		local idx = {}
		for i=0,3 do
			local rc = cc.rect(math.modf(i%2)*30, math.modf(i/2)*30, 30, 30)
			local tmp = cc.rectIntersection(rc, rc_bullet)
			if tmp.width>0 and tmp.height>0 then
				idx[#idx+1] = i+1
			end
		end

		local bullet_crash = false
		for i,v in ipairs(idx) do
			if self.tiles[v]:isVisible() then
				bullet_crash = true
				if self.tiles[v]:on_hit(bullet) then
					self.tiles[v]:setVisible(false)
				end
			end
		end
		
		return bullet_crash
	end

	ret.on_collision = function(self, who, rc )
		local rc_self = {}
		rc_self.x, rc_self.y = self:getPosition()
		rc_self.width, rc_self.height = 60, 60

		rc.x = rc.x - rc_self.x
		rc.y = rc.y - rc_self.y
		rc_self.x, rc_self.y = 0, 0

		local ins = cc.rectIntersection(rc, rc_self)
		if area(ins)<=0 then return false end

		if self.name=='grass' then return false end

		if self.name=='water' then return true end

		if self.name=='symbol' then return true end

		local idx = {}
		for i=0,3 do
			local tmp = cc.rectIntersection(cc.rect(math.modf(i%2)*30, math.modf(i/2)*30, 30, 30), rc)
			if area(tmp)>0 then
				idx[#idx+1] = i+1
			end
		end
		
		for i,v in ipairs(idx) do
			if self.tiles[v]:isVisible() then
				return true
			end
		end
		
		return false
	end

-- init
	ret.type = 'block'
	ret.tiles = {}
	ret.name = name
	ret.state = 0
	ret:setLocalZOrder(global.zBlock)
	ret:resetBlock()

	return ret
end





