-- require("app.tank.global")
-- require("app.tank.Bullet")
-- require("app.tank.Block")

-- []
function rand( start, endi )
    assert(start<endi)

    local x = math.random()*1000
    x = math.modf(x)
    x = x%(endi+1-start)
    x = x+start

    return x
end

--fun
function ptInRC( point, rect )
    local ret = false

    if (point.x >= rect.x) and (point.x < rect.x + rect.width) and
       (point.y >= rect.y) and (point.y < rect.y + rect.height) then
        ret = true
    end

    return ret
end

function ptToRC( x, y )
	local r, c = math.modf(y/60), math.modf(x/60)
	if x<0 then c=-1 end
	if y<0 then y=-1 end
	return {r=r, c=c}
end

function area(rc)
    if rc.width<0 or rc.height<0 then
        return 0
    else
        return rc.width*rc.height
    end
end

-- 返回是否可以行走
function collisionObjs( objs, who, to )
    local from = who:bound()
    for k,t in pairs(objs) do
        if t~=who then

            local rc = t:bound()
            crash_to = cc.rectIntersection(rc, to)
            if area(crash_to)>0 then

                -- collision = t:on_collision(who, to)

                crash_fr = cc.rectIntersection(rc, from)

                can = area(crash_to) <= area(crash_fr)
                if not can then
                    t:on_collision(who, to)
                    return false
                end

                break
            end

        end
    end
    return true
end

-- 返回是否击中
function hitObjs( objs, who )
    local crash = false
    for k,v in pairs(objs) do
        assert(v~=who)
        if v:on_hit(who) then
            crash = true
        end
    end
    return crash
end

--fun
function newButton(text, fun)
	return cc.ui.UIPushButton.new()
        :setButtonSize(100,100)
        :onButtonClicked(fun)
        :setButtonLabel("normal", cc.ui.UILabel.new({
        	UILabelType = 2,
        	text = text,
        	size = 36
    	}))
    	:setButtonLabel("pressed", cc.ui.UILabel.new({
            UILabelType = 2,
            text = text,
            size = 34,
        }))
        :align(display.CENTER, display.cx, display.cy)
end





