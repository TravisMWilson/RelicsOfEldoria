Inventory = Object:extend()

local WEAPON_TYPES = { "Axe", "Dagger", "Hammer", "Spear", "Staff", "Sword", "Key" }

local WEAPON_TYPE_QUANTITIES = {
    ["Axe"] = 15,
    ["Dagger"] = 24,
    ["Hammer"] = 10,
    ["Spear"] = 8,
    ["Staff"] = 34,
    ["Sword"] = 47,
    ["Key"] = 4
}

local inventoryScrollOffset = 0
local shopScrollOffset = 0

local function updateConfirmPopup(self)
    if self.confirmPopup.visible and self.confirmPopup.answer then
        if self.confirmPopup.answer == "Yes" then
            if not self.buying then
                if self.sellingMode then
                    local goldIncrease = math.floor(player.inventory.items[self.indexToDelete].level * ((player.inventory.items[self.indexToDelete].level * 0.11) + 11))
                    player.gold = player.gold + goldIncrease
                    player.totalGold = player.totalGold + goldIncrease
                    music:play(music.sfx.coinSellSFX)
                else
                    music:play(music.sfx.deleteItemSFX)
                end

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
            else
                if #self.items < self.maxItems then
                    local itemCost = math.floor(self.buyingItem.level * ((self.buyingItem.level * 1.75) + 75))

                    if self.buyingItem.type == "Potion" then
                        itemCost = player.level * 50
                    end

                    if player.gold - itemCost >= 0 then
                        player.gold = player.gold - itemCost
                        music:play(music.sfx.coinSellSFX)

                        if self.buyingItem.type == "Potion" then
                            player.healthPotions = player.healthPotions + 1
                        else
                            table.insert(self.items, InventoryItem(self.buyingItem.type, self.buyingItem.code, self.buyingItem.level))
                        end
                    else
                        music.sfx.notEnoughGoldSFX:play()
                    end
                else
                    music.sfx.alreadyFullSFX:play()
                end

                self.buying = false
            end
        else
            music:play(music.sfx.buttonPressSFX)
        end

        self.confirmPopup.answer = false
        self.confirmPopup.visible = false
    end
end

function Inventory:new()
    self.open = false

    self.background = ui.images.inventoryBackground
    self.title = ui.images.inventoryTitle

    self.merchantCorner = ui.images.merchantCorner
    self.shopBackground = ui.images.shopBackground
    self.shopTitle = ui.images.shopTitle

    self.items = {}
    table.insert(self.items, InventoryItem("Dagger", 1, 1))
    self.items[1].selected = true

    self.shopItems = {}

    self.maxItems = 20

    self.confirmPopup = ConfirmPopup()
    self.indexToDelete = 0
    self.isDeleteSelected = false
    self.nextWeaponIndex = nil
    self.sellingMode = false
    self.buyingItem = {}
    self.buying = false

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

        if self.sellingMode then
            local offsetX = love.graphics:getWidth() - self.shopBackground:getWidth()
            local offsetY = 58 + shopScrollOffset
            local row = 0
            local column = 0
    
            for i, item in ipairs(self.shopItems) do
                item.x = offsetX
                item.y = offsetY + ((i - 1) * item.height)
    
                item:update(dt)
            end
        end

        updateConfirmPopup(self)
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

        if self.sellingMode then
            love.graphics.draw(self.shopBackground, love.graphics:getWidth() - self.shopBackground:getWidth(), 0)
            love.graphics.draw(self.merchantCorner, 0, love.graphics:getHeight() - self.merchantCorner:getHeight())

            for _, item in ipairs(self.shopItems) do
                item:draw()
            end

            love.graphics.draw(self.shopTitle, love.graphics:getWidth() - self.shopTitle:getWidth(), 0)

            setFont(24)
            love.graphics.print("MERCHANT", (love.graphics:getWidth() - (self.shopBackground:getWidth() / 2)) - (love.graphics.getFont():getWidth("MERCHANT") / 2), 18)
            resetFont()
        end
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

    if self.sellingMode then
        for _, item in pairs(self.shopItems) do
            item:mousepressed(x, y, button, istouch, presses)
        end
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

    if self.sellingMode then
        local minX = love.graphics:getWidth() - self.shopBackground:getWidth()
        local maxX = love.graphics:getWidth()
    
        if love.mouse.getX() > minX and love.mouse.getX() < maxX then
            if y > 0 then
                shopScrollOffset = shopScrollOffset + 20
    
                if shopScrollOffset > 0 then
                    shopScrollOffset = 0
                end
            elseif y < 0 then
                shopScrollOffset = shopScrollOffset - 20
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

        saveData()

        if #player.inventory.items == 20 then
            music.sfx.inventoryFullVoiceSFX:play()
        elseif #player.inventory.items >= 17 then
            music.sfx.inventoryGettingFullVoiceSFX:play()
        end
    else
        music.sfx.inventoryFullVoiceSFX:play()
    end
end

function Inventory:getRandomWeapon(minLevel, maxLevel)
    local weaponType = WEAPON_TYPES[love.math.random(1, 6)]
    local weaponCode = love.math.random(1, WEAPON_TYPE_QUANTITIES[weaponType])
    local weaponLevel = love.math.random(minLevel, maxLevel)

    return weaponType, weaponCode, weaponLevel
end