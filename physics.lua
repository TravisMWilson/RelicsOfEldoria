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