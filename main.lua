require 'utils'
require 'assets'
require 'plutonian'
require 'lift'
require 'core'
require 'controllayer'

function love.load()
    game = {}
    game.assets = Assets.create("assets")
    game.logic = {}

    bg = game.assets.pluto
    pt = game.assets.plutonians
    w = love.window

    game.data = {}

    game.data.bg = { position={0,0},drawable=bg,scale={w.getWidth()/bg:getWidth(),w.getHeight()/bg:getHeight()},layer=1 }
    game.data.corebuildings = { position={0,0},scale={w.getWidth()/bg:getWidth(),w.getHeight()/bg:getHeight()},
                                drawable=game.assets.corehouses,layer=3 }
    game.data.teleporters = { position={0,0},scale={w.getWidth()/bg:getWidth(),w.getHeight()/bg:getHeight()},
                              drawable=game.assets.teleporters,layer=3 }
    game.data.liftentrances = { position={0,0},scale={w.getWidth()/bg:getWidth(),w.getHeight()/bg:getHeight()},
                               drawable=game.assets.liftentrances,layer=3 }
    for i=1,6 do
        game.data["crystal"..i] = { position={0,0},scale={w.getWidth()/bg:getWidth(),w.getHeight()/bg:getHeight()},layer=3,
                                    drawable=game.assets["crystals.crystal"..i] }
    end

    game.data.pluto = {position={0.5,0.375}}

    game.spawnbldgs = {1.571,-0.545,-3}
    game.lifts = {1.281,-0.857,-2.718}
    Lift.create(game,game.lifts[1])
    Lift.create(game,game.lifts[2])
    Lift.create(game,game.lifts[3])

    ControlLayer.create(game)
    Core:assign(game)

    game.minspawntime = 3
    game.starttime = love.timer.getTime()+2
    game.nextspawntime = game.starttime

    game.data.city1 = { position=Utils.getXY({0.29,.645},game.data.pluto.position) }
    game.data.city2 = { position=Utils.getXY({0.29,-1.793},game.data.pluto.position) }
    game.data.city3 = { position=Utils.getXY({0.29,2.574},game.data.pluto.position) }

    game.data.gameover = { position={0,0},scale={w.getWidth()/bg:getWidth(),w.getHeight()/bg:getHeight()},
                           layer=4,drawable=game.assets.gameover,hidden=true }

    game.score = 0
    game.deathcount = 0
    game.frozen = false
end

function love.update()
    if game.frozen then
        if love.mouse.isDown("l") then
            reset()
            game.frozen = false
        end
        return
    end

    local time = love.timer.getTime()
    if time > game.nextspawntime then
        local spawnindex = math.random(1,table.getn(game.spawnbldgs))
        local plt = Plutonian.create(game,0.135,game.spawnbldgs[spawnindex],game.logic["lift_"..spawnindex])
        plt:setGoal(game.lifts[spawnindex])
        game.nextspawntime = getNewSpawnTime(time)
    end
    for k,v in pairs(game.logic) do
        v:update()
    end
end

function love.draw()
    for i=1,4 do
        for k,v in pairs(game.data) do
            if v.drawable and not v.hidden and ((v.layer and v.layer == i) or (not v.layer and i == 2)) then
                local drawargs = {v.drawable,
                                  v.position and v.position[1]*w.getWidth() or 0,
                                  v.position and v.position[2]*w.getWidth() or 0,
                                  v.rotation or 0,
                                  v.scale and v.scale[1] or 1,
                                  v.scale and v.scale[2] or 1,
                                  v.offset and v.offset[1]*v.drawable:getWidth() or 0,
                                  v.offset and v.offset[2]*v.drawable:getHeight() or 0}
                love.graphics.draw(unpack(drawargs))
            end
        end
    end
--  love.graphics.print("Max time between spawns: "..(3+4*math.exp(-(love.timer.getTime()-game.starttime)/100)))
    love.graphics.printf("Score: "..game.score,0,0,200,"left",0,2)
    love.graphics.printf("Deaths: "..game.deathcount,0,35,200,"left",0,2)
end

function getNewSpawnTime(time)
    return time+1.5+math.random(1.5+4*math.exp(-(time-game.starttime)/100))
end

function plutonianSaved()
    game.score = game.score + 10 + math.floor((love.timer.getTime()-game.starttime)/10)
end

function plutonianKilled()
    game.deathcount = game.deathcount + 1
    if game.deathcount >= 3 then
        gameOver()
    end
end

function gameOver()
    game.frozen = true
    game.data.gameover.hidden = false
    for i=1,6 do
        game.logic.core.laserson[i] = false
        game.logic.core.lasersprimed[i] = false
        game.data["crystal"..i].drawable = game.assets["crystals.crystal"..i]
    end
end

function reset()
    for k,v in pairs(game.logic) do
        if k:find("plutonian") then
            v:delete()
        end
    end

    game.score = 0
    game.deathcount = 0
    game.starttime = love.timer.getTime()
    game.data.gameover.hidden = true
end
