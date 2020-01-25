--- A box that hits a ball away
-- classmod: Hitter
-- see: Object
-- license: GPLv3
-- author: sayaks
-- copyright: sayaks 2020

local c = require "constants"
local Object = require "classes.Object"
local class = require "libraries.middleclass"

local Hitter = class("hitter", Object)

--- Constructor for Hitter
-- number: x initial x coordinate
-- number: y initial y coordinate
-- string: dir which direction to hit the ball
-- !World: world the world that the hitter is in
function Hitter:initialize(x, y, dir, world, which)
    Object.initialize(self, x, y, world, c.METER * 0.8, c.METER * 0.8)
    self.type = "hitter"
    self.hit = false
    self.dir = dir
    self.timer = 0
    self.which = which

    world:add(self, x, y, self.w, self.h)
end

--- Update the state of a hitter
-- number: dt time since last update
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
            col.other:hit(self.dir, self.which)
        end
    end
end

function Hitter.move_filter(item, other)
    return "cross"
end

--- Flag the hitter for destruction
function Hitter:destroy()
    self.world:remove(self)
    self.hit = true
end

--- Draw a hitter to the screen
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