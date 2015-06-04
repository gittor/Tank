
require("config")
require("cocos.init")
require("framework.init")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    display.addSpriteFrames("born.plist", "born.png")
    display.addSpriteFrames("tiles.plist", "tiles.png")
    display.addSpriteFrames("enermy.plist", "enermy.png")
    display.addSpriteFrames("enermy_blast.plist", "enermy_blast.png")
    display.addSpriteFrames("prop.plist", "prop.png")

    self:enterScene("MainScene")
end

appInstance = MyApp
return MyApp
