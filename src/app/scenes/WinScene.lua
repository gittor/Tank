require("app.tank.structure")
require("app.tank.map")
require("app.tank.global")


local WinScene = class("WinScene", function()
    return display.newScene("WinScene")
end)


function WinScene:ctor()
   newButton(string.format("stage %d", global.cur_stage), function()
        global.cur_stage = global.cur_stage+1
        if global.cur_stage > map:size() then
            app:enterScene("MainScene")
        else
            app:enterScene("GameScene")
        end
   end)
   :addTo(self)
   :align(display.CENTER, display.cx, display.height/4)
end

function WinScene:onEnter()

end

function WinScene:onExit()

end

return WinScene
