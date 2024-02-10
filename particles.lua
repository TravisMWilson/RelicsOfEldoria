Particles = Object:extend()

function Particles:new(x, y, emissionRate, lifetime, areaSize, speed, radialAccelMax, linearDamping, directionRad, spreadRad, startSize, midSize, endSize, sizeVariation, spin, tanAccel, image)
    self.image = love.graphics.newImage(image)
  
    self.pSystem = love.graphics.newParticleSystem(self.image, 20000)
    
    self.pSystem:setEmissionRate(emissionRate)
    self.pSystem:setParticleLifetime(lifetime * 0.5, lifetime)
    self.pSystem:setEmissionArea("normal", areaSize, areaSize)

    self.pSystem:setSpeed(speed * 0.5, speed)
    self.pSystem:setRadialAcceleration(radialAccelMax * 0.5, radialAccelMax)
    self.pSystem:setLinearDamping(linearDamping * 0.5, linearDamping)

    self.pSystem:setDirection(-directionRad)
    self.pSystem:setSpread(spreadRad)

    self.pSystem:setSizes(startSize, midSize, endSize)
    self.pSystem:setSizeVariation(sizeVariation)

    self.pSystem:setSpin(spin * 0.5, spin)
    self.pSystem:setTangentialAcceleration(tanAccel * 0.5, tanAccel)

    self.x = x
    self.y = y
end

function Particles:update(dt)
    self.pSystem:update(dt)
end

function Particles:draw()
    love.graphics.draw(self.pSystem, self.x, self.y)
end

function Particles:setColor(r1, g1, b1, a1, r2, g2, b2, a2, ...)
    local thirdColor = {...}

    if #thirdColor > 0 then
        self.pSystem:setColors(
            r1, g1, b1, a1,
            r2, g2, b2, a2,
            thirdColor[1], thirdColor[2], thirdColor[3], thirdColor[4]
        )
    else
        self.pSystem:setColors(
            r1, g1, b1, a1,
            r2, g2, b2, a2
        )
    end
end