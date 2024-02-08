Player = Object:extend()

playerAttack = {}

local SWING_SPEED = 25

local swingingSword = false
local swingDirection = {}

local attackDelayTimer = 0
local deathDelayTimer = 0

local function reset(self)
    self.health = self.maxHealth
    map.currentRoom = Room(0, 0, 0, {})
    currentLevel = 0
    deathDelayTimer = 0
    self.dead = false
end

local function handleDeath(self, dt)
    if self.health <= 0 then
        self.dead = true
    end

    if self.dead then
        if deathDelayTimer == 0 then
            enemy.dead = true
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

function attackBlocked()
    local pa = playerAttack
    local ea = enemyAttack

    return enemy:attacking() and player:attacking() and checkLineCollision(pa.x1, pa.y1, pa.x2, pa.y2, ea.x1, ea.y1, ea.x2, ea.y2)
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
            self.x = defaultPosition.x
            self.y = defaultPosition.y
        end
    end
end

function Player:new()
    self.image = love.graphics.newImage("Assets/Dagger1.png")
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    defaultPosition = {
        x = (love.graphics.getWidth() * 0.75) - (self.width * 0.75),
        y = love.graphics.getHeight() - (self.height * 0.8)
    }

    self.x = defaultPosition.x
    self.y = defaultPosition.y

    self.healthPotions = 3
    self.weaponLevel = 1
    self.attackSpeed = 0
    self.playerTimer = 0
    self.maxHealth = 200
    self.damage = 0
    self.relics = 0
    self.level = 1
    self.gold = 0
    self.exp = 0

    self.keys = {}

    self.expNeeded = self.level * 100
    self.health = self.maxHealth

    self.inventory = Inventory()
    self.stats = {}
    self.stats.open = false
    self.dead = false
end

function Player:update(dt)
    attackDelayTimer = attackDelayTimer + dt
    moveSword(self)
    handleDeath(self, dt)
    self.inventory:update(dt)
end

function Player:draw()
    if not self.dead then
        love.graphics.draw(self.image, self.x, self.y)
    end

    self:playerAttackHandler()
    self.inventory:draw()
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

function Player:giveExp()
    self.exp = self.exp + (enemy.level * 5) + 20

    if self.exp >= self.expNeeded then
        music:play(music.sfx.levelUpSFX)
        self.exp = self.exp - self.expNeeded
        self.level = self.level + 1
        self.maxHealth = (self.level * 10) + 200
        self.expNeeded = self.level * 100
    end
end

function Player:playerAttackHandler()
    if player.dead or enemy.dead then return end

    map.showMap = false

    if player:attacking() then
        if not love.mouse.isDown(1) then
            if attackDelayTimer >= self.attackSpeed then
                if attackBlocked() then
                    enemy.enemyTimer = -0.25
                    displayText("BLOCKED", 200, 40, 2, { r = 255/255, g = 0, b = 0, a = 255/255 })
                    music:play(music.sfx.blockSFX)
                elseif lineRectCollision(playerAttack.x1, playerAttack.y1, playerAttack.x2, playerAttack.y2, enemy.x, enemy.y, enemy.width, enemy.height) then
                    enemy.health = enemy.health - player.damage >= 0 and enemy.health - player.damage or 0
                    displayText(player.damage, 200, 40, 2, { r = 255/255, g = 0, b = 0, a = 255/255 })
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
    self.inventory:mousepressed(x, y, button, istouch, presses)

    if button == 1 and not enemy.dead then
        playerAttack = {}
        playerAttack.x1, playerAttack.y1 = x, y
        playerAttack.x2, playerAttack.y2 = x, y
    elseif button == 1 then
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
    if key == "h" and self.healthPotions > 0 then
        self.health = self.maxHealth
        self.healthPotions = self.healthPotions - 1
        music:play(music.sfx.drinkPotionSFX)
        music:play(music.sfx.potionHealSFX)
    elseif key == "escape" then
        ui.skipScenes = true
    elseif key == "n" then
        player.inventory:giveRandomWeapon(1, 5)
    end
end

function Player:wheelmoved(x, y)
    self.inventory:wheelmoved(x, y)
end

function Player:addKey()
    if not map.currentRoom.keyPickedUp then
        map.currentRoom.keyPickedUp = true
        music:play(music.sfx.pickupKeySFX)
        table.insert(player.keys, key)
        map.currentRoom.buttons = {}
        key = {}
    end
end

function Player:addPotion()
    player.healthPotions = player.healthPotions + 1
    music:play(music.sfx.pickupPotionSFX)
end

function Player:addRelic()
    player.relics = player.relics + 1
    music:play(music.sfx.pickupRelicSFX)
    map.currentRoom.buttons = {}

    if player.relics == 1 then
        playStory = 2
    elseif player.relics >= 10 then
        playStory = 4
    end
end

function Player:teleport()
    music:play(music.sfx.teleportSFX)
    map.currentRoom = Room(0, 0, 0, {})
    currentLevel = 0
end

function Player:heal()
    player.health = player.maxHealth
    music:play(music.sfx.healSFX)
end

function Player:openInventory()
    player.inventory.open = not player.inventory.open

    if player.inventory.open then
        music:play(music.sfx.bagOpenSFX)
    else
        music:play(music.sfx.bagCloseSFX)
    end
end

function Player:openStats()
    player.stats.open = not player.stats.open
end