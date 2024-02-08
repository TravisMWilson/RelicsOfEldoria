textInstances = {}
textTimer = 0

currentColor = { r = 255/255, g = 255/255, b = 255/255, a = 255/255 }
currentFont = love.graphics.getFont()

function setColor(r, g, b, a)
    currentColor.r, currentColor.g, currentColor.b, currentColor.a = love.graphics.getColor()
    love.graphics.setColor(r, g, b, a)
end

function resetColor()
    love.graphics.setColor(currentColor.r, currentColor.g, currentColor.b, currentColor.a)
end

function setFont(scale)
    currentFont = love.graphics.getFont()
    love.graphics.setFont(love.graphics.newFont("Assets/Candarab.ttf", scale))
end

function resetFont()
    love.graphics.setFont(currentFont)
end

function displayText(message, maxScale, scaleSpeed, displayTime, color)
    table.insert(textInstances, {
        message = message,
        x = (love.graphics.getWidth() / 2) + math.random(-100, 100),
        y = (love.graphics.getHeight() / 2) + math.random(-100, 100),
        scale = 1,
        maxScale = maxScale,
        scaleSpeed = scaleSpeed,
        displayTime = displayTime,
        color = color,
        timer = 0,
        remove = false
    })
end

function updateText(dt)
    for i = #textInstances, 1, -1 do
        local instance = textInstances[i]
        instance.timer = instance.timer + dt

        if instance.scale < instance.maxScale and instance.timer <= instance.displayTime / 2 then
            instance.scale = instance.scale + instance.scaleSpeed * dt
        end

        if instance.scale > 1 and instance.timer > instance.displayTime / 2 then
            instance.scale = instance.scale - instance.scaleSpeed * dt
        end

        if instance.scale <= 1 then
            instance.remove = true
        end
    end

    for i = #textInstances, 1, -1 do
        if textInstances[i].remove then
            table.remove(textInstances, i)
        end
    end
end

function drawText()
    for _, instance in ipairs(textInstances) do
        local x = instance.x - love.graphics.getFont():getWidth(instance.message) / 2
        local y = instance.y - love.graphics.getFont():getHeight() / 2

        setColor(instance.color.r, instance.color.g, instance.color.b, instance.color.a)
        setFont(instance.scale)
        love.graphics.print(instance.message, x, y)
        resetFont()
        resetColor()
        love.graphics.origin()
    end
end