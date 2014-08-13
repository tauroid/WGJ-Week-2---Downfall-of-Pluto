require 'utils'

Plutonian = {}
Plutonian.__index = Plutonian
Plutonian.n = 1

-- Self inserts into game
function Plutonian.create(game)
    return Plutonian.create(game,0,0)
end

function Plutonian.create(game,height,angle,lift)
    local plt = {}
    setmetatable(plt,Plutonian)
    plt.name = "plutonian_"..Plutonian.n
    plt.game = game
    plt.lift = lift
    plt.speed = 0.4
    plt.ascendheight = 0.29
    plt.ascending = false
    plt.ascended = false
    plt.evacuated = false
    plt.controllable = false
    plt.spawntime = love.timer.getTime()
    plt.ascenddelay = 2
    plt.cityrad = 0.2
    plt.survivalperiod = 7
    plt.exposuretime = 0
    plt.cold = false
    plt.data = { position={0,0},
                 rotation=0,
                 drawable=game.assets.plutoniangroup,
                 offset={0.5,1},
                 layer=2,
                 controller=plt }
    game.data[plt.name] = plt.data
    game.logic[plt.name] = plt
    Plutonian.n = Plutonian.n + 1
    plt:setPos(height,angle)
    plt.goal = plt.angle
    return plt
end

function Plutonian:update()
    if self.ascending then self:_ascend() return end
    
    if not self.ascended and not self.ascending and self.lift.height == self.lift.bottom
            and love.timer.getTime() > self.spawntime+self.ascenddelay then
        self.ascending = true
        self.lift:ascend(0.1)
    end

    if self.ascended and not self.evacuated then
        local time = love.timer.getTime()
        if time-self.exposuretime > self.survivalperiod then
            plutonianKilled()
            self:delete()
        elseif time-self.exposuretime > self.survivalperiod-3 and not self.cold then
            self.data.drawable=self.game.assets.plutoniangroup_exposure
            self.cold = true
        end
    end

    self:checkLasers()

    local cityloc = self:getInCity()
    if cityloc then
        self:setGoal(cityloc)
        self.speed = 0.2
        self.controllable = false
        self.evacuated = true
    end

    if self:canMove() then self:move() end
end

function Plutonian:setPos(height,angle)
    self.height = height
    self.angle = angle
    self.data.position=Utils.getXY({height,angle},self.game.data.pluto.position)
    self.data.rotation=angle
end

function Plutonian:_ascend()
    if self.ascended then self.ascending = false end
    local newheight = self.height+0.1*love.timer.getDelta()
    if self.height >= self.ascendheight then
        self:setPos(self.ascendheight,self.angle)
        self.ascending = false
        self.ascended = true
        self.controllable = true
        self.exposuretime = love.timer.getTime()
    else
        self:setPos(newheight,self.angle)
    end
end

function Plutonian:setGoal(angle)
    self.goal = angle
    self.stopped = false
end

function Plutonian:move()
    local diff = (self.goal - self.angle) % (2*math.pi)
    local moveamt = self.speed*love.timer.getDelta()
    local newangle
    if diff < math.pi then
        newangle = self.angle + moveamt
        if (newangle - self.goal) % (2*math.pi) < math.pi then
            self:stop()
        else
            self:setPos(self.height,newangle)
        end
    else
        newangle = self.angle - moveamt
        if (newangle - self.goal) % (2*math.pi) > math.pi then
            self:stop()
        else
            self:setPos(self.height,self.angle - moveamt)
        end
    end
end

function Plutonian:stop()
    if self.evacuated then
        self:delete()
        plutonianSaved()
        return
    end 
    self:setPos(self.height,self.goal)
    self.stopped = true 
end

function Plutonian:delete()
    self.game.data[self.name] = nil
    self.game.logic[self.name] = nil
    self.controllable = false
end

function Plutonian:canMove()
    return not self.stopped
end

function Plutonian:getInCity()
    for k,v in pairs(self.game.data) do
        if k:find("city") then
            local cityangle = Utils.getAngle(v.position,self.game.data.pluto.position)
            if math.abs(cityangle-self.angle)%(2*math.pi) < self.cityrad then
                return cityangle
            end
        end
    end
end

function Plutonian:checkLasers()
    for i=1,6 do
        local core = self.game.logic.core
        if core.laserson[i] and not core.lasersprimed[i]
                and math.abs(core.angles[i]-self.angle)%(2*math.pi) < 0.18 then
            plutonianKilled()
            self:delete()
        end
    end
end
