require 'utils'

Assets = {}
Assets.__index = Assets
Assets.ext_image = {"jpg","png"}
fs = love.filesystem

function Assets.create(dir)
    local assets = {}
    setmetatable(assets,Assets)
    if not fs.isDirectory(dir) then return assets end
    assets:loadRecurseInDir(dir)
    return assets
end

function Assets:loadRecurseInDir(dir)
    self:_loadRecurseInDir("",dir)
end

function Assets:_loadRecurseInDir(relativedir,start)
    local dirpath = start.."/"..relativedir
    for k,v in ipairs(fs.getDirectoryItems(dirpath)) do
        local namepath = relativedir == "" and v or relativedir.."/"..v
        local path = start.."/"..namepath
        if fs.isDirectory(path) then
            self:_loadRecurseInDir(namepath,start)
        else
            if Utils.isInIterable(Utils.getExtension(v),Assets.ext_image) then
                self[Utils.pathToID(namepath)] = love.graphics.newImage(path)
                print("Added \""..path.."\" as \""..Utils.pathToID(namepath).."\" to assets")
            end
        end
    end
end