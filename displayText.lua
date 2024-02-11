DisplayText = Object:extend()

function DisplayText:new(message, maxScale, scaleSpeed, displayTime, color)
    self.message = message
    self.x = (love.graphics.getWidth() / 2) + love.math.random(-100, 100)
    self.y = (love.graphics.getHeight() / 2) + love.math.random(-100, 100)
    self.scale = 1
    self.maxScale = maxScale
    self.scaleSpeed = scaleSpeed
    self.displayTime = displayTime
    self.color = color
    self.timer = 0
    self.remove = false
    self.timer = 0
end

function DisplayText:update(dt)
    self.timer = self.timer + dt

    if self.scale < self.maxScale and self.timer <= self.displayTime / 2 then
        self.scale = self.scale + self.scaleSpeed * dt
    end

    if self.scale > 1 and self.timer > self.displayTime / 2 then
        self.scale = self.scale - self.scaleSpeed * dt
    end

    if self.scale <= 1 then
        self.remove = true
    end
end

function DisplayText:draw()
    local x = self.x - love.graphics.getFont():getWidth(self.message) / 2
    local y = self.y - love.graphics.getFont():getHeight() / 2

    setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    setFont(self.scale)
    love.graphics.print(self.message, x, y)
    resetFont()
    resetColor()
end