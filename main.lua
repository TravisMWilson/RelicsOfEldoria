startTime = os.time()

function stopwatch(text)
    if os.time() - startTime > 1 then
        print(text .. " - " .. os.time() - startTime)
    end

    startTime = os.time()
end

function love.load()
    Object = require "classic"
    require "blockAttack"
    require "circleAttack"
    require "particles"
    require "button"
    require "waypoint"
    require "confirmPopup"
    require "player"
    require "enemy"
    require "Math"
    require "physics"
    require "statsMenu"
    require "displayText"
    require "clickArea"
    require "map"
    require "room"
    require "music"
    require "ui"
    require "inventory"
    require "inventoryItem"
    require "shopItem"
    require "data"

    music = Music()
    ui = UI()
    map = Map()
    player = Player()
    enemy = Enemy()

    loadData()
    updateData()
end

function love.draw()
    map:draw()
    enemy:draw()
    player:draw()
    ui:draw()
end

function love.update(dt)
    map:update(dt)
    --stopwatch("map update")
    music:update(dt)
    --stopwatch("music update")

    if not player.playingTutorial then
        player:update(dt)
        --stopwatch("player update")
        enemy:update(dt)
        --stopwatch("enemy update")
    end

    ui:update(dt)
    --stopwatch("ui update")
end

function love.mousepressed(x, y, button, istouch, presses)
    if not player.playingTutorial then
        player:mousepressed(x, y, button, istouch, presses)
        --stopwatch("player mousepressed")
        ui:mousepressed(x, y, button, istouch, presses)
        --stopwatch("ui mousepressed")
        map:mousepressed(x, y, button, istouch, presses)
        --stopwatch("map mousepressed")
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    player:mousemoved(x, y, dx, dy, istouch)
end

function love.keypressed(key)
    player:keypressed(key)
end

function love.wheelmoved(x, y)
    player:wheelmoved(x, y)
end

function love.quit()
    saveData()
end