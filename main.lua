--[[
    todo list:

    - need a tutorial
    - need to add a save/load
]]

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

    music = Music()
    ui = UI()
    map = Map()
    player = Player()
    enemy = Enemy()
end

function love.draw()
    map:draw()
    enemy:draw()
    player:draw()
    ui:draw()
end

function love.update(dt)
    map:update(dt)
    music:update(dt)
    player:update(dt)
    enemy:update(dt)
    ui:update(dt)
end

function love.mousepressed(x, y, button, istouch, presses)
    player:mousepressed(x, y, button, istouch, presses)
    ui:mousepressed(x, y, button, istouch, presses)
    map:mousepressed(x, y, button, istouch, presses)
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