local c = require "constants"

local Ball = {
    type = "ball",
    mass = 1,
    r = c.METER * 0.11,
}
Ball.__index = Ball

function Ball.new(x, y, vx, vy, world)
    local self = setmetatable({
        x = x,
        y = y,
        vx = vx,
        vy = vy,
        world = world,
        callbacks = {}
    }, Ball)

    world:add(self, x, y, self.r * 2, self.r * 2)

    return self
end

function Ball.move_filter(_, other)
    if other.type == "player" or
       other.type == "hitter" or
       other.which == "player" then
        return "cross"
    else
        return "bounce"
    end
end

function Ball:draw()
    love.graphics.setColor(1,0.5,0)
    love.graphics.circle("fill", self.x + self.r, self.y + self.r, self.r)
end

function Ball:update(dt)
    self.vy = self.vy + c.METER * 10 * dt
    local goal_x = self.x + self.vx * dt
    local goal_y = self.y + self.vy * dt

    local actual_x, actual_y, cols, _ = self.world:move(self, goal_x, goal_y, self.move_filter)

    self.x = actual_x
    self.y = actual_y

    for _, col in pairs(cols) do
        if self.callbacks[col.other.type] then
            self.callbacks[col.other.type](col.other)
        end

        if col.other.type == "wall" then
            self.vx = -self.vx
        end

        if self.vy > 0 and col.other.type == "floor" then
            self.vy = -self.vy
        end

        if col.other.type == "divider" and col.other.which ~= "player" then
            if self.vy > 0 and actual_y < goal_y then
                self.vy = -self.vy
            else
                self.vx = -self.vx
            end
        end
    end
end

function Ball:hit(dir)
    if dir == "left" then
        self.vx = -7 * c.METER
        self.vy = -3.5 * c.METER
    elseif dir == "right" then
        self.vx =  7 * c.METER
        self.vy = -3.5 * c.METER
    end
end

function Ball:register_callback(type, fun)
    self.callbacks[type] = fun
end

return Ball