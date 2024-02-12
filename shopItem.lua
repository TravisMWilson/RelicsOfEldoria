ShopItem = Object:extend()

function ShopItem:new(type, code, level)
    self.background = Button(0, 0, "Assets/ShopItemFrame.png", ShopItem.buyItem)
    self.background.visible = true
    self.width = 397
    self.height = 70

    self.type = type
    self.code = code
    self.level = level

    self.x = 0
    self.y = 0

    if type == "Potion" then
        self.icon = ui.images.healthPotionUI
    else
        self.icon = love.graphics.newImage("Assets/" .. type .. code .. ".png")
    end

    self.iconWidth = self.icon:getWidth()
    self.iconHeight = self.icon:getHeight()
end

function ShopItem:update(dt)
    self.background.x = self.x
    self.background.y = self.y
end

function ShopItem:draw()
    self.background:draw()

    local scaleWidth = (self.height - 26) / self.iconWidth
    local scaleHeight = (self.height - 24) / self.iconHeight
    local scale

    if scaleWidth < scaleHeight then
        scale = scaleWidth
    else
        scale = scaleHeight
    end
    
    love.graphics.draw(
        self.icon,
        (self.x + 32) - ((self.iconWidth * scale) / 2),
        (self.y + 35) - ((self.iconHeight * scale) / 2),
        0,
        scale,
        scale
    )

    local titleText = "Level " .. tostring(self.level) .. " - " .. self.type

    setColor(255/255, 159/255, 76/255, 255/255)
    setFont(20)
    love.graphics.print(
        titleText,
        (self.x + 245) - (love.graphics.getFont():getWidth(tostring(titleText)) / 2),
        (self.y + 23) - (love.graphics.getFont():getHeight() / 2)
    )
    resetFont()
    resetColor()

    local goldCost = tostring(math.floor(self.level * ((self.level * 1.11) + 33)))

    if self.type == "Potion" then
        goldCost = tostring(player.level * 50)
    end

    setColor(254/255, 246/255, 133/255, 255/255)
    setFont(20)
    love.graphics.print(
        goldCost,
        (self.x + 245) - (love.graphics.getFont():getWidth(goldCost) / 2),
        (self.y + 48) - (love.graphics.getFont():getHeight() / 2)
    )
    resetFont()
    resetColor()
end

function ShopItem:mousepressed(x, y, button, istouch, presses)
    self.background:mousepressed(x, y, button, istouch, presses)
end

function ShopItem:buyItem()
    for i, item in ipairs(player.inventory.shopItems) do
        if pointRectCollision(love.mouse:getX(), love.mouse:getY(), item) then
            player.inventory.buyingItem = item
        end
    end

    player.inventory.buying = true
    player.inventory.confirmPopup.visible = true
    music:play(music.sfx.buttonPressSFX)
end
