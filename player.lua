local c = require "constants"
local Hitter = require "hitter"

local Player = {
    type = "player",
    w = c.METER * 0.5,
    h = c.METER * 1,
    speed = c.METER * 7,
    max_jumps = 2,
}
Player.__index = Player

function Player.new(x, y, world)
    local self = setmetatable({
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        world = world,
        facing = "right",
        jump_count = 0,
    }, Player)

    world:add(self, self.x, self.y, self.w, self.h)

    return self
end

function Player:update(dt)
    self.vy = self.vy + c.METER * 10 * dt

    local goal_x = self.x + self.vx * dt
    local goal_y = self.y + self.vy * dt

    local actual_x, actual_y, cols, _ = self.world:move(self, goal_x, goal_y, self.move_filter)

    self.x = actual_x
    self.y = actual_y

    for _, col in pairs(cols) do
        if self.vy > 0 and goal_y > actual_y then
            self:land()
            self.vy = 0
        end
    end
end

function Player:move(dir)
    if dir == "right" then
        self.vx = self.speed
        self.facing = "right"
    end

    if dir == "left" then
        self.vx = -self.speed
        self.facing = "left"
    end

    if dir == "none" then
        self.vx = 0
    end
end

function Player:jump()
    if self.jump_count < self.max_jumps then
        self.vy = -self.speed
        self.jump_count = self.jump_count + 1
    end
end

function Player:hit()
    local x = self.x

    if self.facing == "left" then
        x = x - c.METER * 0.3
    end

    local hitter = Hitter.new(x, self.y - c.METER * 0.15, self.facing, self.world)
    return hitter
end

function Player:draw()
    love.graphics.setColor(0,0.2,1)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end

function Player:land()
    self.jump_count = 0
end

function Player.move_filter(item, other)
    if other.type == "ball" or other.type == "hitter" then
        return "cross"
    else
        return "slide"
    end
end

return Player