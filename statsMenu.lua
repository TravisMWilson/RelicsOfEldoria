StatsMenu = Object:extend()

function StatsMenu:new()
    self.open = false

    self.background = ui.images.scrollMenu
    self.width = self.background:getWidth()
    self.height = self.background:getHeight()

    self.x = (love.graphics:getWidth() / 2) - (self.background:getWidth() / 2)
    self.y = 0

    self.characterCount = 1
end

function StatsMenu:draw()
    if self.open then
        local timeDifference = os.time() - player.gameStartedTime
        local days = math.floor(timeDifference / (24 * 60 * 60))
        local hours = math.floor((timeDifference % (24 * 60 * 60)) / (60 * 60))
        local minutes = math.floor((timeDifference % (60 * 60)) / 60)

        local text = "- I started my journey:\n" .. days .. " days, " .. hours .. " hours, " .. minutes .. " minutes ago\n"
                    .. "- Lowest dungeon level is " .. map.lowestLevel .. "\n"
                    .. "- Killed " .. player.enemiesKilled .. " creatures\n"
                    .. "- Looted " .. player.chestsLooted .. " chests\n"
                    .. "- Gained a total of " .. player.totalGold .. " gold\n"
                    .. "... but only have " .. player.gold .. " left, how sad..."

        self.characterCount = self.characterCount + 1

        love.graphics.draw(self.background, self.x, self.y)

        setColor(0, 0, 0, 1)
        setFont(20, "Assets/segoeprb.ttf")
        love.graphics.print(
            string.sub(text, 1, self.characterCount),
            self.x + 150,
            self.y + 225
        )
        resetFont()
        resetColor()
    end
end
