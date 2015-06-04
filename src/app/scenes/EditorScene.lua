require("app.tank.structure")
require("app.MyApp")

-- grid = {}

-- offset = {x=0,y=0}

-- cur_block = {name='brick', state=0}

local EditorScene = class("EditorScene", function()
    return display.newScene("EditorScene")
end)

function EditorScene:ctor()
    grid = {}
    offset = {x=0,y=0}
    cur_block = {name='brick', state=0}
    last_block = {idx=-1, name='brick', state=0}
end

function EditorScene:resetBlock( idx, name, state )
    if grid[idx] ~= nil then
        grid[idx]:removeSelf()
        grid[idx] = nil
    end

    if name=='empty' then
        return
    end

    r,c = math.modf((idx-1)/13), math.modf((idx-1)%13)

    grid[idx] = newBlock(name)
    grid[idx]:addTo(self.layer)
    grid[idx]:align(display.BOTTOM_LEFT, c*60, r*60 )

    -- print("resetBlock",id, name, state)
    if state ~= nil then
        -- print("resetBlock:",idx, name, state, grid[idx].state)
        grid[idx]:set_state(state)
    end
end

function EditorScene:onTouch( name, x, y )
    x,y = x-offset.x, y-offset.y

    r = math.modf( y/60 )
    c = math.modf( x/60 )

    if r>=13 or c>=13 or r<0 or c<0 then return end

    idx = r*13+c+1

    if name=='moved' then
        if idx ~= last_block.idx then
            self:resetBlock(idx, last_block.name, last_block.state)
        end
    elseif name=='ended' then
        print("last_block", last_block.idx, last_block.name, last_block.state)
        if idx == last_block.idx then
            if grid[idx] then
                next = grid[idx]:roll_state()
            else
                next = {name='brick', state=0}
            end
            
            if next.name == nil then
                last_block.state = next.state
            else
                last_block.name = next.name
                last_block.state = next.state
                self:resetBlock(idx, next.name, next.state)
            end
        else -- 点击新的格子
            last_block.idx = idx
            if last_block.name ~= nil then
                self:resetBlock(idx, last_block.name, last_block.state)
            else
                assert(last_block.name~=nil)
            end
        end
    end
    return true
end

function EditorScene:onKeypad( name, key )
    -- print ('key'..name)
end
function EditorScene:onEnter()
    -- print("onEnter")
    self.layer = display.newColorLayer(cc:c4b(255,255,255, 0))
    local size = display.height--*display.contentScaleFactor;
    print('size', size)
    self.layer:setContentSize(size, size)
    offset = {x=(display.width-size)/2, y=0}
    self.layer:setPosition(offset)
    print("offsetX:", offset.x)

    self.layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouch(event.name, event.x, event.y)
    end)
    self.layer:setTouchEnabled(true)
    self.layer:setTouchSwallowEnabled(false)

    self.layer:addNodeEventListener(cc.KEYPAD_EVENT, function( event )
        return self:onKeypad(event.name, event.key)
    end)
    self.layer:setKeypadEnabled(true)

    self:addChild(self.layer)

    -- save
    cc.ui.UIPushButton.new('save.png')
        :setButtonSize(100,100)
        :onButtonClicked(function(event)
            -- 
            self:resetBlock(7, 'symbol')
            self:resetBlock(6, 'brick', 3)
            self:resetBlock(8, 'brick', 1)
            self:resetBlock(19, 'brick', 6)
            self:resetBlock(20, 'brick', 2)
            self:resetBlock(21, 'brick', 5)

            -- local file = io.open(device.writablePath..'loadmap', "a")
            -- local loadmap = file:read("number")
            -- local savemap = file:read("string")
            -- file:close()

            mapid = "x"

            local file = io.open(device.writablePath..'map_t.txt', 'w')
            file:write("map["..mapid.."]={\n")
            for i=1,169 do
                if grid[i] ~= nil then
                    line = string.format("\t[%d]={%s}\n", i, dumpBlock(grid[i]))
                    file:write(line)
                end
            end
            file:write("}")
            file:write("\n\n\n")
            file:close()

            print("saved to ", device.writablePath..'map.txt')
    
            -- app:enterScene("MainScene")
        end)
        :align(display.RIGHT_BOTTOM, display.right, display.bottom)
        :addTo(self)
end

function EditorScene:onExit()
    -- print ("exit")
end

return EditorScene
