Button = Object:extend()

function Button:new(x, y, image, action)
    self.x = x
    self.y = y
    self.action = action
    self.visible = false

    self.r = 1
    self.g = 1
    self.b = 1
    self.a = 1

    self.filePath = image
    self.image = love.graphics.newImage(image)
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
end

function Button:draw()
    if self.visible then
        setColor(self.r, self.g, self.b, self.a)
        love.graphics.draw(self.image, self.x, self.y)
        resetColor()
    end
end

function Button:mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        if pointRectCollision(x, y, self) and self.visible then
            self.action()
        end
    end
end

function Button:setColor(r, g, b, a)
    self.r = r
    self.g = g
    self.b = b
    self.a = a
end