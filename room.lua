Room = Object:extend()

ROOM_TYPES = {
    town = 0,
    none = 0,
    upstairs = 1,
    downstairs = 2,
    empty = 3,
    enemy = 4,
    chest = 5,
    key = 6,
    health = 7,
    teleport = 8,
    potion = 9,
    merchant = 10
}

local NUM_KEY_IMAGES = 4
local NUM_CHEST_IMAGES = 2

local ROOM_LIST = {
    ["l"] = { 7, 21, 30, 41, 43, 46 },
    ["r"] = { 24, 28, 30, 42, 45, 47 },
    ["f"] = { 3, 4, 5, 6, 8, 10, 12, 13, 14, 16, 18, 22, 23, 25, 26, 29, 30, 33, 34, 37 },
    ["lr"] = { 7, 19, 30, 38, 44, 48 },
    ["lf"] = { 5, 6, 12, 13, 15, 17, 19, 20, 21, 30, 32, 35, 37, 40 },
    ["fr"] = { 5, 6, 13, 17, 19, 20, 24, 26, 30, 33, 37, 40, 47 },
    ["lfr"] = { 5, 6, 9, 11, 13, 15, 17, 19, 20, 30, 36, 37 },
    ["deadend"] = { 4, 8, 12, 27, 28, 30, 31, 39 },
    ["chest"] = { 7, 12, 27, 28, 30, 31 }
}

local ROOM_CLICK_AREAS = {
    town = { ClickArea(610, 87, 109, 223, Map.goDownstairs) },
    upstairs = { ClickArea(676, 0, 222, 102, Map.goUpstairs) },
    downstairs = { ClickArea(672, 107, 148, 154, Map.goDownstairs) }
}

local ROOM_BUTTONS = {
    chest = { Button(
        (love.graphics:getWidth() / 2) - 170,
        (love.graphics:getHeight() * 0.8) - 325,
        "Assets/Chest" .. love.math.random(1, NUM_CHEST_IMAGES) .. "a.png",
        Map.openChest
    ) },
    key = { Button(
        (love.graphics:getWidth() / 2) - 35,
        love.graphics:getHeight() * 0.8,
        "Assets/Key" .. love.math.random(1, NUM_KEY_IMAGES) .. ".png",
        Player.addKey
    ) },
    health = { Button(
        (love.graphics:getWidth() / 2) - 170,
        (love.graphics:getHeight() * 0.8) - 465,
        "Assets/HealingShrineA.png",
        Player.heal
    ) },
    teleport = { Button(
        (love.graphics:getWidth() / 2) - 175,
        (love.graphics:getHeight() * 0.8) - 465,
        "Assets/TeleportShrineA.png", 
        Player.addTeleport
    ) },
    town = {
        Button(
            133,
            218,
            "Assets/TownTeleport.png", 
            Player.addTeleport
        ),
        Button(
            love.graphics:getWidth() - 44,
            20,
            "Assets/TutorialButton.png",
            Player.playTutorial
        )
    },
    potion = { Button(
        (love.graphics:getWidth() / 2) - 35,
        (love.graphics:getHeight() * 0.8) - 110,
        "Assets/HealthPotion.png",
        Player.addPotion
    ) },
    relic = { Button(
        (love.graphics:getWidth() / 2) - 85,
        (love.graphics:getHeight() * 0.8) - 270,
        "Assets/Relic.png",
        Player.addRelic
    ) },
    merchant = { Button(
        (love.graphics:getWidth() / 2) - 238,
        (love.graphics:getHeight() * 0.8) - 500,
        "Assets/Merchant.png",
        Player.openShop
    ) }
}

local function getDoors(self)
    local doors = ""

    for _, room in pairs(self.adjacentRooms) do
        if room[1] == self.row - 1 then
            doors = doors .. "n"
        elseif room[1] == self.row + 1 then
            doors = doors .. "s"
        elseif room[2] == self.col - 1 then
            doors = doors .. "w"
        elseif room[2] == self.col + 1 then
            doors = doors .. "e"
        end
    end

    return doors
end

local function compareTables(table1, table2, bool)
    local combinedTable = {}

    for _, v in ipairs(table1) do
        if table.contains(table2, v) == bool then
            table.insert(combinedTable, v)
        end
    end
    
    return combinedTable
end

local function getRoomListType(self)
    if #self.doors == 1 then
        return "deadend"
    end

    local northDoor = self.doors:find("n")
    local southDoor = self.doors:find("s")
    local westDoor = self.doors:find("w")
    local eastDoor = self.doors:find("e")

    if northDoor and southDoor and eastDoor and westDoor then
        return "lfr"
    elseif northDoor and southDoor and eastDoor then
        return "fr"
    elseif northDoor and southDoor and westDoor then
        return "lf"
    elseif northDoor and eastDoor and westDoor then
        return "lr"
    elseif southDoor and eastDoor and westDoor then
        return "lr"
    elseif northDoor and southDoor then
        return "f"
    elseif northDoor and eastDoor then
        return "l"
    elseif northDoor and westDoor then
        return "r"
    elseif southDoor and eastDoor then
        return "r"
    elseif southDoor and westDoor then
        return "l"
    elseif eastDoor and westDoor then
        return "f"
    end

    return nil
end

local function selectBackground(self)
    if self.type == ROOM_TYPES.town then
        return ROOM_TYPES.town
    elseif self.type == ROOM_TYPES.upstairs then
        return ROOM_TYPES.upstairs
    elseif self.type == ROOM_TYPES.downstairs then
        return ROOM_TYPES.downstairs
    end

    local availableRooms = {}
    local roomListType = getRoomListType(self)

    if self.type == ROOM_TYPES.chest then
        availableRooms = compareTables(ROOM_LIST["chest"], ROOM_LIST[roomListType], true)
    else
        availableRooms = compareTables(ROOM_LIST[roomListType], ROOM_LIST["chest"], false)
    end

    return availableRooms[love.math.random(1, #availableRooms)]
end

local function getClickArea(self)
    if self.type == ROOM_TYPES.town then
        return ROOM_CLICK_AREAS.town
    elseif self.type == ROOM_TYPES.upstairs then
        return ROOM_CLICK_AREAS.upstairs
    elseif self.type == ROOM_TYPES.downstairs then
        return ROOM_CLICK_AREAS.downstairs
    else
        return {}
    end
end

function Room:getButtons()
    if self.type == ROOM_TYPES.chest then
        return ROOM_BUTTONS.chest
    elseif self.type == ROOM_TYPES.key then
        return ROOM_BUTTONS.key
    elseif self.type == ROOM_TYPES.health then
        return ROOM_BUTTONS.health
    elseif self.type == ROOM_TYPES.teleport then
        return ROOM_BUTTONS.teleport
    elseif self.type == ROOM_TYPES.merchant then
        return ROOM_BUTTONS.merchant
    elseif self.type == ROOM_TYPES.potion then
        return ROOM_BUTTONS.potion
    elseif currentLevel == 0 then
        return ROOM_BUTTONS.town
    else
        return {}
    end
end

function Room:new(row, col, type, adjacentRooms)
    self.row = row
    self.col = col
    self.type = type
    self.adjacentRooms = adjacentRooms

    self.doors = getDoors(self)
    self.background = selectBackground(self)
    self.clickAreas = getClickArea(self)
    self.buttons = self:getButtons()

    self.image = love.graphics.newImage("Assets/Background" .. self.background .. ".png")

    self.chest = {}
    self.chest.isOpened = false
    self.chest.isLooted = false

    self.healingShrineUsed = false
    self.teleportDiscovered = false
    self.enemyDefeated = false
    self.discovered = false
    self.searched = false
    self.keyPickedUp = false
end

function Room:update(dt)
    
end

function Room:draw()
    love.graphics.draw(self.image)

    for _, button in pairs(self.buttons) do
        button:draw()
    end
end

function Room:placeRelic()
    table.insert(map.currentRoom.buttons, ROOM_BUTTONS.relic[1])

    for _, button in ipairs(map.currentRoom.buttons) do
        button.visible = true
    end
end

function Room:mousepressed(x, y, button, istouch, presses)
    for _, uiButton in pairs(self.buttons) do
        uiButton:mousepressed(x, y, button, istouch, presses)
    end
end