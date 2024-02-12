dataLoaded = false

function updateData()
    if dataLoaded then
        if #player.inventory.items > 1 then
            local selectReplaced = false

            for i = 2, #player.inventory.items do
                if player.inventory.items[i].type ~= "Key" then
                    InventoryItem:equip(player.inventory.items[i])
                    selectReplaced = true
                    break
                end
            end

            if selectReplaced then
                table.remove(player.inventory.items, 1)
            end
        end

        if not player.listenedToOpeningScene then
            ui.showSkipMessage = true
        end

        player:updateExp()
    end
end

local function fileExists(filename)
    local fileInfo = love.filesystem.getInfo(filename)
    return fileInfo and fileInfo.type == "file"
end

local function split(str, delimiter)
    local result = {}

    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    
    return result
end

local function serializePlayerData()
    return string.format("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%s",
        player.enemiesKilled,
        player.healthPotions,
        player.chestsLooted,
        player.totalGold,
        player.relics,
        player.deaths,
        player.level,
        player.gold,
        player.exp,
        player.gameStartedTime,
        map.lowestLevel,
        tostring(player.listenedToOpeningScene)
    )
end

local function deserializePlayerData(dataString)
    local parts = {}

    for part in dataString:gmatch("[^,]+") do
        table.insert(parts, part)
    end

    player.enemiesKilled = tonumber(parts[1])
    player.healthPotions = tonumber(parts[2])
    player.chestsLooted = tonumber(parts[3])
    player.totalGold = tonumber(parts[4])
    player.relics = tonumber(parts[5])
    player.deaths = tonumber(parts[6])
    player.level = tonumber(parts[7])
    player.gold = tonumber(parts[8])
    player.exp = tonumber(parts[9])
    player.gameStartedTime = parts[10]
    map.lowestLevel = tonumber(parts[11])
    player.listenedToOpeningScene = parts[12] == "true"
end

local function serializeInventory()
    local items = {}

    for _, item in ipairs(player.inventory.items) do
        table.insert(items, string.format("%s,%d,%d", item.type, item.code, item.level))
    end

    return table.concat(items, ";")
end

local function deserializeInventory(dataString)
    for _, itemStr in ipairs(split(dataString, ";")) do
        local parts = split(itemStr, ",")
        table.insert(player.inventory.items, InventoryItem(parts[1], tonumber(parts[2]), tonumber(parts[3])))
    end
end

local function deserializeWaypoints(dataString)
    player.waypoints = {}

    for _, value in ipairs(split(dataString, ",")) do
        table.insert(player.waypoints, tonumber(value))
    end
end

local function serializeWaypoints()
    return string.format("%s", table.concat(player.waypoints, ","))
end

local function deserializeBosses(dataString)
    player.bossesDead = {}

    for _, value in ipairs(split(dataString, ",")) do
        table.insert(player.bossesDead, tonumber(value))
    end
end

local function serializeBosses()
    return string.format("%s", table.concat(player.bossesDead, ","))
end

function loadData()
    local filename = "RelicsOfEldoria_GameSave.txt"

    if fileExists(filename) then
        local contents, size = love.filesystem.read(filename)

        if contents then
            local data = split(contents, "|")
            deserializePlayerData(data[1])
            deserializeInventory(data[2])
            deserializeWaypoints(data[3])
            deserializeBosses(data[4])
            dataLoaded = true
        end
    end
end

function saveData()
    local playerData = serializePlayerData()
    local inventoryData = serializeInventory()
    local waypointData = serializeWaypoints()
    local bossesData = serializeBosses()
    local fileContent = playerData .. "|" .. inventoryData .. "|" .. waypointData .. "|" .. bossesData
    love.filesystem.write("RelicsOfEldoria_GameSave.txt", fileContent)
end