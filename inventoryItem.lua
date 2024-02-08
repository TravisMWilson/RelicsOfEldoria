InventoryItem = Object:extend()

function InventoryItem:new(type, code, level)
    self.deleteButton = Button(0, 0, "Assets/DeleteButton.png", InventoryItem.deleteItem)
    self.equipButton = Button(0, 0, "Assets/EquipButton.png", InventoryItem.equipItem)
    self.deleteButton.visible = true
    self.equipButton.visible = true

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
    self.deleteButton.x = ((self.x + self.width) - self.deleteButton.width) - 15
    self.deleteButton.y = ((self.y + self.height) - self.deleteButton.height) - 20
    self.equipButton.x = ((self.x + self.width) - self.equipButton.width) - 15
    self.equipButton.y = ((self.y + self.height) - (self.equipButton.height * 2)) - 30
end

function InventoryItem:draw()
    if self.selected then
        love.graphics.draw(self.selectedBackground, self.x, self.y)
    else
        love.graphics.draw(self.background, self.x, self.y)
    end

    love.graphics.draw(
        self.icon,
        (self.x + (self.width / 2)) - ((self.iconWidth * (self.height - 30) / self.iconHeight) / 2),
        self.y + 15,
        0,
        (self.height - 30) / self.iconHeight,
        (self.height - 30) / self.iconHeight
    )

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
    self.equipButton:draw()
end

function InventoryItem:mousepressed(x, y, button, istouch, presses)
    self.deleteButton:mousepressed(x, y, button, istouch, presses)
    self.equipButton:mousepressed(x, y, button, istouch, presses)
end

function InventoryItem:deleteItem()
    if #player.inventory.items > 1 then
        music:play(music.sfx.deleteItemSFX)

        local isDeleteSelected = false

        for i, item in ipairs(player.inventory.items) do
            if pointRectCollision(love.mouse:getX(), love.mouse:getY(), item) then
                if item.selected then
                    isDeleteSelected = true
                end

                table.remove(player.inventory.items, i)
                break
            end
        end

        if isDeleteSelected then
            player.inventory.items[1].selected = true
        end
    else
        music:play(music.sfx.cantDeleteVoiceSFX)
    end
end

function InventoryItem:equipItem()
    music:play(music.sfx.equipWeaponSFX)

    for i, item in ipairs(player.inventory.items) do
        if item.selected then
            item.selected = false
        elseif pointRectCollision(love.mouse:getX(), love.mouse:getY(), item) then
            item.selected = true

            player.image = love.graphics.newImage("Assets/" .. item.type .. item.code .. ".png")
            player.width = player.image:getWidth()
            player.height = player.image:getHeight()
            player.weaponLevel = item.level

            local defaultPosition = {}

            if item.type == "Staff" or item.type == "Spear" then
                defaultPosition = {
                    x = (love.graphics.getWidth() * 0.75) - (player.width * 0.75),
                    y = love.graphics.getHeight() - (player.height * 0.65)
                }
            else
                defaultPosition = {
                    x = (love.graphics.getWidth() * 0.75) - (player.width * 0.75),
                    y = love.graphics.getHeight() - (player.height * 0.8)
                }
            end

            player.x = defaultPosition.x
            player.y = defaultPosition.y
        end
    end
end
