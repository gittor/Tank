
require("app.tank.global")

local FireLayer = class("FireLayer", function()
	local layer = display.newLayer("FireLayer")
	layer:setContentSize(100,100)
    return layer
end)

function FireLayer:ctor()
	local size = self:getContentSize()

	self.btn = display.newSprite("firebtn.png")
	self.btn:addTo(self)
	self.btn:setPosition(size.width/2, size.height/2)

    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouch(event.name, event.x, event.y)
    end)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(false)
 
end

function FireLayer:onTouch( name, x, y )
	if name == 'began' then
		if not self.click and not self.longtouch then
			self.btn:setScale(0.8)
			self.click = self:schedule(function()
				self:beginLongTouch()
			end, 0.1)
		end
	elseif name == 'ended' then
		self.btn:setScale(1.0)

		if self.click then

			transition.removeAction(self.click)
			self.click = nil

			self:onClick()
		end

		if self.longtouch then
			transition.removeAction(self.longtouch)
			self.longtouch = nil
		end
	elseif name == 'cancelled' then
		self.btn:setScale(1.0)

		if self.click then
			transition.removeAction(self.click)
			self.click = nil
		end

		if self.longtouch then
			transition.removeAction(self.longtouch)
			self.longtouch = nil
		end
	end

	return true
end

function FireLayer:onClick()
	self:onFire()
end

function FireLayer:beginLongTouch()
	transition.removeAction(self.click)
	self.longtouch = nil

	self.longtouch = self:schedule(function()
		self:onFire()
	end, 0.05)
end
function FireLayer:onFire()
	if not self.processing then return end

	if not global.p1 then return end

	global.p1:fire()
end

function FireLayer:onGSChanged( state )
	if state=='prepare' then
		self.processing = true
	elseif state=='dead' then
		self.processing = false
	end
end

return FireLayer


