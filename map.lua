Map = Object:extend()

currentLevel = 0
key = {}

local mapBackground = {}

local function hasConnectedRoom(row, col)
    local directions = {{ -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 }}

    for _, dir in ipairs(directions) do
        local newRow = row + dir[1]
        local newCol = col + dir[2]

        if newRow >= 1 and newRow <= map.height and newCol >= 1 and newCol <= map.width then
            if map.dungeonMap[newRow][newCol] ~= ROOM_TYPES.none then
                return true
            end
        end
    end

    return false
end

local function findConnectedEmptySpots()
    local connectedEmptySpots = {}

    for i = 1, map.height do
        for j = 1, map.width do
            if map.dungeonMap[i][j] == ROOM_TYPES.none and hasConnectedRoom(i, j) then
                table.insert(connectedEmptySpots, { j, i })
            end
        end
    end

    return connectedEmptySpots
end

local function printMap()
    for i, row in ipairs(map.dungeonMap) do
        for j, roomType in ipairs(row) do
            io.write(roomType .. " ")
        end

        io.write("\n")
    end

    io.write("\n")
end

local function getAdjacentRooms(row, col)
    local directions = {{ -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 }}
    local adjacentRooms = {}

    for _, dir in ipairs(directions) do
        local newRow = row + dir[1]
        local newCol = col + dir[2]

        if newRow >= 1 and newRow <= map.height and newCol >= 1 and newCol <= map.width then
            if map.dungeonMap[newRow][newCol] ~= ROOM_TYPES.none then
                table.insert(adjacentRooms, { newRow, newCol })
            end
        end
    end

    return adjacentRooms
end

local function populateRooms()
    for i = 1, map.height do
        for j = 1, map.width do
            if map.dungeonMap[i][j] ~= ROOM_TYPES.none then
                local adjacentRooms = getAdjacentRooms(i, j)
                local roomType = map.dungeonMap[i][j]

                map.dungeonMap[i][j] = Room(i, j, roomType, adjacentRooms)

                if roomType == ROOM_TYPES.upstairs then
                    map.upstairsRoom = map.dungeonMap[i][j]
                elseif roomType == ROOM_TYPES.downstairs then
                    map.downstairsRoom = map.dungeonMap[i][j]
                end
            end
        end
    end
end

local function discoverRooms()
    map.currentRoom.discovered = true
    map.currentRoom.searched = true
    
    for k, adjacentRoom in ipairs(map.currentRoom.adjacentRooms) do
        map.dungeonMap[adjacentRoom[1]][adjacentRoom[2]].discovered = true
    end
end

local function roomIsClose(room1, room2)
    local rowDiff = math.abs(room1.row - room2.row)
    local colDiff = math.abs(room1.col - room2.col)

    return rowDiff <= 3 and colDiff <= 3
end

local function setMapClickAreas()
    if map.showMap then
        local tileSize = 20
        local originX = (love.graphics:getWidth() - 86) - (map.currentRoom.col * tileSize) - (tileSize * 1.5)
        local originY = 92 - (map.currentRoom.row * tileSize) + (tileSize / 2)

        for i, row in ipairs(map.dungeonMap) do
            for j, room in ipairs(row) do
                if room ~= ROOM_TYPES.none then
                    local roomX = originX + (j * tileSize)
                    local roomY = originY + (i * tileSize)

                    if room ~= map.currentRoom and room.discovered and roomIsClose(map.currentRoom, room) then
                        if not room.searched then
                            table.insert(map.currentRoom.clickAreas, ClickArea(roomX, roomY, tileSize - 2, tileSize - 2, "goToRoom", room))
                        elseif room.searched then
                            table.insert(map.currentRoom.clickAreas, ClickArea(roomX, roomY, tileSize - 2, tileSize - 2, "goToRoom", room))
                        end
                    end
                end
            end
        end
    end
end

function Map:new()
    love.math.setRandomSeed(0)
    self.width = love.math.random(10, 40)
    self.height = love.math.random(10, 40)
    self.maxRooms = (self.width * self.height) / 6
    self.showMap = false
    self.dungeonMap = {}
    self.upstairsRoom = nil
    self.downstairsRoom = nil
    self.currentRoom = Room(0, 0, 0, {})
    
    mapBackground.image = ui.images.itemBackgound
    mapBackground.width = mapBackground.image:getWidth()
    mapBackground.height = mapBackground.image:getHeight()
    mapBackground.x = love.graphics:getWidth() - mapBackground.width - 20
    mapBackground.y = 20
end

function Map:draw()
    map.currentRoom:draw()

    if map.showMap then
        setColor(255/255, 255/255, 255/255, 255/255)
        love.graphics.draw(mapBackground.image, mapBackground.x, mapBackground.y)
        resetColor()

        local tileSize = 20
        local originX = (love.graphics:getWidth() - 86) - (map.currentRoom.col * tileSize) - (tileSize * 1.5)
        local originY = 92 - (map.currentRoom.row * tileSize) + (tileSize / 2)

        for i, row in ipairs(map.dungeonMap) do
            for j, room in ipairs(row) do
                if room ~= ROOM_TYPES.none then
                    local roomX = originX + (j * tileSize)
                    local roomY = originY + (i * tileSize)

                    if room == map.currentRoom then
                        setColor(255/255, 159/255, 76/255, 0.8)
                        love.graphics.rectangle("fill", roomX, roomY, tileSize - 2, tileSize - 2)
                    elseif room.discovered and not room.searched and roomIsClose(map.currentRoom, room) then
                        setColor(0, 0, 0, 0.5)
                        love.graphics.rectangle("fill", roomX, roomY, tileSize - 2, tileSize - 2)
                    elseif room.discovered and room.searched and roomIsClose(map.currentRoom, room) then
                        setColor(189/255, 168/255, 148/255, 0.5)
                        love.graphics.rectangle("fill", roomX, roomY, tileSize - 2, tileSize - 2)
                    end

                    resetColor()
                end
            end
        end
    end
end

function Map:generate(seed)
    if currentLevel == 0 then return end

    love.math.setRandomSeed(seed)

    map.width = love.math.random(10, 40)
    map.height = love.math.random(10, 40)
    map.maxRooms = (map.width * map.height) / 6
    map.dungeonMap = {}

    local maxRooms = love.math.random(15, map.maxRooms)
    local currentRooms = 0

    for i = 1, map.height do
        map.dungeonMap[i] = {}

        for j = 1, map.width do
            map.dungeonMap[i][j] = ROOM_TYPES.none
        end
    end

    local upStairsX = love.math.random(1, map.width)
    local upStairsY = love.math.random(1, map.height)

    map.dungeonMap[upStairsY][upStairsX] = ROOM_TYPES.upstairs
    currentRooms = currentRooms + 1

    while currentRooms < maxRooms do
        local connectedEmptySpots = findConnectedEmptySpots()
        local roomType = love.math.random(ROOM_TYPES.empty, ROOM_TYPES.enemy)
        local roomSpot = love.math.random(1, #connectedEmptySpots)
        local newRow = connectedEmptySpots[roomSpot][1]
        local newCol = connectedEmptySpots[roomSpot][2]

        if love.math.random(1, 100) == ROOM_TYPES.chest then
            map.dungeonMap[newCol][newRow] = ROOM_TYPES.chest
        elseif love.math.random(1, 100) == ROOM_TYPES.key then
            map.dungeonMap[newCol][newRow] = ROOM_TYPES.key
        elseif love.math.random(1, 200) == ROOM_TYPES.health then
            map.dungeonMap[newCol][newRow] = ROOM_TYPES.health
        elseif love.math.random(1, 300) == ROOM_TYPES.teleport then
            map.dungeonMap[newCol][newRow] = ROOM_TYPES.teleport
        else
            map.dungeonMap[newCol][newRow] = roomType
        end

        currentRooms = currentRooms + 1
    end

    local connectedEmptySpots = findConnectedEmptySpots()
    local downStairsSpot = love.math.random(1, #connectedEmptySpots)
    local downStairsX = connectedEmptySpots[downStairsSpot][1]
    local downStairsY = connectedEmptySpots[downStairsSpot][2]

    map.dungeonMap[downStairsY][downStairsX] = ROOM_TYPES.downstairs
    printMap()
    populateRooms()
end

function Map:goUpstairs()
    music:play(music.sfx.changeLevelSFX)
    currentLevel = currentLevel - 1
    map:generate(currentLevel)

    if currentLevel == 0 then
        map.currentRoom = Room(0, 0, 0, {})
        map.showMap = false
    else
        map:goToRoom(map.downstairsRoom)
        map.showMap = true
    end
end

function Map:goDownstairs()
    if currentLevel == 0 then
        music:play(music.sfx.enterDungeonSFX)
    else
        music:play(music.sfx.changeLevelSFX)
    end

    currentLevel = currentLevel + 1
    map.showMap = true
    map:generate(currentLevel)
    map:goToRoom(map.upstairsRoom)
end

function Map:goToRoom(room)
    music:play(music.sfx.changeRoomSFX)

    for _, button in ipairs(map.currentRoom.buttons) do
        button.visible = false
    end

    map.currentRoom = room

    for _, button in ipairs(room.buttons) do
        button.visible = true
    end
    
    for i = #map.currentRoom.clickAreas, 1, -1 do
        if map.currentRoom.clickAreas[i].width == 18 then
            table.remove(map.currentRoom.clickAreas, i)
        end
    end

    map.showMap = true
    discoverRooms()
    setMapClickAreas()

    if map.currentRoom.type == ROOM_TYPES.enemy and not map.currentRoom.enemyDefeated then
        enemy = Enemy()
        enemy.dead = false
        map.currentRoom.enemyDefeated = true
    elseif map.currentRoom.type == ROOM_TYPES.key then
        key = {}
        key.level = currentLevel
    elseif map.currentRoom.type == ROOM_TYPES.chest then
        local chestNumber = map.currentRoom.buttons[1].filePath:match("(%d+)")

        if not map.currentRoom.chest.isOpened then
            map.currentRoom.buttons[1].image = love.graphics.newImage("Assets/Chest" .. chestNumber .. "a.png")
        else
            map.currentRoom.buttons[1].image = love.graphics.newImage("Assets/Chest" .. chestNumber .. "b.png")
        end
    end
end

function Map:openChest()
    if not map.currentRoom.chest.isOpened then
        if #player.inventory.items < 20 then
            local useKey = false

            for k, v in ipairs(player.keys) do
                if v.level >= currentLevel then
                    useKey = v
                    table.remove(player.keys, k)
                    break
                end
            end

            if useKey then
                music:play(music.sfx.chestOpenSFX)
                map.currentRoom.chest.isOpened = true

                local chestNumber = map.currentRoom.buttons[1].filePath:match("(%d+)")
                map.currentRoom.buttons[1].image = love.graphics.newImage("Assets/Chest" .. chestNumber .. "b.png")
            else
                music:play(music.sfx.noKeySFX)
            end
        else
            music:play(music.sfx.inventoryAlreadyFullVoiceSFX)
        end
    elseif map.currentRoom.chest.isOpened and not map.currentRoom.chest.isLooted then
        if #player.inventory.items < 20 then
            music:play(music.sfx.lootChestSFX)
            map.currentRoom.chest.isLooted = true

            player.gold = player.gold + math.random(200, 500)
            player.inventory:giveRandomWeapon(currentLevel + 3, currentLevel + 8)
        else
            music:play(music.sfx.inventoryAlreadyFullVoiceSFX)
        end
    else
        music:play(music.sfx.noKeySFX)
    end
end

function Map:mousepressed(x, y, button, istouch, presses)
    map.currentRoom:mousepressed(x, y, button, istouch, presses)
end