function getDistance(pos1, pos2)
    return math.sqrt((pos2.x - pos1.x)^2 + (pos2.y - pos1.y)^2)
end

function getDirection(pos1, pos2)
    local distance = getDistance(pos1, pos2)
    return {
        x = (pos2.x - pos1.x) / distance,
        y = (pos2.y - pos1.y) / distance
    }
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end