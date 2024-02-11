Enemy = Object:extend()

enemyAttack = {}

local DISTANCE_INCREMENT = 100
local TIME_INCREMENT = 0.35
local INCREMENT_MAX = 7
local NUMBER_OF_ENEMIES = 87
local NUMBER_OF_BOSSES = 11

local function moveTowards(obj, targetX, targetY, speed, dt)
    local directionX = targetX - obj.x
    local directionY = targetY - obj.y

    local distance = math.sqrt(directionX ^ 2 + directionY ^ 2)

    directionX = directionX / distance
    directionY = directionY / distance

    local nextX = obj.x + ((directionX * speed) * dt)
    local nextY = obj.y + ((directionY * speed) * dt)

    return nextX, nextY
end

local function drawSpecialAttack()
    setColor(1, 0, 0, 0.75)

    if #enemy.circleAttacks > 0 then
        for i, circle in ipairs(enemy.circleAttacks) do
            love.graphics.ellipse("fill", circle.x, circle.y, circle.radius, circle.radius)
        end
    end
    
    if #enemy.blockAttacks > 0 then
        for i, block in ipairs(enemy.blockAttacks) do
            love.graphics.rectangle("fill", block.x, block.y, block.width, block.height)
        end
    end

    resetColor()
end

local function updateSpecialAttack(dt)
    if #enemy.circleAttacks > 0 then
        for i = #enemy.circleAttacks, 1, -1 do
            local circle = enemy.circleAttacks[i]

            if circle.specialNumber == 1 then
                local newX, newY = moveTowards(circle, love.mouse:getX(), love.mouse:getY(), 125, dt)
                circle.x = newX
                circle.y = newY
                circle.timer = circle.timer - dt

                if circle.timer <= 0 then
                    table.remove(enemy.circleAttacks, i)
                end
            elseif circle.specialNumber == 2 then
                circle.radius = circle.radius + (150 * dt)
                circle.timer = circle.timer - dt

                if circle.timer <= 0 then
                    table.remove(enemy.circleAttacks, i)
                end
            elseif circle.specialNumber == 3 then
                if circle.side == 1 then
                    circle.y = circle.y + (200 * dt)
                elseif circle.side == 2 then
                    circle.y = circle.y - (200 * dt)
                elseif circle.side == 3 then
                    circle.x = circle.x + (200 * dt)
                elseif circle.side == 4 then
                    circle.x = circle.x - (200 * dt)
                end

                if (circle.side == 1 and circle.y > love.graphics:getHeight() + (circle.radius * 2))
                or (circle.side == 2 and circle.y < -(circle.radius * 2))
                or (circle.side == 3 and circle.x > love.graphics:getWidth() + (circle.radius * 2))
                or (circle.side == 4 and circle.x > -(circle.radius * 2)) then
                    table.remove(enemy.circleAttacks, i)
                end
            end

            if (player:attacking() and lineCircleCollision(playerAttack.x1, playerAttack.y1, playerAttack.x2, playerAttack.y2, circle.x, circle.y, circle.radius))
            or pointCircleCollision(love.mouse:getX(), love.mouse:getY(), circle.x, circle.y, circle.radius) then
                table.remove(enemy.circleAttacks, i)
                local circleDamage = math.floor(circle.radius * 0.25)
                player.health = player.health - circleDamage >= 0 and player.health - circleDamage or 0
                table.insert(textInstances, DisplayText(circleDamage, 200, 40, 2, { r = 0, g = 255/255, b = 0, a = 255/255 }))
                music:play(music.sfx.enemySwingSFX)
                music:play(music.sfx.enemyHitPlayerSFX)
            end
        end
    end
    
    if #enemy.blockAttacks > 0 then
        for i = #enemy.blockAttacks, 1, -1 do
            local block = enemy.blockAttacks[i]

            if block.specialNumber == 4 or block.specialNumber == 5 then
                if block.side == 1 then
                    block.y = block.y + (100 * dt)
                elseif block.side == 2 then
                    block.y = block.y - (100 * dt)
                elseif block.side == 3 then
                    block.x = block.x + (100 * dt)
                elseif block.side == 4 then
                    block.x = block.x - (100 * dt)
                end

                if (block.side == 1 and block.y > love.graphics:getHeight())
                or (block.side == 2 and block.y < -block.height)
                or (block.side == 3 and block.x > love.graphics:getWidth())
                or (block.side == 4 and block.x > -block.width) then
                    table.remove(enemy.blockAttacks, i)
                end
            end

            if (player:attacking() and lineRectCollision(playerAttack.x1, playerAttack.y1, playerAttack.x2, playerAttack.y2, block.x, block.y, block.width, block.height))
            or pointRectCollision(love.mouse:getX(), love.mouse:getY(), block) then
                table.remove(enemy.blockAttacks, i)
                local blockDamage = math.floor((block.width * block.height) / 1500)
                player.health = player.health - blockDamage >= 0 and player.health - blockDamage or 0
                table.insert(textInstances, DisplayText(blockDamage, 200, 40, 2, { r = 0, g = 255/255, b = 0, a = 255/255 }))
                music:play(music.sfx.enemySwingSFX)
                music:play(music.sfx.enemyHitPlayerSFX)
            end
        end
    end

    if #enemy.circleAttacks > 0 and #enemy.blockAttacks == 0 then
        enemy.currentSpecialAttacks = 0
    end
end

function Enemy:new()
    self.level = love.math.random(currentLevel, currentLevel + 5)

    local bossAlreadyDead = false

    for _, boss in ipairs(player.bossesDead) do
        if boss == currentLevel then
            bossAlreadyDead = true
        end
    end

    if love.math.random(1, 300) == 1 and not bossAlreadyDead then
        self.isBoss = true
        self.image = love.graphics.newImage("Assets/Boss" .. love.math.random(1, NUMBER_OF_BOSSES) .. ".png")
        self.maxHealth = self.level * 175
        self.maxSpecialAttacks = 5

        if player.relics == 9 then
            playStory = 3
        end
    else
        self.isBoss = false
        self.image = love.graphics.newImage("Assets/Enemy" .. love.math.random(1, NUMBER_OF_ENEMIES) .. ".png")
        self.maxHealth = self.level * 25
        self.maxSpecialAttacks = 2
    end
    
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.x = (love.graphics.getWidth() * 0.5) - (self.width / 2)
    self.y = (love.graphics.getHeight() * 0.85) - (self.height / 2)

    self.health = self.maxHealth
    self.dead = true
    self.damage = 0
    self.speed = love.math.random(7, 20) / 10

    self.currentSpecialAttacks = 0
    self.usingSpecial = false
    self.specialTimer = 0
    self.circleAttacks = {}
    self.blockAttacks = {}

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
    if not self.dead then
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
            self.circleAttacks = {}
            self.blockAttacks = {}
            table.insert(textInstances, DisplayText("Enemy Died", 200, 40, 2, { r = 255/255, g = 0, b = 0, a = 255/255 }))
            
            player:giveExp()

            local goldIncrease = love.math.random(1, 20)
            player.gold = player.gold + goldIncrease
            player.totalGold = player.totalGold + goldIncrease

            if love.math.random(1, 25) == 1 then
                player.inventory:giveRandomWeapon(self.level, self.level + 1)
            end

            if self.isBoss and player.relics < 10 then
                map.currentRoom:placeRelic()
            end
        end

        self:enemyAttackHandler(dt)

        if (love.math.random(1, 200) == 1) or (self.isBoss and love.math.random(1, 100) == 1) then
            self:specialAttack()
        end
    
        updateSpecialAttack(dt)
    end
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

        drawSpecialAttack()
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
                    enemyAttack.x2 = enemyAttack.x2 + direction.x * speed + love.math.random(-15, 15)
                    enemyAttack.y2 = enemyAttack.y2 + direction.y * speed + love.math.random(-15, 15)
                else
                    enemyAttack.x2 = enemyAttack.x2 - direction.x * speed + love.math.random(-15, 15)
                    enemyAttack.y2 = enemyAttack.y2 - direction.y * speed + love.math.random(-15, 15)
                end
            else
                enemyAttack.x2 = enemyAttack.x2 + love.math.random(-50, 50)
                enemyAttack.y2 = enemyAttack.y2 + love.math.random(-50, 50)
            end
        else
            if attackBlocked() then
                playerAttack = {}
                player.playerTimer = 0
                table.insert(textInstances, DisplayText("BLOCKED", 200, 40, 2, { r = 0, g = 255/255, b = 0, a = 255/255 }))
                music:play(music.sfx.blockSFX)
            elseif self.enemyTimer >= enemy.speed then
                player.health = player.health - enemy.damage >= 0 and player.health - enemy.damage or 0
                table.insert(textInstances, DisplayText(enemy.damage, 200, 40, 2, { r = 0, g = 255/255, b = 0, a = 255/255 }))
                music:play(music.sfx.enemySwingSFX)
                music:play(music.sfx.enemyHitPlayerSFX)
            end

            if self.enemyTimer >= enemy.speed then
                self.enemyTimer = self.enemyTimer - enemy.speed
            end

            enemyAttack = {}

            if love.math.random(2) == 1 then
                enemy:setBlocking(true)
            else
                enemy:setBlocking(false)
            end
        end
    else
        local startX = love.math.random(self.x, self.x + self.width)
        local startY = love.math.random(self.y, self.y + (self.height / 2))

        enemyAttack.x1, enemyAttack.y1 = startX, startY
        enemyAttack.x2, enemyAttack.y2 = startX, startY
    end
end

function Enemy:specialAttack()
    self.currentSpecialAttacks = self.currentSpecialAttacks + 1
    local chosenSpecialAttack = love.math.random(1, 5)

    if self.currentSpecialAttacks < self.maxSpecialAttacks then
        if chosenSpecialAttack == 1 then
            local newCircle = CircleAttack()
            newCircle.specialNumber = 1
            newCircle.side = love.math.random(1, 4)
            newCircle.radius = love.math.random(15, 40)
            newCircle.timer = love.math.random(100, 200) / 10
            
            if newCircle.side == 1 then
                newCircle.x = love.math.random(0, love.graphics:getWidth())
                newCircle.y = -newCircle.radius
            elseif newCircle.side == 2 then
                newCircle.x = love.math.random(0, love.graphics:getWidth())
                newCircle.y = love.graphics:getHeight() + newCircle.radius
            elseif newCircle.side == 3 then
                newCircle.x = -newCircle.radius
                newCircle.y = love.math.random(0, love.graphics:getHeight())
            elseif newCircle.side == 4 then
                newCircle.x = love.graphics:getWidth() + newCircle.radius
                newCircle.y = love.math.random(0, love.graphics:getHeight())
            end

            table.insert(self.circleAttacks, newCircle)
        elseif chosenSpecialAttack == 2 then
            local newCircle = CircleAttack()
            newCircle.specialNumber = 2
            newCircle.radius = 0
            newCircle.timer = love.math.random(10, 30) / 10
            newCircle.x = love.math.random(0, love.graphics:getWidth())
            newCircle.y = love.math.random(0, love.graphics:getHeight())

            table.insert(self.circleAttacks, newCircle)
        elseif chosenSpecialAttack == 3 then
            local circleCount = love.math.random(20, 60)

            for i = 1, circleCount do
                local newCircle = CircleAttack()
                newCircle.specialNumber = 3
                newCircle.side = love.math.random(1, 4)
                newCircle.radius = love.math.random(15, 20)
                
                if newCircle.side == 1 then
                    newCircle.x = love.math.random(0, love.graphics:getWidth())
                    newCircle.y = love.math.random(-love.graphics:getHeight(), -newCircle.radius)
                elseif newCircle.side == 2 then
                    newCircle.x = love.math.random(0, love.graphics:getWidth())
                    newCircle.y = love.graphics:getHeight() + love.math.random(newCircle.radius, love.graphics:getHeight())
                elseif newCircle.side == 3 then
                    newCircle.x = love.math.random(-love.graphics:getWidth(), -newCircle.radius)
                    newCircle.y = love.math.random(0, love.graphics:getHeight())
                elseif newCircle.side == 4 then
                    newCircle.x = love.graphics:getWidth() + love.math.random(newCircle.radius, love.graphics:getWidth())
                    newCircle.y = love.math.random(0, love.graphics:getHeight())
                end
        
                table.insert(self.circleAttacks, newCircle)
            end
        elseif chosenSpecialAttack == 4 then
            local opening = {
                width = love.math.random(50, 200),
                side = love.math.random(1, 4),
                x = 0,
                y = 0
            }

            if opening.side == 1 or opening.side == 2 then
                opening.x = love.math.random((opening.width / 2), love.graphics:getWidth() - (opening.width / 2))
            elseif opening.side == 3 or opening.side == 4 then
                opening.y = love.math.random((opening.width / 2), love.graphics:getHeight() - (opening.width / 2))
            end

            local newBlock1 = BlockAttack()
            newBlock1.specialNumber = 4
            newBlock1.side = opening.side

            if opening.side == 1 or opening.side == 2 then
                newBlock1.width = love.graphics:getWidth()
                newBlock1.height = love.math.random(10, 250)
                newBlock1.x = (opening.x - (opening.width / 2)) - newBlock1.width

                if opening.side == 1 then
                    newBlock1.y = -newBlock1.height
                else
                    newBlock1.y = love.graphics:getHeight() + newBlock1.height
                end
            elseif opening.side == 3 or opening.side == 4 then
                newBlock1.width = love.math.random(10, 100)
                newBlock1.height = love.graphics:getHeight()
                newBlock1.y = (opening.y - (opening.width / 2)) - newBlock1.height

                if opening.side == 3 then
                    newBlock1.x = -newBlock1.width
                else
                    newBlock1.x = love.graphics:getWidth() + newBlock1.width
                end
            end

            local newBlock2 = BlockAttack()
            newBlock2.specialNumber = newBlock1.specialNumber
            newBlock2.width = newBlock1.width
            newBlock2.height = newBlock1.height
            newBlock2.x = newBlock1.x
            newBlock2.y = newBlock1.y
            newBlock2.side = newBlock1.side

            if opening.side == 1 or opening.side == 2 then
                newBlock1.x = (opening.x + (opening.width / 2))
            elseif opening.side == 3 or opening.side == 4 then
                newBlock1.y = (opening.y + (opening.width / 2))
            end

            table.insert(self.blockAttacks, newBlock1)
            table.insert(self.blockAttacks, newBlock2)
        elseif chosenSpecialAttack == 5 then
            local blockCount = love.math.random(4, 8)

            for i = 1, blockCount do
                local newBlock = BlockAttack()
                newBlock.specialNumber = 5
                newBlock.side = love.math.random(1, 4)

                if newBlock.side == 1 or newBlock.side == 2 then
                    newBlock.width = love.math.random(10, 250)
                    newBlock.height = love.graphics:getHeight()
                    newBlock.x = love.math.random(0, love.graphics:getWidth())
        
                    if newBlock.side == 1 then
                        newBlock.y = -newBlock.height * i
                    else
                        newBlock.y = love.graphics:getHeight() + (newBlock.height * i)
                    end
                elseif newBlock.side == 3 or newBlock.side == 4 then
                    newBlock.width = love.graphics:getWidth()
                    newBlock.height = love.math.random(10, 100)
                    newBlock.y = love.math.random(0, love.graphics:getHeight())
        
                    if newBlock.side == 3 then
                        newBlock.x = -newBlock.width * 1
                    else
                        newBlock.x = love.graphics:getWidth() + (newBlock.width * 1)
                    end
                end

                table.insert(self.blockAttacks, newBlock)
            end
        end
    end
end
