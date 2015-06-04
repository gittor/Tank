-- require("app.tank.Structure")
require("app.tank.map")
require("app.tank.global")

local StageScene = class("StageScene", function()
    return display.newScene("StageScene")
end)


function StageScene:ctor()
	-- local button_off = -display.height/4
    self.cur_stage = 1

    self.stage = newButton("stage 1", function()
        self.cur_stage = self.cur_stage+1
        if self.cur_stage>#map then self.cur_stage=1 end

        self.stage:setButtonLabel("normal", cc.ui.UILabel.new({
            UILabelType = 2,
            text = string.format("stage %d", self.cur_stage),
            size = 36
        }))
        :setButtonLabel("pressed", cc.ui.UILabel.new({
            UILabelType = 2,
            text = string.format("stage %d", self.cur_stage),
            size = 34
        }))
    end)
    -- :align(display.CENTER, display.cx, display.cy)
    :addTo(self)

    newButton("开始游戏", function()
        global.cur_stage = self.cur_stage
        global.lifes = 2
        global.stars = 0
        global.totalScore = 0
        global.levelScore = 0
        app:enterScene("GameScene")
    end)
    :align(display.CENTER, display.cx, display.cy-70)
    :addTo(self)
end

function StageScene:onEnter()
end

function StageScene:onExit()
end

return StageScene
