InventoryItem = Object:extend()

function InventoryItem:new(type, code, level)
    if type ~= "Key" then
        self.equipButton = Button(0, 0, "Assets/EquipButton.png", InventoryItem.equipItem)
        self.equipButton.visible = true
    end

    self.deleteButton = Button(0, 0, "Assets/DeleteButton.png", InventoryItem.deleteItem)
    self.deleteButton.visible = true

    self.type = type
    self.code = code
    self.level = level

    self.selected = false

    self.x = 0
    self.y = 0

    self.icon = love.graphics.newImage("Assets/" .. type .. code .. ".png")
    self.iconWidth = self.icon:getWidth()
    self.iconHeight = self.icon:getHeight()

    self.background = ui.images.itemBackgound
    self.width = self.background:getWidth()
    self.height = self.background:getHeight()

    self.selectedBackground = ui.images.itemBackgroundSelected
end

function InventoryItem:update(dt)
    if self.type ~= "Key" then
        self.equipButton.x = ((self.x + self.width) - self.equipButton.width) - 15
        self.equipButton.y = ((self.y + self.height) - (self.equipButton.height * 2)) - 30
    end

    self.deleteButton.x = ((self.x + self.width) - self.deleteButton.width) - 15
    self.deleteButton.y = ((self.y + self.height) - self.deleteButton.height) - 20
end

function InventoryItem:draw()
    if self.selected then
        love.graphics.draw(self.selectedBackground, self.x, self.y)
    else
        love.graphics.draw(self.background, self.x, self.y)
    end

    if self.type == "Key" then
        love.graphics.draw(
            self.icon,
            (self.x + (self.width / 2)) - (self.iconWidth / 2),
            (self.y + (self.height / 2)) - (self.iconHeight / 2)
        )
    else
        local scale = (self.height - 30) / self.iconHeight
        
        love.graphics.draw(
            self.icon,
            (self.x + (self.width / 2)) - ((self.iconWidth * scale) / 2),
            self.y + 15,
            0,
            scale,
            scale
        )
    end

    setColor(255/255, 159/255, 76/255, 255/255)
    setFont(25)
    love.graphics.print(
        tostring(self.level),
        self.x + 15 ,
        (((self.y + self.height) - (love.graphics.getFont():getHeight() / 2)) - 20)
    )
    resetFont()
    resetColor()

    self.deleteButton:draw()

    if self.type ~= "Key" then
        self.equipButton:draw()
    end
end

function InventoryItem:mousepressed(x, y, button, istouch, presses)
    if self.type ~= "Key" then
        self.equipButton:mousepressed(x, y, button, istouch, presses)
    end

    self.deleteButton:mousepressed(x, y, button, istouch, presses)
end

function InventoryItem:deleteItem()
    if #player.inventory.items > 1 then
        local isWeapon = false
        local totalWeapons = 0

        player.inventory.isDeleteSelected = false
        player.inventory.indexToDelete = 0
        player.inventory.nextWeaponIndex = 0

        for i, item in ipairs(player.inventory.items) do
            if pointRectCollision(love.mouse:getX(), love.mouse:getY(), item) then
                if item.selected then
                    player.inventory.isDeleteSelected = true
                end

                if item.type ~= "Key" then
                    totalWeapons = totalWeapons + 1
                end

                player.inventory.indexToDelete = i
            elseif item.type ~= "Key" then
                totalWeapons = totalWeapons + 1

                if i ~= 1 then
                    player.inventory.nextWeaponIndex = i - 1
                else
                    player.inventory.nextWeaponIndex = i
                end
            end
        end

        if (isWeapon and totalWeapons > 1) or not isWeapon then
            player.inventory.confirmPopup.visible = true
            music:play(music.sfx.buttonPressSFX)
        else
            music.sfx.cantDeleteVoiceSFX:play()
        end
    else
        music.sfx.cantDeleteVoiceSFX:play()
    end
end

function InventoryItem:equipItem()
    music:play(music.sfx.equipWeaponSFX)

    for i, item in ipairs(player.inventory.items) do
        if item.selected then
            item.selected = false
        end
        
        if pointRectCollision(love.mouse:getX(), love.mouse:getY(), item) then
            item.selected = true

            player.image = love.graphics.newImage("Assets/" .. item.type .. item.code .. ".png")
            player.width = player.image:getWidth()
            player.height = player.image:getHeight()
            player.weaponLevel = item.level

            if item.type == "Staff" or item.type == "Spear" then
                player.defaultPosition = {
                    x = (love.graphics.getWidth() * 0.75) - (player.width * 0.75),
                    y = love.graphics.getHeight() - (player.height * 0.65)
                }
            else
                player.defaultPosition = {
                    x = (love.graphics.getWidth() * 0.75) - (player.width * 0.75),
                    y = love.graphics.getHeight() - (player.height * 0.8)
                }
            end

            player.x = player.defaultPosition.x
            player.y = player.defaultPosition.y
        end
    end
end
