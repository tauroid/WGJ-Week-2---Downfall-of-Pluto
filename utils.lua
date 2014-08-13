Utils = {}

function Utils.isInIterable(value,iter)
    for k,v in pairs(iter) do
        if v == value then return true end
    end
    return false
end

function Utils.getTableLength(t)
    i = 0
    for k,v in pairs(t) do i = i+1 end
    return i
end

function Utils.tail(t)
    local tail = {}
    local n = table.getn(t)
    if n <= 1 then return tail end
    for i=2,table.getn(t) do
        table.insert(tail,t[i])
    end
    return tail
end

function Utils.join(table1,table2)
    for k,v in pairs(table2) do
        if type(k) == "number" then
            table.insert(table1,v)
        else
            table1[k] = v
        end
    end
end

function Utils.getExtension(str)
    parts = Utils.split(str,'\\.')
    return parts[table.getn(parts)]
end

function Utils.split(str,sep)
    str = str..sep
    return {str:match((str:gsub("[^"..sep.."]*"..sep, "([^"..sep.."]*)"..sep)))}
end

function Utils.pathToID(path)
    local start = ""
    local parts = Utils.split(path,'/')
    local nparts = table.getn(parts)
    for i=1,nparts-1 do start = start..parts[i].."." end
    return start..Utils.split(parts[nparts],'.')[1]
end

function Utils.flatten(t)
    local flatt = {}
    for k,v in pairs(t) do
        if type(v) == "table" then
            Utils.join(flatt,Utils.flatten(v))
        else
            flatt[k] = v
        end
    end
    return flatt
end

function Utils.getAngle(position,centre)
    local anglegotten = math.atan2((position[1]-centre[1]),(centre[2]-position[2]))
    return anglegotten
end

function Utils.getPolar(position,centre)
    return {math.sqrt(math.pow(position[1]-centre[1],2)+math.pow(position[2]-centre[2],2)),
            math.atan2((position[1]-centre[1]),(centre[2]-position[2]))}
end

function Utils.getXY(polarpos,centre)
    return {centre[1]+polarpos[1]*math.sin(polarpos[2]),
            centre[2]-polarpos[1]*math.cos(polarpos[2])}
end

function Utils.vecLength(vector)
    return math.sqrt(math.pow(vector[1],2)+math.pow(vector[2],2))
end
