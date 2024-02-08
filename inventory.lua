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
    table.insert(self.items, InventoryItem("Sword", 1, 1))
    table.insert(self.items, InventoryItem("Staff", 1, 1))
    table.insert(self.items, InventoryItem("Spear", 1, 1))
    table.insert(self.items, InventoryItem("Hammer", 1, 1))
    table.insert(self.items, InventoryItem("Axe", 1, 1))
    self.items[1].selected = true

    self.maxItems = 20
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
    end
end

function Inventory:mousepressed(x, y, button, istouch, presses)
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
            print(inventoryScrollOffset)

            local maxHeight = (((ui.images.itemBackgound:getHeight() * 5) + ui.images.inventoryTitle:getHeight()) - love.graphics:getHeight()) * -1

            if inventoryScrollOffset < maxHeight then
                inventoryScrollOffset = maxHeight
            end
        end
    end
end

function Inventory:giveRandomWeapon(minLevel, maxLevel)
    if #player.inventory.items < player.inventory.maxItems then
        local weaponType = WEAPON_TYPES[math.random(1 ,6)]
        local weaponCode = math.random(1, WEAPON_TYPE_QUANTITIES[weaponType])
        local weaponLevel = math.random(minLevel, maxLevel)

        table.insert(player.inventory.items, InventoryItem(weaponType, weaponCode, weaponLevel))

        if #player.inventory.items == 20 then
            music:play(music.sfx.inventoryFullVoiceSFX)
        elseif #player.inventory.items >= 17 then
            music:play(music.sfx.inventoryGettingFullVoiceSFX)
        end
    else
        music:play(music.sfx.inventoryFullVoiceSFX)
    end
end