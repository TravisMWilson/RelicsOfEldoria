Player = Object:extend()

playerAttack = {}

local SWING_SPEED = 25

local swingingSword = false
local swingDirection = {}

local attackDelayTimer = 0
local deathDelayTimer = 0
local waypointScrollOffset = 0

function attackBlocked()
    local pa = playerAttack
    local ea = enemyAttack

    return enemy:attacking() and player:attacking() and checkLineCollision(pa.x1, pa.y1, pa.x2, pa.y2, ea.x1, ea.y1, ea.x2, ea.y2)
end

local function reset(self)
    currentLevel = 0
    deathDelayTimer = 0

    self.health = self.maxHealth
    map.currentRoom = Room(0, 0, 0, {})
    map.currentRoom.buttons = map.currentRoom:getButtons()

    for _, button in ipairs(map.currentRoom.buttons) do
        button.visible = true
    end

    self.dead = false
    self.deaths = self.deaths + 1
end

local function handleDeath(self, dt)
    if self.health <= 0 then
        self.dead = true
    end

    if self.dead then
        if deathDelayTimer == 0 then
            enemy.dead = true
            enemy.circleAttacks = {}
            enemy.blockAttacks = {}
            music:play(music.sfx.deathLaughterSFX)
            music:play(music.sfx.deathSFX)
            map.showMap = false
        end

        deathDelayTimer = deathDelayTimer + dt

        if deathDelayTimer > 2 then
            reset(self)
        end
    end
end

local function moveSword(self)
    if swingingSword then
        local distance = getDistance(swingDirection[1], swingDirection[2])
        local direction = getDirection(swingDirection[1], swingDirection[2])
        local speed = distance / SWING_SPEED

        self.x = self.x + direction.x * speed
        self.y = self.y + direction.y * speed

        if self.x >= swingDirection[2].x - speed
        and self.x <= swingDirection[2].x + speed
        and self.y >= swingDirection[2].y - speed
        and self.y <= swingDirection[2].y + speed then
            swingingSword = false
            self.x = self.defaultPosition.x
            self.y = self.defaultPosition.y
        end
    end
end

function Player:new()
    self.image = love.graphics.newImage("Assets/Dagger1.png")
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    self.defaultPosition = {
        x = (love.graphics.getWidth() * 0.75) - (self.width * 0.75),
        y = love.graphics.getHeight() - (self.height * 0.8)
    }

    self.x = self.defaultPosition.x
    self.y = self.defaultPosition.y

    self.tutorialNumber = 1
    self.enemiesKilled = 0
    self.healthPotions = 3
    self.chestsLooted = 0
    self.weaponLevel = 1
    self.attackSpeed = 0
    self.playerTimer = 0
    self.maxHealth = 200
    self.totalGold = 0
    self.damage = 0
    self.relics = 0
    self.deaths = 0
    self.level = 1
    self.gold = 0
    self.exp = 0
    
    self.expNeeded = self.level * 100
    self.gameStartedTime = os.time()
    self.health = self.maxHealth

    self.inventory = Inventory()
    self.statsMenu = StatsMenu()

    self.waypoints = { 0 }
    self.waypointDisplay = {}
    self.bossesDead = { 0 }

    self.listenedToOpeningScene = false
    self.currentTutorialAutdio = love.audio.newSource("SFX/Tutorial1Voice.wav", "static")
    self.playingTutorial = false
    self.dead = false
end

function Player:update(dt)
    attackDelayTimer = attackDelayTimer + dt
    moveSword(self)
    handleDeath(self, dt)

    if #self.waypointDisplay == 0 then
        self.inventory:update(dt)
    end
end

function Player:draw()
    if not self.dead then
        love.graphics.draw(self.image, self.x, self.y)
    end

    self:playerAttackHandler()

    setColor(1, 1, 1, 1)

    if #self.waypointDisplay > 0 then
        for i, point in ipairs(self.waypointDisplay) do
            point:draw((point.height * (i - 1)) + waypointScrollOffset)
        end
    else
        self.inventory:draw()
        self.statsMenu:draw()
    end
end

function Player:attacking()
    return playerAttack.x1 and playerAttack.y1 and playerAttack.x2 and playerAttack.y2
end

function Player:swingSword(swingLine)
    swingDirection = { 
        { x = swingLine.x1, y = swingLine.y1 },
        { x = swingLine.x2, y = swingLine.y2 }
    }

    self.x = swingLine.x1
    self.y = swingLine.y1

    swingingSword = true
end

function Player:isSwinging()
    return swingingSword
end

function Player:updateExp()
    while self.exp >= self.expNeeded do
        music:play(music.sfx.levelUpSFX)
        self.exp = self.exp - self.expNeeded
        self.level = self.level + 1
        self.maxHealth = (self.level * 10) + 200
        self.expNeeded = self.level * 100
    end
end

function Player:giveExp()
    self.exp = self.exp + (enemy.level * 5) + 20
    self.enemiesKilled = self.enemiesKilled + 1
    self:updateExp()
end

function Player:playerAttackHandler()
    if player.dead or enemy.dead then return end

    map.showMap = false

    if player:attacking() then
        if not love.mouse.isDown(1) then
            if attackDelayTimer >= self.attackSpeed then
                if attackBlocked() then
                    enemy.enemyTimer = -0.25
                    table.insert(textInstances, DisplayText("BLOCKED", 200, 40, 2, { r = 255/255, g = 0, b = 0, a = 255/255 }))
                    music:play(music.sfx.blockSFX)
                elseif lineRectCollision(playerAttack.x1, playerAttack.y1, playerAttack.x2, playerAttack.y2, enemy.x, enemy.y, enemy.width, enemy.height) then
                    enemy.health = enemy.health - player.damage >= 0 and enemy.health - player.damage or 0
                    table.insert(textInstances, DisplayText(player.damage, 200, 40, 2, { r = 255/255, g = 0, b = 0, a = 255/255 }))
                    music:play(music.sfx.swordSwingSFX)
                    music:play(music.sfx.playerHitEnemySFX)

                    if enemy.health <= 0 then
                        map.showMap = true
                        music:play(music.sfx.enemyDieSFX)
                    end
                end

                if playerAttack.x1 ~= playerAttack.x2 then
                    player:swingSword(playerAttack)
                end

                attackDelayTimer = 0
            end

            playerAttack = {}
            self.playerTimer = 0
        else
            setColor(0, 255/255, 0, 200/255)
            love.graphics.setLineWidth(5)
            love.graphics.line(playerAttack.x1, playerAttack.y1, playerAttack.x2, playerAttack.y2)
            resetColor()
        end
    end
end

function Player:mousepressed(x, y, button, istouch, presses)
    if self.inventory.open then
        self.inventory:mousepressed(x, y, button, istouch, presses)
    elseif #self.waypointDisplay > 0 then
        for _, point in ipairs(player.waypointDisplay) do
            point:mousepressed(x, y, button, istouch, presses)
        end
    end

    if button == 1 and not enemy.dead then
        playerAttack = {}
        playerAttack.x1, playerAttack.y1 = x, y
        playerAttack.x2, playerAttack.y2 = x, y
    elseif button == 1 and not self.inventory.open then
        for _, clickArea in ipairs(map.currentRoom.clickAreas) do
            if pointRectCollision(x, y, clickArea) then
                if #clickArea.parameter > 0 then
                    if clickArea.action == "goToRoom" then
                        map:goToRoom(clickArea.parameter[1])
                    end
                else
                    clickArea.action()
                end
            end
        end
    end
end

function Player:mousemoved(x, y, dx, dy, istouch)
    if love.mouse.isDown(1) and self:attacking() and not enemy.dead then
        playerAttack.x2, playerAttack.y2 = x, y
    end
end

function Player:keypressed(key)
    if key == "h" then
        self:useHealthPotion()
    elseif key == "escape" then
        if playStory ~= 0 then
            music.voice["voiceStory" .. playStory .. playStoryPart]:stop()
            player.listenedToOpeningScene = true
            playStory = 0
            playStoryPart = 1
        end
        
        if player.playingTutorial then
            player.playingTutorial = false
            player.currentTutorialAutdio:stop()
        end
    end
end

function Player:wheelmoved(x, y)
    self.inventory:wheelmoved(x, y)

    if #self.waypointDisplay > 0 then
        local minX = (love.graphics:getWidth() / 2) - (self.waypointDisplay[1].width / 2)
        local maxX = minX + self.waypointDisplay[1].width
    
        if love.mouse.getX() > minX and love.mouse.getX() < maxX then
            if y > 0 then
                waypointScrollOffset = waypointScrollOffset + 20
    
                if waypointScrollOffset > 0 then
                    waypointScrollOffset = 0
                end
            elseif y < 0 then
                waypointScrollOffset = waypointScrollOffset - 20
            end
        end
    end
end

function Player:addKey()
    if not map.currentRoom.keyPickedUp then
        map.currentRoom.keyPickedUp = true
        music:play(music.sfx.pickupKeySFX)

        local keyNumber = map.currentRoom.buttons[1].filePath:match("(%d+)")

        table.insert(player.inventory.items, InventoryItem("Key", keyNumber, currentLevel))
        map.currentRoom.buttons = {}
        saveData()
    end
end

function Player:addPotion()
    player.healthPotions = player.healthPotions + 1
    music:play(music.sfx.pickupPotionSFX)
    map.currentRoom.buttons = {}
end

function Player:addRelic()
    player.relics = player.relics + 1
    music:play(music.sfx.pickupRelicSFX)
    map.currentRoom.buttons = {}
    saveData()

    if player.relics == 1 then
        playStory = 2
    elseif player.relics >= 10 then
        playStory = 4
    end
end

function Player:addTeleport()
    local levelAlreadyAdded = false

    for i, v in ipairs(player.waypoints) do
        if v == currentLevel then
            levelAlreadyAdded = true
        end
    end
    
    if not levelAlreadyAdded then
        music:play(music.sfx.teleportSFX)
        table.insert(player.waypoints, currentLevel)
        map.currentRoom.teleportDiscovered = true
        map.currentRoom.buttons[1].image = love.graphics.newImage("Assets/TeleportShrineB.png")
        saveData()
    elseif #player.waypointDisplay == 0 then
        music:play(music.sfx.teleportSFX)
        player.waypointDisplay = {}

        for _, point in ipairs(player.waypoints) do
            table.insert(player.waypointDisplay, Waypoint(point))
        end
    else
        music:play(music.sfx.teleportCancelSFX)
        player.waypointDisplay = {}
    end
end

function Player:teleport(level)
    music:play(music.sfx.buttonPressSFX)
    player.waypointDisplay = {}
    currentLevel = level
    map:generate(currentLevel)

    if currentLevel == 0 then
        map.currentRoom = Room(0, 0, 0, {})
        player.health = player.maxHealth

        for _, button in ipairs(map.currentRoom.buttons) do
            button.visible = true
        end

        map.showMap = false
    else
        for _, row in pairs(map.dungeonMap) do
            for _, room in pairs(row) do
                if room ~= ROOM_TYPES.none then
                    if room.type == ROOM_TYPES.teleport then
                        map:goToRoom(room)
                        break
                    end
                end
            end
        end

        map.showMap = true
    end

    music:play(music.sfx.teleportCastSFX)
end

function Player:useHealthPotion()
    if player.health ~= player.maxHealth then
        if player.healthPotions > 0 then
            self.health = self.maxHealth
            self.healthPotions = self.healthPotions - 1
            music:play(music.sfx.drinkPotionSFX)
            music:play(music.sfx.potionHealSFX)
        else
            music.sfx.noPotionsVoiceSFX:play()
        end
    else
        music.sfx.alreadyFullHealthVoiceSFX:play()
    end
end

function Player:heal()
    if not map.currentRoom.healingShrineUsed then
        if player.health ~= player.maxHealth then
            player.health = player.maxHealth
            music:play(music.sfx.healSFX)
            map.currentRoom.healingShrineUsed = true
            map.currentRoom.buttons[1].image = love.graphics.newImage("Assets/HealingShrineB.png")
        else
            music.sfx.alreadyFullHealthVoiceSFX:play()
        end
    else
        music.sfx.powerUsedUpVoiceSFX:play()
    end
end

function Player:openInventory()
    player.inventory.open = not player.inventory.open

    if player.inventory.open then
        music:play(music.sfx.bagOpenSFX)
    else
        if player.inventory.sellingMode then
            player.inventory.sellingMode = false
            music.sfx.merchantPartingSFX:play()
            saveData()
        end

        music:play(music.sfx.bagCloseSFX)
    end
end

function Player:openStats()
    player.statsMenu.open = not player.statsMenu.open

    if player.statsMenu.open then
        player.statsMenu.characterCount = 0
        music:play(music.sfx.skillOpenSFX)
    else
        music:play(music.sfx.skillCloseSFX)
    end
end

function Player:playTutorial()
    player.playingTutorial = true
    player.currentTutorialAutdio:play()
end

function Player:openShop()
    if not player.inventory.sellingMode then
        player.inventory.sellingMode = true
        player.inventory.open = true
        music.sfx.merchantGreetingSFX:play()
    end
end
