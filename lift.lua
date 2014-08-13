require 'utils'

Lift = {}
Lift.__index = Lift
Lift.n = 1

function Lift.create(game,angle)
    local l = {}
    setmetatable(l,Lift)
    l.game = game
    l.bottom = 0.131
    l.top = 0.283
    l.height = l.bottom
    l.angle = angle
    l.data = { position=Utils.getXY({l.height,l.angle},game.data.pluto.position),rotation=angle,
               drawable=game.assets.lift,layer=2,offset={0.5,1} }
    game.data["lift_"..Lift.n] = l.data
    game.logic["lift_"..Lift.n] = l
    l.ascending = false
    l.moving = false
    l.speed = 0
    l.waitingtodescend = false
    l.descendtime = 0
    Lift.n = Lift.n + 1
    return l
end

function Lift:update()
    self:move()
    if self.waitingtodescend and love.timer.getTime() > self.descendtime then
        self:descend(0.15)
        self.waitingtodescend = false
    end
end

function Lift:ascend(speed)
    self.moving = true
    self.ascending = true
    self.speed = speed
end

function Lift:descend(speed)
    self.moving = true
    self.ascending = false
    self.speed = speed
end

function Lift:move()
    if self.moving then
        local movedist = self.speed*love.timer.getDelta()
        if self.ascending then
            if self.height > self.top then
                self:setPos(self.top,self.angle)
                self.moving = false
                self.waitingtodescend = true
                self.descendtime = love.timer.getTime()+1.5
            else
                self:setPos(self.height+movedist,self.angle)
            end
        else
            if self.height < self.bottom then
                self:setPos(self.bottom,self.angle)
                self.moving = false
            else
                self:setPos(self.height-movedist,self.angle)
            end
        end
    end
end

function Lift:setPos(height,angle)
    self.height = height
    self.angle = angle
    self.data.position=Utils.getXY({height,angle},self.game.data.pluto.position)
    self.data.rotation=angle
end
