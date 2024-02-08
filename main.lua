--[[
    todo list:

    - stats will track time played, lowest dungeon level, enemies killed, chests looted
    - need a tutorial
    - bosses need special attacks
    - discorved Teleports are added to list to teleport back to
    - need to add a save/load
]]

local SCREEN_WIDTH = 1500
local SCREEN_HEIGHT = 750

function love.load()
    love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT)
    love.window.setTitle("Relics of Eldoria")

    Object = require "classic"
    require "button"
    require "player"
    require "enemy"
    require "Math"
    require "physics"
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
    drawText()
end

function love.update(dt)
    music:update(dt)
    player:update(dt)
    enemy:update(dt)
    ui:update(dt)
    updateText(dt)
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