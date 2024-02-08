ClickArea = Object:extend()

function ClickArea:new(x, y, width, height, action, ...)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.action = action
    self.parameter = {...}
end