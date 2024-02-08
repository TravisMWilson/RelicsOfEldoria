Enemy = Object:extend()

enemyAttack = {}

local DISTANCE_INCREMENT = 100
local TIME_INCREMENT = 0.35
local INCREMENT_MAX = 7
local NUMBER_OF_ENEMIES = 87
local NUMBER_OF_BOSSES = 11

function Enemy:new()
    self.level = math.random(currentLevel, currentLevel + 5)

    if math.random(1, 600) == 1 then
        self.isBoss = true
        self.image = love.graphics.newImage("Assets/Boss" .. math.random(1, NUMBER_OF_BOSSES) .. ".png")
        self.maxHealth = self.level * 175

        if player.relics == 9 then
            playStory = 3
        end
    else
        self.isBoss = false
        self.image = love.graphics.newImage("Assets/Enemy" .. math.random(1, NUMBER_OF_ENEMIES) .. ".png")
        self.maxHealth = self.level * 25
    end
    
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.x = (love.graphics.getWidth() * 0.5) - (self.width / 2)
    self.y = (love.graphics.getHeight() * 0.85) - (self.height / 2)

    self.health = self.maxHealth
    self.dead = true
    self.damage = 0
    self.speed = math.random(7, 20) / 10

    self.blocking = false
    self.enemyTimer = 0
    self.timeMultiplier = 1
    self.distanceMultiplier = 1

    self.healthBar = {}
    self.healthBar.image = ui.images.enemyHealthBar
    self.healthBar.width = self.healthBar.image:getWidth()
    self.healthBar.height = self.healthBar.image:getHeight()
    self.healthBar.x = (love.graphics.getWidth() * 0.5) - (self.healthBar.width / 2)
    self.healthBar.y = self.y - 100

    if self.isBoss then
        self.y = (love.graphics.getHeight() * 0.925) - (self.height / 2)
        self.healthBar.x = love.graphics.getWidth() - self.healthBar.width - 20
        self.healthBar.y = 20
    end

    self.healthIndicator = {}
    self.healthIndicator.width = 150
    self.healthIndicator.maxWidth = 150
    self.healthIndicator.height = 25
    self.healthIndicator.x = self.healthBar.x + 65
    self.healthIndicator.y = self.healthBar.y + 76
    self.healthIndicator.color = { r = 216/255, g = 36/255, b = 39/255, a = 200/255 }
end

function Enemy:update(dt)
    self.healthIndicator.width = self.healthIndicator.maxWidth * (self.health / self.maxHealth)

    if enemy:attacking() then
        local distance = getDistance(
            { x = enemyAttack.x1, y = enemyAttack.y1 },
            { x = enemyAttack.x2, y = enemyAttack.y2 }
        )
        
        if self.enemyTimer < TIME_INCREMENT * INCREMENT_MAX then
            self.timeMultiplier = math.floor(self.enemyTimer / TIME_INCREMENT) + 1
        else
            self.timeMultiplier = INCREMENT_MAX
        end

        if distance < DISTANCE_INCREMENT * INCREMENT_MAX then
            self.distanceMultiplier = math.floor(distance / DISTANCE_INCREMENT) + 1
        else
            self.distanceMultiplier = INCREMENT_MAX
        end
    else
        self.timeMultiplier = 1
        self.distanceMultiplier = 1
    end

    self.damage = self.distanceMultiplier * self.timeMultiplier

    if self.health <= 0 and not self.dead then
        self.dead = true
        enemyAttack = {}
        displayText("Enemy Died", 200, 40, 2, { r = 255/255, g = 0, b = 0, a = 255/255 })
        
        player:giveExp()
        player.gold = player.gold + math.random(1, 20)

        if math.random(1, 25) == 1 then
            player.inventory:giveRandomWeapon(self.level, self.level + 2)
        end

        if self.isBoss and player.relics < 10 then
            map.currentRoom:placeRelic()
        end
    end

    self:enemyAttackHandler(dt)
end

function Enemy:draw()
    if not self.dead then
        love.graphics.draw(self.image, self.x, self.y)
        
        setColor(self.healthIndicator.color.r, self.healthIndicator.color.g, self.healthIndicator.color.b, self.healthIndicator.color.a)
        love.graphics.rectangle("fill", self.healthIndicator.x, self.healthIndicator.y, self.healthIndicator.width, self.healthIndicator.height)
        resetColor()

        setColor(255/255, 255/255, 255/255, 255/255)
        love.graphics.draw(self.healthBar.image, self.healthBar.x, self.healthBar.y)
        resetColor()
        
        setColor(255/255, 0, 0, 255/255)
        setFont(20)
        love.graphics.print(
            "Level " .. tostring(self.level),
            self.healthBar.x + 91,
            self.healthBar.y + 41 - (love.graphics.getFont():getHeight() / 2)
        )
        resetFont()
        resetColor()
    end

    if self:attacking() then
        setColor(255/255, 0, 0, 200/255)
        love.graphics.setLineWidth(5)
        love.graphics.line(enemyAttack.x1, enemyAttack.y1, enemyAttack.x2, enemyAttack.y2)
        resetColor()
    end
end

function Enemy:attacking()
    return enemyAttack.x1 and enemyAttack.y1 and enemyAttack.x2 and enemyAttack.y2
end

function Enemy:isBlocking()
    return self.blocking
end

function Enemy:setBlocking(switch)
    self.blocking = switch
end

function Enemy:enemyAttackHandler(dt)
    if enemy.dead or player.dead then return end

    self.enemyTimer = self.enemyTimer + dt

    if enemy:attacking() then
        if self.enemyTimer > 0 and self.enemyTimer < enemy.speed then
            if player:attacking() then
                local speed = 15
                local direction = getDirection(
                    { x = enemyAttack.x2,
                    y = enemyAttack.y2 }, 
                    { x = ((playerAttack.x2 + playerAttack.x1) / 2),
                    y = ((playerAttack.y2 + playerAttack.y1) / 2) }
                )
                
                if enemy:isBlocking() then
                    enemyAttack.x2 = enemyAttack.x2 + direction.x * speed + math.random(-15, 15)
                    enemyAttack.y2 = enemyAttack.y2 + direction.y * speed + math.random(-15, 15)
                else
                    enemyAttack.x2 = enemyAttack.x2 - direction.x * speed + math.random(-15, 15)
                    enemyAttack.y2 = enemyAttack.y2 - direction.y * speed + math.random(-15, 15)
                end
            else
                enemyAttack.x2 = enemyAttack.x2 + math.random(-50, 50)
                enemyAttack.y2 = enemyAttack.y2 + math.random(-50, 50)
            end
        else
            if attackBlocked() then
                playerAttack = {}
                player.playerTimer = 0
                displayText("BLOCKED", 200, 40, 2, { r = 0, g = 255/255, b = 0, a = 255/255 })
                music:play(music.sfx.blockSFX)
            elseif self.enemyTimer >= enemy.speed then
                player.health = player.health - enemy.damage >= 0 and player.health - enemy.damage or 0
                displayText(enemy.damage, 200, 40, 2, { r = 0, g = 255/255, b = 0, a = 255/255 })
                music:play(music.sfx.enemySwingSFX)
                music:play(music.sfx.enemyHitPlayerSFX)
            end

            if self.enemyTimer >= enemy.speed then
                self.enemyTimer = self.enemyTimer - enemy.speed
            end

            enemyAttack = {}

            if math.random(2) == 1 then
                enemy:setBlocking(true)
            else
                enemy:setBlocking(false)
            end
        end
    else
        local startX = math.random((love.graphics.getWidth() / 2) - 100, (love.graphics.getWidth() / 2) + 100)
        local startY = math.random(self.y, self.y + 200)

        enemyAttack.x1, enemyAttack.y1 = startX, startY
        enemyAttack.x2, enemyAttack.y2 = startX, startY
    end
end