--- A player that can move around and hit the ball.
--
-- classmod: Player
-- license: GPLv3
-- author: sayaks
-- copyright: sayaks 2020

local c = require "constants"
local Hitter = require "hitter"
local class = require "libraries.middleclass"

local Player = class("Player")

--- string: type What type of object this is
Player.type = "player"

--- number: w width
Player.w = c.METER * 0.5

--- number: h height
Player.h = c.METER * 1

--- number: speed The movement speed of a player.
Player.static.speed = c.METER * 7

--- int: max_jumps The maximum amount of jumps before a player has to land.
Player.static.max_jumps = 2

--- number: x x-coordinate
Player.x = nil

--- number: y y-coordinate
Player.y = nil

--- number: vx x-velocity
Player.vx = 0

--- number: vy y-velocity
Player.vy = 0

--- !World: world The world that contains the player.
Player.world = nil

--- string: facing Which direction the player is facing.
Player.facing = "right"

--- int: jump_count How many times the player has jumped since touching the ground.
Player.jump_count = 0

--- Constructor for the Player class
-- number: x x-coordinate
-- number: y y-coordinate
-- !World: world The world of the new player.
-- treturn: Player
function Player:initialize(x, y, world)
    self.x = x
    self.y = y
    self.world = world
    world:add(self, self.x, self.y, self.w, self.h)
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
        self.vx = Player.speed
        self.facing = "right"
    end

    if dir == "left" then
        self.vx = -Player.speed
        self.facing = "left"
    end

    if dir == "none" then
        self.vx = 0
    end
end

function Player:jump()
    if self.jump_count < Player.max_jumps then
        self.vy = -Player.speed
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