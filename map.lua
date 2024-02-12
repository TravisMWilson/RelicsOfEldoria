Map = Object:extend()

currentLevel = 0

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
    if not map.showMap then return end

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
    self.lowestLevel = 0
    
    mapBackground.image = ui.images.itemBackgound
    mapBackground.width = mapBackground.image:getWidth()
    mapBackground.height = mapBackground.image:getHeight()
    mapBackground.x = love.graphics:getWidth() - mapBackground.width - 20
    mapBackground.y = 20

    for _, button in ipairs(self.currentRoom.buttons) do
        button.visible = true
    end

    self.portal = Particles(690, 220, 300, 5, 50, 0, 70, 10, 0, 0, 0.5, 2.5, 5, 0, 7, 70, "Assets/single_pixel.png")
    self.portal:setColor(73/255, 53/255, 61/255, 0.3, 73/255, 53/255, 61/255, 0.3, 73/255, 53/255, 61/255, 0)

    self.fire = Particles(515, 555, 30, 2.5, 30, 80, 0, 0, 1.5, 0, 0, 2.5, 0, 1, 0, 0, "Assets/tri_triangle.png")
    self.fire:setColor(255/255, 247/255, 168/255, 0, 244/255, 132/255, 48/255, 0.9, 244/255, 132/255, 48/255, 0)
    
    self.smoke = Particles(515, 400, 30, 3, 30, 200, 0, 0, 1.5, 0, 0.5, 5, 5, 0.2, 2, 100, "Assets/smoke.png")
    self.smoke:setColor(255/255, 141/255, 22/255, 0.3, 255/255, 255/255, 255/255, 0.5, 67/255, 67/255, 67/255, 0)

    love.math.setRandomSeed(os.time())
end

function Map:update(dt)
    if currentLevel == 0 then
        self.portal:update(dt)
        self.smoke:update(dt)
        self.fire:update(dt)
    end
end

function Map:draw()
    map.currentRoom:draw()

    if currentLevel == 0 then
        self.portal:draw()
        self.smoke:draw()
        self.fire:draw()
    end

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

    map.width = love.math.random(4, 16)
    map.height = love.math.random(4, 16)
    map.maxRooms = (map.width * map.height) * 0.75
    map.dungeonMap = {}

    local maxRooms = love.math.random(15, map.maxRooms)
    local hasTeleportRoom = false
    local hasMerchantRoom = false
    local hasHealingRoom = false
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

        if love.math.random(1, 50) == ROOM_TYPES.teleport and not hasTeleportRoom then
            map.dungeonMap[newCol][newRow] = ROOM_TYPES.teleport
            hasTeleportRoom = true
        elseif love.math.random(1, 50) == ROOM_TYPES.health and not hasHealingRoom then
            map.dungeonMap[newCol][newRow] = ROOM_TYPES.health
            hasHealingRoom = true
        end

        love.math.setRandomSeed(os.time() + currentRooms)

        if map.dungeonMap[newCol][newRow] ~= ROOM_TYPES.teleport and map.dungeonMap[newCol][newRow] ~= ROOM_TYPES.health then
            if love.math.random(1, 40) == ROOM_TYPES.chest then
                map.dungeonMap[newCol][newRow] = ROOM_TYPES.chest
            elseif love.math.random(1, 40) == ROOM_TYPES.key then
                map.dungeonMap[newCol][newRow] = ROOM_TYPES.key
            elseif love.math.random(1, 40) == ROOM_TYPES.potion then
                map.dungeonMap[newCol][newRow] = ROOM_TYPES.potion
            elseif love.math.random(1, 40) == ROOM_TYPES.merchant and not hasMerchantRoom then
                map.dungeonMap[newCol][newRow] = ROOM_TYPES.merchant
                hasMerchantRoom = true

                player.inventory.shopItems = {}

                local numberOfShopItems = love.math.random(5, 15)
            
                if love.math.random(1, 5) == 1 then
                    table.insert(player.inventory.shopItems, ShopItem("Potion", 0, 0))
                end

                for i = 1, numberOfShopItems do
                    local type, code, level = player.inventory.getRandomWeapon(currentLevel, currentLevel + 10)
                    table.insert(player.inventory.shopItems, ShopItem(type, code, level))
                end
            else
                map.dungeonMap[newCol][newRow] = roomType
            end
        end

        love.math.setRandomSeed(seed + currentRooms)

        currentRooms = currentRooms + 1
    end

    local connectedEmptySpots = findConnectedEmptySpots()
    local downStairsSpot = love.math.random(1, #connectedEmptySpots)
    local downStairsX = connectedEmptySpots[downStairsSpot][1]
    local downStairsY = connectedEmptySpots[downStairsSpot][2]

    map.dungeonMap[downStairsY][downStairsX] = ROOM_TYPES.downstairs

    printMap()
    populateRooms()
    
    love.math.setRandomSeed(os.time())
end

function Map:goUpstairs()
    music:play(music.sfx.changeLevelSFX)
    currentLevel = currentLevel - 1
    map:generate(currentLevel)

    if currentLevel == 0 then
        map.currentRoom = Room(0, 0, 0, {})
        player.health = player.maxHealth

        for _, button in ipairs(map.currentRoom.buttons) do
            button.visible = true
        end

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

    if currentLevel > map.lowestLevel then
        map.lowestLevel = currentLevel
    end

    map.showMap = true
    map:generate(currentLevel)
    map:goToRoom(map.upstairsRoom)
end

function Map:goToRoom(room)
    player.waypointDisplay = {}
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
    elseif map.currentRoom.type == ROOM_TYPES.chest then
        local chestNumber = map.currentRoom.buttons[1].filePath:match("(%d+)")

        if not map.currentRoom.chest.isOpened then
            map.currentRoom.buttons[1].image = love.graphics.newImage("Assets/Chest" .. chestNumber .. "a.png")
        else
            map.currentRoom.buttons[1].image = love.graphics.newImage("Assets/Chest" .. chestNumber .. "b.png")
        end
    elseif map.currentRoom.type == ROOM_TYPES.teleport then
        for _, waypoint in ipairs(player.waypoints) do
            if waypoint == currentLevel then
                map.currentRoom.teleportDiscovered = true
            end
        end

        if not map.currentRoom.teleportDiscovered then
            map.currentRoom.buttons[1].image = love.graphics.newImage("Assets/TeleportShrineA.png")
        else
            map.currentRoom.buttons[1].image = love.graphics.newImage("Assets/TeleportShrineB.png")
        end
    elseif map.currentRoom.type == ROOM_TYPES.health then
        if not map.currentRoom.healingShrineUsed then
            map.currentRoom.buttons[1].image = love.graphics.newImage("Assets/HealingShrineA.png")
        else
            map.currentRoom.buttons[1].image = love.graphics.newImage("Assets/HealingShrineB.png")
        end
    end
end

function Map:openChest()
    if not map.currentRoom.chest.isOpened then
        if #player.inventory.items < 20 then
            local useKey = false
            local hasKey = false

            for k, v in ipairs(player.inventory.items) do
                if v.level >= currentLevel and v.type == "Key" then
                    useKey = v
                    table.remove(player.inventory.items, k)
                    break
                elseif v.type == "Key" then
                    hasKey = true
                end
            end

            if useKey then
                music:play(music.sfx.chestOpenSFX)
                map.currentRoom.chest.isOpened = true

                local chestNumber = map.currentRoom.buttons[1].filePath:match("(%d+)")
                map.currentRoom.buttons[1].image = love.graphics.newImage("Assets/Chest" .. chestNumber .. "b.png")
            elseif hasKey then
                music.sfx.needBetterKeyVoiceSFX:play()
            else
                music:play(music.sfx.noKeySFX)
            end
        else
            music.sfx.inventoryAlreadyFullVoiceSFX:play()
        end
    elseif map.currentRoom.chest.isOpened and not map.currentRoom.chest.isLooted then
        if #player.inventory.items < 20 then
            music:play(music.sfx.lootChestSFX)
            map.currentRoom.chest.isLooted = true
            player.chestsLooted = player.chestsLooted + 1

            local goldIncrease = love.math.random((currentLevel * 5) + 100, (currentLevel * 10) + 300)
            player.gold = player.gold + goldIncrease
            player.totalGold = player.totalGold + goldIncrease
            
            player.inventory:giveRandomWeapon(currentLevel + 2, currentLevel + 6)
        else
            music.sfx.inventoryAlreadyFullVoiceSFX:play()
        end
    else
        music:play(music.sfx.noKeySFX)
    end
end

function Map:mousepressed(x, y, button, istouch, presses)
    if enemy.dead then
        map.currentRoom:mousepressed(x, y, button, istouch, presses)
    end
end