function checkLineCollision(x1, y1, x2, y2, x3, y3, x4, y4)
    local function orientation(x1, y1, x2, y2, x3, y3)
        return (y3 - y1) * (x2 - x1) > (y2 - y1) * (x3 - x1)
    end

    local o1 = orientation(x1, y1, x3, y3, x4, y4)
    local o2 = orientation(x2, y2, x3, y3, x4, y4)
    local o3 = orientation(x1, y1, x2, y2, x3, y3)
    local o4 = orientation(x1, y1, x2, y2, x4, y4)

    if o1 ~= o2 and o3 ~= o4 then
        return true
    end

    return false
end

function lineRectCollision(x1, y1, x2, y2, rectX, rectY, rectWidth, rectHeight)
    local function onSegment(px, py, qx, qy, rx, ry)
        return (qx <= math.max(px, rx) and qx >= math.min(px, rx) and qy <= math.max(py, ry) and qy >= math.min(py, ry))
    end

    local function orientation(px, py, qx, qy, rx, ry)
        local val = (qy - py) * (rx - qx) - (qx - px) * (ry - qy)
        if val == 0 then return 0 end
        return (val > 0) and 1 or 2
    end

    local function doCollide(p1x, p1y, q1x, q1y, p2x, p2y, q2x, q2y)
        local o1 = orientation(p1x, p1y, q1x, q1y, p2x, p2y)
        local o2 = orientation(p1x, p1y, q1x, q1y, q2x, q2y)
        local o3 = orientation(p2x, p2y, q2x, q2y, p1x, p1y)
        local o4 = orientation(p2x, p2y, q2x, q2y, q1x, q1y)

        if o1 ~= o2 and o3 ~= o4 then
            return true
        end

        if o1 == 0 and onSegment(p1x, p1y, p2x, p2y, q1x, q1y) then return true end
        if o2 == 0 and onSegment(p1x, p1y, q2x, q2y, q1x, q1y) then return true end
        if o3 == 0 and onSegment(p2x, p2y, p1x, p1y, q2x, q2y) then return true end
        if o4 == 0 and onSegment(p2x, p2y, q1x, q1y, q2x, q2y) then return true end

        return false
    end

    local rect = {x = rectX, y = rectY, width = rectWidth, height = rectHeight}

    return doCollide(x1, y1, x2, y2, rectX, rectY, rectX + rectWidth, rectY)
        or doCollide(x1, y1, x2, y2, rectX + rectWidth, rectY, rectX + rectWidth, rectY + rectHeight)
        or doCollide(x1, y1, x2, y2, rectX + rectWidth, rectY + rectHeight, rectX, rectY + rectHeight)
        or doCollide(x1, y1, x2, y2, rectX, rectY + rectHeight, rectX, rectY)
        or pointRectCollision(x1, y1, rect)
        or pointRectCollision(x2, y2, rect)
end

function pointRectCollision(x, y, rect)
    return x >= rect.x and x <= rect.x + rect.width and y >= rect.y and y <= rect.y + rect.height
end

function pointCircleCollision(px, py, cx, cy, radius)
    local dx = px - cx
    local dy = py - cy
    local distanceSquared = dx * dx + dy * dy
    local radiusSquared = radius * radius

    return distanceSquared <= radiusSquared
end

function distanceSquared(x1, y1, x2, y2)
    return (x2 - x1)^2 + (y2 - y1)^2
end

function pointLineDistance(x, y, x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    local d = dx * dx + dy * dy
    local t = ((x - x1) * dx + (y - y1) * dy) / d

    if t < 0 then
        return distanceSquared(x, y, x1, y1)
    elseif t > 1 then
        return distanceSquared(x, y, x2, y2)
    else
        local px, py = x1 + t * dx, y1 + t * dy
        return distanceSquared(x, y, px, py)
    end
end

function lineCircleCollision(x1, y1, x2, y2, cx, cy, radius)
    local d = pointLineDistance(cx, cy, x1, y1, x2, y2)
    return d <= radius * radius
end