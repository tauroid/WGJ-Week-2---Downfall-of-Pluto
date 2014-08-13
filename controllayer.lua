require 'utils'
require 'plutonian'

ControlLayer = {}
ControlLayer.__index = ControlLayer
ControlLayer.active = nil

function ControlLayer.onMousePressed(x,y,button)
    local wwidth = love.window.getWidth()
    ControlLayer.active:_onMousePressed(x/wwidth,y/wwidth,button)
end

-- Gives control of mouse presses to itself
function ControlLayer.create(game)
    local cl = {}
    setmetatable(cl,ControlLayer)
    cl.game = game
    cl.selected = nil
    cl.ring = { drawable=game.assets.selector,position={0,0},rotation=0,offset={0.5,0.9},hidden=true,layer=3 }
    game.data.selectring = cl.ring
    game.logic.controllayer = cl
    ControlLayer.active = cl
    love.mousepressed = ControlLayer.onMousePressed
    return cl
end

function ControlLayer:update()
    if self.selected then
        if not self.selected.controller.controllable then self.ring.hidden = true end
        self.ring.position = self.selected.position
        self.ring.rotation = self.selected.rotation
    end
end

function ControlLayer:findPlutonianInRadius(position,radius)
    for k,v in pairs(game.data) do
        if v.position and k:find("plutonian") and
                Utils.vecLength({v.position[1]-position[1],v.position[2]-position[2]}) < radius then
            return v
        end
    end
    return nil
end

function ControlLayer:_onMousePressed(x,y,button)
    if button == 'l' then
        self:select(x,y)
    elseif button == 'r' and self.selected then
        print("Trying to find angle between mouse at "..x..", "..y.." and "
              ..self.game.data.pluto.position[1]..", "..self.game.data.pluto.position[2])
        local mouseangle = Utils.getAngle({x,y},self.game.data.pluto.position)
        print(mouseangle)
        self.selected.controller:setGoal(mouseangle)
    end
end

function ControlLayer:select(x,y)
    self.selected = self:findPlutonianInRadius({x,y},0.05)
    if not self.selected or not self.selected.controller.controllable then self.selected = nil end
    if self.selected == nil then self:deselect() print("Nothing found") return end
    self:update()
    self.ring.hidden = false
end

function ControlLayer:deselect()
    self.ring.hidden = true
end

