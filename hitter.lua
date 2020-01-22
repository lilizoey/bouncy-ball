local c = require "constants"

local Hitter = {
    type = "hitter",
    w = c.METER * 0.8,
    h = c.METER * 0.8,
}
Hitter.__index = Hitter

function Hitter.new(x, y, dir, world)
    local self = setmetatable({
        hit = false,
        x = x,
        y = y,
        dir = dir,
        world = world,
        timer = 0,
    }, Hitter)

    world:add(self, x, y, self.w, self.h)

    return self
end

function Hitter:update(dt)
    if self.hit then
        return
    end

    self.timer = self.timer + dt

    if self.timer > c.HITTER_TIMEOUT then
        self:destroy()
        return
    end

    local x, y, cols, len = self.world:move(self, self.x, self.y, self.move_filter)

    for _, col in pairs(cols) do
        if col.other.type == "ball" then
            self:destroy()
            col.other:hit(self.dir)
        end
    end
end

function Hitter.move_filter(item, other)
    return "cross"
end

function Hitter:destroy()
    self.world:remove(self)
    self.hit = true
end

function Hitter:draw()
    if self.hit then
        return
    end
    if self.dir == "left" then
        love.graphics.setColor(1,0,0)
    elseif self.dir == "right" then
        love.graphics.setColor(0,1,0)
    end

    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end

return Hitter