require("app.tank.structure")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:addButton(text, fun)
	return newButton(text, fun):addTo(self)
end
function MainScene:ctor()
	local button_off = -display.height/4
    self:addButton('单人游戏', function()
    	app:enterScene("StageScene")
    end)
    :align(display.CENTER, display.cx, display.cy+button_off+36*1.5)

    -- self:addButton('button2', function()

    -- end)
    -- :align(display.CENTER, display.cx, display.cy+button_off)

    -- self:addButton('button3', function()
    -- 	app:enterScene("EditorScene")
    -- end)
    -- :align(display.CENTER, display.cx, display.cy+button_off-36*1.5)

end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
