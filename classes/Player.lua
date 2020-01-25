--- A player that can move around and hit the ball. Subclass of Object.
--
-- see: Object
-- classmod: Player
-- license: GPLv3
-- author: sayaks
-- copyright: sayaks 2020

local c = require "constants"
local Hitter = require "classes.Hitter"
local class = require "libraries.middleclass"
local Object = require "classes.Object"
local mixins = require "classes.mixins"
local settings = require "settings_manager"

local Player = class("Player", Object)
Player:include(mixins.Gravity)

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
    Object.initialize(self, x, y, world, Player.w, Player.h, 0, 0.2, 0.8)
    world:add(self, x, y, Player.w, Player.h)
end

--- Update the state of the player one timestep
-- number: dt Time since last update
function Player:update(dt)
    self:apply_gravity(dt)

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

--- Make the player move in a direction
-- string: dir Direction to move
--   accepts:
--     * "left" to move left
--     * "right" to move right
--     * "none" to move in no direction
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

--- Make the player jump
function Player:jump()
    if self.jump_count < Player.max_jumps then
        self.vy = -Player.speed
        self.jump_count = self.jump_count + 1
    end
end

--- Make the player try to hit the ball
function Player:hit()
    local x = self.x

    if self.facing == "left" then
        x = x - c.METER * 0.3
    end

    local hitter = Hitter:new(x, self.y - c.METER * 0.15, self.facing, self.world)
    return hitter
end

--- Tell the player it has landed
function Player:land()
    self.jump_count = 0
end

--- Filter for the move function, see bump library for information
function Player.move_filter(item, other)
    if other.type == "ball" or other.type == "hitter" then
        return "cross"
    else
        return "slide"
    end
end

--- Choose what action to take depending on a keypress
-- string: key which key was pressed
-- Array(Object): object_table table of objects to insert a hitter into
function Player:keypressed(key, object_table)
    if key == settings.get_setting("jump_button") then
        self:jump()
    end

    if key == settings.get_setting("hit_button") then
        table.insert(object_table, self:hit())
    end
end

--- Check if a key is down and respond correspondingly
function Player:key_down_handler()
    local left = love.keyboard.isDown(settings.get_setting("left_button"))
    local right = love.keyboard.isDown(settings.get_setting("right_button"))
    if left and right or not (left or right) then
        self:move("none")
    elseif left then
        self:move("left")
    else
        self:move("right")
    end
end

return Player