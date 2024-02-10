Inventory = Object:extend()

local WEAPON_TYPES = { "Axe", "Dagger", "Hammer", "Spear", "Staff", "Sword" }

local WEAPON_TYPE_QUANTITIES = {
    ["Axe"] = 15,
    ["Dagger"] = 24,
    ["Hammer"] = 10,
    ["Spear"] = 8,
    ["Staff"] = 34,
    ["Sword"] = 47
}

local inventoryScrollOffset = 0

function Inventory:new()
    self.open = false

    self.background = ui.images.inventoryBackground
    self.title = ui.images.inventoryTitle

    self.items = {}
    table.insert(self.items, InventoryItem("Dagger", 1, 1))
    self.items[1].selected = true

    self.maxItems = 20

    self.confirmPopup = ConfirmPopup()
    self.indexToDelete = 0
    self.isDeleteSelected = false
    self.nextWeaponIndex = nil

    self.showIcon = nil
    self.showLevel = 0
    self.rays = Particles(750, 375, 5, 1.5, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1.5, 0, "Assets/ray.png")
    self.rays:setColor(0, 0, 0, 0, 0, 0, 0, 0.9, 0, 0, 0, 0)
    self.rayBackground = Particles(750, 375, 30, 2, 50, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1.8, -200, "Assets/WhiteCloud.png")
    self.rayBackground:setColor(167/255, 98/255, 255/255, 0, 22/255, 252/255, 62/255, 0.9, 255/255, 46/255, 247/255, 0)
    self.showRays = false
    self.rayTimer = 0
end

function Inventory:update(dt)
    if self.open then
        local offsetX = ((love.graphics:getWidth() / 2) - (self.background:getWidth() / 2) + 11)
        local offsetY = 58 + inventoryScrollOffset
        local row = 0
        local column = 0

        for _, item in pairs(self.items) do
            item.x = offsetX + (column * item.width)
            item.y = offsetY + (row * item.height)

            column = column + 1

            if column >= 4 then
                column = 0
                row = row + 1
            end

            item:update(dt)
        end

        if self.confirmPopup.visible and self.confirmPopup.answer then
            if self.confirmPopup.answer == "Yes" then
                table.remove(player.inventory.items, self.indexToDelete)

                if self.isDeleteSelected then
                    local item = player.inventory.items[self.nextWeaponIndex]
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
                
                music:play(music.sfx.deleteItemSFX)
            else
                music:play(music.sfx.buttonPressSFX)
            end

            self.confirmPopup.answer = false
            self.confirmPopup.visible = false
        end
    end

    if self.showRays then
        self.rayTimer = self.rayTimer + dt

        self.rayBackground:update(dt)
        self.rays:update(dt)

        if self.rayTimer > 3 then
            self.rayTimer = 0
            self.showRays = false
        end
    end
end

function Inventory:draw()
    if self.open then
        love.graphics.draw(self.background, (love.graphics:getWidth() / 2) - (self.background:getWidth() / 2), 0)
    
        for _, item in ipairs(self.items) do
            item:draw()
        end
    
        love.graphics.draw(self.title, (love.graphics:getWidth() / 2) - (self.title:getWidth() / 2), 0)

        setFont(24)
        love.graphics.print("INVENTORY", (love.graphics:getWidth() / 2) - (love.graphics.getFont():getWidth("INVENTORY") / 2), 18)
        resetFont()
        
        self.confirmPopup:draw()
    end

    if self.showRays then
        self.rayBackground:draw()
        self.rays:draw()

        local scale = 0.85
        local iconWidth = self.showIcon:getWidth() * scale
        local iconHeight = self.showIcon:getHeight() * scale
        local iconX = (love.graphics:getWidth() / 2) - (iconWidth / 2)
        local iconY = (love.graphics:getHeight() / 2) - (iconHeight / 2)

        love.graphics.draw(self.showIcon, iconX, iconY, 0, scale, scale)

        setColor(0, 0, 0, 1)
        setFont(80)
        love.graphics.print(
            tostring(self.showLevel),
            iconX - love.graphics.getFont():getWidth(tostring(self.showLevel)),
            (love.graphics:getHeight() / 2)
        )
        resetFont()
        resetColor()
    end
end

function Inventory:mousepressed(x, y, button, istouch, presses)
    self.confirmPopup:mousepressed(x, y, button, istouch, presses)

    for _, item in pairs(self.items) do
        item:mousepressed(x, y, button, istouch, presses)
    end
end

function Inventory:wheelmoved(x, y)
    local minX = (love.graphics:getWidth() / 2) - (self.background:getWidth() / 2)
    local maxX = minX + self.background:getWidth()

    if love.mouse.getX() > minX and love.mouse.getX() < maxX then
        if y > 0 then
            inventoryScrollOffset = inventoryScrollOffset + 20

            if inventoryScrollOffset > 0 then
                inventoryScrollOffset = 0
            end
        elseif y < 0 then
            inventoryScrollOffset = inventoryScrollOffset - 20

            local maxHeight = (((ui.images.itemBackgound:getHeight() * 5) + ui.images.inventoryTitle:getHeight()) - love.graphics:getHeight()) * -1

            if inventoryScrollOffset < maxHeight then
                inventoryScrollOffset = maxHeight
            end
        end
    end
end

function Inventory:giveRandomWeapon(minLevel, maxLevel)
    if #player.inventory.items < player.inventory.maxItems then
        local weaponType = WEAPON_TYPES[love.math.random(1, 6)]
        local weaponCode = love.math.random(1, WEAPON_TYPE_QUANTITIES[weaponType])
        local weaponLevel = love.math.random(minLevel, maxLevel)

        table.insert(player.inventory.items, InventoryItem(weaponType, weaponCode, weaponLevel))

        player.inventory.showIcon = love.graphics.newImage("Assets/" .. weaponType ..tostring(weaponCode) .. ".png")
        player.inventory.showLevel = weaponLevel
        player.inventory.showRays = true

        if #player.inventory.items == 20 then
            music.sfx.inventoryFullVoiceSFX:play()
        elseif #player.inventory.items >= 17 then
            music.sfx.inventoryGettingFullVoiceSFX:play()
        end
    else
        music.sfx.inventoryFullVoiceSFX:play()
    end
end