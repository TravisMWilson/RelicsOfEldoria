Waypoint = Object:extend()

function Waypoint:new(level)
    self.image = ui.images.waypointUI
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.level = level

    self.x = (love.graphics:getWidth() / 2) - (self.width / 2)
    self.y = 0
end

function Waypoint:draw(offset)
    self.y = 0 + offset
    love.graphics.draw(self.image, self.x, self.y)

    setColor(163/255, 225/255, 236/255, 1)
    setFont(36)
    love.graphics.print(self.level, self.x + 68, self.y + 25)
    resetFont()
    resetColor()
end

function Waypoint:mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        if pointRectCollision(x, y, self) then
            if currentLevel ~= self.level then
                player:teleport(self.level)
            else
                music.sfx.alreadyThereVoiceSFX:play()
            end
        end
    end
end