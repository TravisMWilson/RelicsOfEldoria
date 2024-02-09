Waypoint = Object:extend()

function Waypoint:new(level)
    self.image = ui.images.waypointUI
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.level = level

    self.x = (love.graphics:getWidth() / 2) - (self.width / 2)
    self.y = (love.graphics:getHeight() / 2) - (self.height / 2)

    self.options = {
        ClickArea(self.x + 147, self.y + 12, 145, 29, "Yes"),
        ClickArea(self.x + 147, self.y + 42, 145, 29, "No")
    }
end

function Waypoint:draw()
    love.graphics.draw(self.image, self.x, self.y)
end

function Waypoint:mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        for _, option in ipairs(self.options) do
            if pointRectCollision(x, y, option) then
                self.answer = option.action
            end
        end
    end
end