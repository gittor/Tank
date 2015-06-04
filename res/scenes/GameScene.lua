-- require("app.tank.Structure")
require("app.tank.map")
require("app.tank.global")
local GameLayer = require("app.tank.GameLayer")
-- local DirLayer = require("app.tank.DirLayer")
local EnermyMgr = require("app.tank.EnermyMgr")
local PropMgr = require("app.tank.PropMgr")
local InfoLayer = require("app.tank.InfoLayer")
-- local FireLayer = require("app.tank.FireLayer")
local CtrlLayer = require("app.tank.CtrlLayer")

local GameScene = class("GameScene", function()
	global.game_scene = display.newScene("GameScene")
    return global.game_scene
end)


function GameScene:ctor()
    self.gs = 'prepare'
    -- win dead 


    self.gl = GameLayer.new()
            :addTo(self)
            :setPosition(global.layer_offset, 0)

    self.em = EnermyMgr.new()
            :addTo(self)
            :setPosition(0,0)

    self.pm = PropMgr.new()
            :addTo(self)
            :setPosition(0,0)

    self.il = InfoLayer.new()
            :addTo(self)
            :setPosition((display.width+display.height)/2, 0)

    -- self.dl = DirLayer.new()
    --         :addTo(self)
    --         :setPosition(math.max(global.layer_offset-100,0),20)

    -- self.fl = FireLayer.new()
    --         :addTo(self)
    --         :setPosition((display.width+display.height)/2, 0)

    self.cl = CtrlLayer.new()
        :addTo(self)
    
end

function GameScene:changeGS(state)

    if self.gs=='dead' then return end

    self.gs = state

    self.gl:onGSChanged(state)
    -- self.dl:onGSChanged(state)
    self.em:onGSChanged(state)
    self.pm:onGSChanged(state)
    self.il:onGSChanged(state)
    -- self.fl:onGSChanged(state)
    self.cl:onGSChanged(state)

    if state=='dead' then
        local sp = display.newSprite("over.png")
        sp:setPosition(display.cx, -30)
        local acts = {
            cc.MoveTo:create(2.0, cc.p(display.cx, display.cy)),
            cc.DelayTime:create(2),
            cc.CallFunc:create(function()
                app:enterScene("MainScene")
            end)
        }
        sp:runAction(cc.Sequence:create(acts))
        sp:addTo(self)
    elseif state=="win" then
        self:schedule(function()
            app:enterScene("WinScene")
        end, 3)
    end
end

function GameScene:onEnter()
    self:changeGS("prepare")
end

function GameScene:onExit()
    global.p1 = nil
    global.p2 = nil
    global.game_scene = nil
end

return GameScene
