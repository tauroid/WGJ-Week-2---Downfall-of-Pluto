Core = {}
Core.primetime = 0.6
Core.ontime = 1
Core.laserspacing = 2
Core.nextlaser = love.timer.getTime()+math.random()*Core.laserspacing
Core.laserson = {false,
                 false,
                 false,
                 false,
                 false,
                 false}
Core.lasersprimed = {false,
                     false,
                     false,
                     false,
                     false,
                     false}

Core.lasertimes = {0,0,0,0,0,0}
Core.angles = {0.333,0.989,2.13,3.1,-2.263,-1.242}

function Core:assign(game)
    self.game = game
    self.game.logic.core = self
end

function Core:update()
    local time = love.timer.getTime()

    if time > self.nextlaser then
        local laser = math.random(1,6)
        if not self.laserson[laser] then
            self.lasertimes[laser] = time
            self.lasersprimed[laser] = true
            self.laserson[laser] = true
            self.game.data["crystal"..laser].drawable = self.game.assets["crystals.crystal"..laser.."_glow"]
            self.nextlaser = love.timer.getTime()+math.random()*self.laserspacing
        end
    end


    for i=1,6 do
        if self.lasersprimed[i] and time-self.lasertimes[i] > self.primetime then
            self.lasersprimed[i] = false
            self.game.data["crystal"..i].drawable = self.game.assets["crystals.crystal"..i.."_laser"]
        elseif self.laserson[i] and not self.lasersprimed[i]
                and time-self.lasertimes[i] > self.primetime+self.ontime then
            self.laserson[i] = false
            self.game.data["crystal"..i].drawable = self.game.assets["crystals.crystal"..i]
        end
    end
end

