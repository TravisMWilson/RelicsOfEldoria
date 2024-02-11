UI = Object:extend()

textInstances = {}

playStory = 0

local DISTANCE_INCREMENT = 80
local TIME_INCREMENT = 0.1
local INCREMENT_MAX = 9

local distanceIndicator = {}
local healthIndicator = {}
local healthPotionUI = {}
local timeIndicator = {}
local expIndicator = {}
local deathImage = {}
local healthBar = {}
local relicUI = {}

local playingStory = false
local playStoryPart = 1
local storyOffsetX = 0
local storyOffsetY = 0
local storyLogoAlpha = 5

local currentColor = { r = 255/255, g = 255/255, b = 255/255, a = 255/255 }
local currentFont = love.graphics.getFont()

function setColor(r, g, b, a)
    currentColor.r, currentColor.g, currentColor.b, currentColor.a = love.graphics.getColor()
    love.graphics.setColor(r, g, b, a)
end

function resetColor()
    love.graphics.setColor(currentColor.r, currentColor.g, currentColor.b, currentColor.a)
end

function setFont(scale, ...)
    local otherFont = {...}

    currentFont = love.graphics.getFont()

    if #otherFont == 0 then
        love.graphics.setFont(love.graphics.newFont("Assets/Candarab.ttf", scale))
    else
        love.graphics.setFont(love.graphics.newFont(otherFont[1], scale))
    end
end

function resetFont()
    love.graphics.setFont(currentFont)
end

local function setupDisplay(self)
    local frameSize = 132
    local frameCount = 9

    timeIndicator.image = self.images.playerDamageDisplay
    timeIndicator.frames = {}
    timeIndicator.currentFrame = 1

    for i = 0, frameCount - 1 do
        table.insert(
            timeIndicator.frames,
            love.graphics.newQuad(i * frameSize, 0, frameSize, frameSize, timeIndicator.image:getWidth(),
            timeIndicator.image:getHeight())
        )
    end

    distanceIndicator.image = self.images.playerMultiplierDisplay
    distanceIndicator.frames = {}
    distanceIndicator.currentFrame = 1

    for i = 0, frameCount - 1 do
        table.insert(
            distanceIndicator.frames,
            love.graphics.newQuad(i * frameSize, 0, frameSize, frameSize, distanceIndicator.image:getWidth(),
            distanceIndicator.image:getHeight())
        )
    end
    
    healthBar.image = self.images.playerHealthBar
    healthBar.width = healthBar.image:getWidth()
    healthBar.height = healthBar.image:getHeight()
    healthBar.x = 20
    healthBar.y = 20

    healthIndicator.width = 150
    healthIndicator.maxWidth = 150
    healthIndicator.height = 25
    healthIndicator.x = 65 + healthBar.x
    healthIndicator.y = 76 + healthBar.y
    healthIndicator.color = { r = 82/255, g = 190/255, b = 90/255, a = 200/255 }

    expIndicator.width = 0
    expIndicator.maxWidth = 150
    expIndicator.height = 25
    expIndicator.x = 65 + healthBar.x
    expIndicator.y = 111 + healthBar.y
    expIndicator.color = { r = 56/255, g = 210/255, b = 215/255, a = 200/255 }
    
    healthBar.image = self.images.playerHealthBar
    healthBar.width = healthBar.image:getWidth()
    healthBar.height = healthBar.image:getHeight()
    healthBar.x = 20
    healthBar.y = 20
    
    healthPotionUI.image = self.images.healthPotionUI
    healthPotionUI.width = healthPotionUI.image:getWidth()
    healthPotionUI.height = healthPotionUI.image:getHeight()
    healthPotionUI.x = (love.graphics:getWidth() - 20) - healthPotionUI.width
    healthPotionUI.y = (love.graphics:getHeight() - 20) - healthPotionUI.height
    
    relicUI.image = self.images.relicUI
    relicUI.width = relicUI.image:getWidth()
    relicUI.height = relicUI.image:getHeight()
    relicUI.x = (love.graphics:getWidth() - 20) - relicUI.width
    relicUI.y = (love.graphics:getHeight() - 20) - relicUI.height - healthPotionUI.height - 20
    
    deathImage.image = self.images.death
    deathImage.x = 0
    deathImage.y = love.graphics.getHeight() - deathImage.image:getHeight()
end

local function drawDisplay()
    setColor(healthIndicator.color.r, healthIndicator.color.g, healthIndicator.color.b, healthIndicator.color.a)
    love.graphics.rectangle("fill", healthIndicator.x, healthIndicator.y, healthIndicator.width, healthIndicator.height)
    resetColor()
    
    setColor(expIndicator.color.r, expIndicator.color.g, expIndicator.color.b, expIndicator.color.a)
    love.graphics.rectangle("fill", expIndicator.x, expIndicator.y, expIndicator.width, expIndicator.height)
    resetColor()

    setColor(255/255, 255/255, 255/255, 255/255)
    love.graphics.draw(healthBar.image, healthBar.x, healthBar.y)
    love.graphics.draw(healthPotionUI.image, healthPotionUI.x, healthPotionUI.y)
    love.graphics.draw(relicUI.image, relicUI.x, relicUI.y)
    resetColor()

    setColor(14/255, 171/255, 66/255, 255/255)
    setFont(25)
    love.graphics.print(
        tostring(player.healthPotions),
        (healthPotionUI.x - 15) - love.graphics.getFont():getWidth(player.healthPotions),
        (love.graphics:getHeight() - 20) - love.graphics.getFont():getHeight()
    )
    resetFont()
    resetColor()

    setColor(246/255, 55/255, 53/255, 255/255)
    setFont(25)
    love.graphics.print(
        tostring(player.relics),
        (relicUI.x - 15) - love.graphics.getFont():getWidth(player.relics),
        (love.graphics:getHeight() - 40) - healthPotionUI.height - love.graphics.getFont():getHeight()
    )
    resetFont()
    resetColor()
end

local function updateIndicators(dt)
    if player:attacking() then
        player.playerTimer = player.playerTimer + dt

        local distance = getDistance(
            { x = playerAttack.x1, y = playerAttack.y1 },
            { x = playerAttack.x2, y = playerAttack.y2 }
        )
        
        if player.playerTimer < TIME_INCREMENT * INCREMENT_MAX then
            timeIndicator.currentFrame = math.floor(player.playerTimer / TIME_INCREMENT) + 1
        else
            timeIndicator.currentFrame = INCREMENT_MAX
        end

        if distance < DISTANCE_INCREMENT * INCREMENT_MAX then
            distanceIndicator.currentFrame = math.floor(distance / DISTANCE_INCREMENT) + 1
        else
            distanceIndicator.currentFrame = INCREMENT_MAX
        end
    else
        timeIndicator.currentFrame = 1
        distanceIndicator.currentFrame = 1
    end

    expIndicator.width = expIndicator.maxWidth * (player.exp / player.expNeeded)
    healthIndicator.width = healthIndicator.maxWidth * (player.health / player.maxHealth)
end

local function drawIndicators()
    if not enemy.dead then
        setColor(255/255, 255/255, 255/255, 255/255)
        love.graphics.draw(timeIndicator.image, timeIndicator.frames[math.floor(timeIndicator.currentFrame)], 100, love.graphics:getHeight() - 232)
        love.graphics.draw(distanceIndicator.image, distanceIndicator.frames[math.floor(distanceIndicator.currentFrame)], 100, love.graphics:getHeight() - 232)

        setFont(20)
        love.graphics.print(
            "Damage: " .. player.damage,
            166 - (love.graphics.getFont():getWidth("Damage: " .. player.damage) / 2),
            love.graphics:getHeight() - 90
        )
        resetFont()
        resetColor()
    end

    setColor(255/255, 159/255, 76/255, 255/255)
    setFont(36)
    love.graphics.print(
        "Level " .. tostring(player.level),
        healthBar.x + 91,
        healthBar.y + 46 - (love.graphics.getFont():getHeight() / 2)
    )
    resetFont()
    resetColor()

    setColor(254/255, 246/255, 133/255, 255/255)
    setFont(25)
    love.graphics.print(
        tostring(player.gold),
        healthBar.x + 67,
        healthBar.y + 160 - (love.graphics.getFont():getHeight() / 2)
    )
    resetFont()
    resetColor()
end

function UI:new()
    self.images = {}
    self.images.playerMultiplierDisplay = love.graphics.newImage("Assets/PlayerMultiplierDisplay.png")
    self.images.itemBackgroundSelected = love.graphics.newImage("Assets/ItemBackgroundSelected.png")
    self.images.playerDamageDisplay = love.graphics.newImage("Assets/PlayerDamageDisplay.png")
    self.images.inventoryBackground = love.graphics.newImage("Assets/InventoryBackground.png")
    self.images.playerHealthBar = love.graphics.newImage("Assets/PlayerHealthBar.png")
    self.images.inventoryButton = love.graphics.newImage("Assets/InventoryButton.png")
    self.images.healthPotionUI = love.graphics.newImage("Assets/HealthPotion_UI.png")
    self.images.enemyHealthBar = love.graphics.newImage("Assets/EnemyHealthBar.png")
    self.images.inventoryTitle = love.graphics.newImage("Assets/InventoryTitle.png")
    self.images.itemBackgound = love.graphics.newImage("Assets/ItemBackground.png")
    self.images.confirmPopup = love.graphics.newImage("Assets/ConfirmPopup.png")
    self.images.deleteButton = love.graphics.newImage("Assets/DeleteButton.png")
    self.images.statsButton = love.graphics.newImage("Assets/StatsButton.png")
    self.images.equipButton = love.graphics.newImage("Assets/EquipButton.png")
    self.images.waypointUI = love.graphics.newImage("Assets/WaypointUI.png")
    self.images.scrollMenu = love.graphics.newImage("Assets/ScrollMenu.png")
    self.images.relicUI = love.graphics.newImage("Assets/RelicUI.png")
    self.images.death = love.graphics.newImage("Assets/Death.png")
        
    self.images.storyScene1Logo = love.graphics.newImage("Assets/StoryScene1.png")
    self.images.storyScene1 = love.graphics.newImage("Assets/StoryScene1.jpg")
    self.images.storyScene2 = love.graphics.newImage("Assets/StoryScene2.jpg")
    self.images.storyScene3 = love.graphics.newImage("Assets/StoryScene3.jpg")

    self.buttons = {}
    table.insert(self.buttons, Button(20, 380, "Assets/InventoryButton.png", Player.openInventory))
    table.insert(self.buttons, Button(20, 265, "Assets/StatsButton.png", Player.openStats))

    for _, uiButton in pairs(self.buttons) do
        uiButton.visible = true
    end

    self.skipScenes = false

    setupDisplay(self)
    playStory = 1
end

function UI:update(dt)
    updateIndicators(dt)

    setColor(255/255, (400 * (player.health / player.maxHealth))/255 + 0.25, (400 * (player.health / player.maxHealth))/255 + 0.25, 255/255)
    player.damage = math.ceil((distanceIndicator.currentFrame * timeIndicator.currentFrame) * (player.weaponLevel * 0.25))

    if not playingStory then
        if playStory ~= 0 then
            music.voice["voiceStory" .. playStory .. playStoryPart]:play()
            playingStory = true
            
            if playStory == 4 then
                enemy.dead = true
                map.currentRoom = Room(0, 0, 0, {})
                player.health = player.maxHealth

                for _, button in ipairs(map.currentRoom.buttons) do
                    button.visible = true
                end

                currentLevel = 0
            end
        end
    else
        if playStory ~= 0 then
            if not music.voice["voiceStory" .. playStory .. playStoryPart]:isPlaying() then
                playStoryPart = playStoryPart + 1
                playingStory = false

                if (playStory == 1 and playStoryPart >= 8)
                or (playStory == 2 and playStoryPart >= 3)
                or (playStory == 3 and playStoryPart >= 3)
                or (playStory == 4 and playStoryPart >= 5) then
                    playStory = 0
                    playStoryPart = 1

                    self.skipScenes = false
                end
            end
        end
    end
    
    for i = #textInstances, 1, -1 do
        textInstances[i]:update(dt)

        if textInstances[i].remove then
            table.remove(textInstances, i)
        end
    end
end

function UI:draw()
    if not player.dead then
        drawDisplay()
        drawIndicators()
    else
        setColor(1, 1, 1, 1)
        love.graphics.draw(deathImage.image, deathImage.x, deathImage.y)
        resetColor()
    end

    for _, button in pairs(self.buttons) do
        button:draw()
    end

    if playStory == 1 and not self.skipScenes then
        if playStoryPart <= 2 then
            storyOffsetX = storyOffsetX - 0.2
            storyOffsetY = storyOffsetY - 0.3
            storyLogoAlpha = storyLogoAlpha - 0.01

            love.graphics.draw(self.images.storyScene1, storyOffsetX, storyOffsetY)

            setColor(1, 1, 1, storyLogoAlpha)
            love.graphics.draw(self.images.storyScene1Logo, 0, 0)
            resetColor()
        elseif playStoryPart <= 4 then
            storyOffsetX = storyOffsetX + 0.1
            storyOffsetY = storyOffsetY + 0.02
            love.graphics.draw(self.images.storyScene1, storyOffsetX, storyOffsetY)
        elseif playStoryPart == 5 then
            storyOffsetX = -50
            storyOffsetY = storyOffsetY + 0.35
            love.graphics.draw(self.images.storyScene2, storyOffsetX, storyOffsetY)
        end
    elseif playStory == 4 then
        if playStoryPart <= 3 then
            storyOffsetX = storyOffsetX - 0.15
            storyOffsetY = storyOffsetY - 0.28
        else
            storyOffsetX = storyOffsetX - 0.05
            storyOffsetY = storyOffsetY + 0.4
        end

        love.graphics.draw(self.images.storyScene3, storyOffsetX, storyOffsetY)
    end
    
    for _, instance in ipairs(textInstances) do
        instance:draw()
    end

    if player.playingTutorial then
        love.graphics.draw(love.graphics.newImage("Assets/Tutorial" .. player.tutorialNumber .. ".png"))
    end
end

function UI:mousepressed(x, y, button, istouch, presses)
    for _, uiButton in pairs(self.buttons) do
        uiButton:mousepressed(x, y, button, istouch, presses)
    end
end
