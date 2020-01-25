--- A ball that bounces around and has gravity.
--
-- classmod: Ball
-- see: Object
-- license: GPLv3
-- author: sayaks
-- copyright: sayaks 2020
local c = require "constants"
local class = require "libraries.middleclass"
local Object = require "classes.Object"
local mixins = require "classes.mixins"

local Ball = class("ball", Object)
Ball:include(mixins.Gravity)

Ball.RADIUS = c.METER * 0.11

--- Constructor for ball
-- number: x initial x coordinate
-- number: y initial y coordinate
-- number: vx initial x velocity
-- number: vy initial y velocity
-- !World: world the Bump world that the ball is in.
function Ball:initialize(x, y, vx, vy, world)
    Object.initialize(self, x, y, world, Ball.RADIUS * 2, Ball.RADIUS * 2, 1, 0.5, 0)
    self.vx = vx
    self.vy = vy
    self.type = "ball"
    self.radius = Ball.RADIUS
    world:add(self, x, y, self.radius * 2, self.radius * 2)
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

--- Draw the ball as an orange circle
function Ball:draw()
    love.graphics.setColor(self.r, self.g, self.b)
    love.graphics.circle("fill", self.x + self.radius, self.y + self.radius, self.radius)
end

--- Update the ball's position and velocity.
-- number: dt Time since last update.
function Ball:update(dt)
    self:apply_gravity(dt)
    local goal_x = self.x + self.vx * dt
    local goal_y = self.y + self.vy * dt

    local actual_x, actual_y, cols, _ = self.world:move(self, goal_x, goal_y, self.move_filter)

    self.x = actual_x
    self.y = actual_y

    for _, col in pairs(cols) do
        self:call_callback(col.other.type, col.other)

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

--- Spawn a hitter to hit the ball
-- string: dir Which direction to spawn the hitter in
function Ball:hit(dir, which)
    if which == "lob" then
        self.vx = 3.5 * c.METER
        self.vy = -7 * c.METER
    end

    if which == "long" then
        self.vx = 7 * c.METER
        self.vy = -3.5 * c.METER
    end

    if dir == "left" then
        self.vx = -self.vx
    end
end

return Ball