local c = require "constants"
local class = require "libraries.middleclass"

local AI = class("ai")

function AI:initialize(player, ball)
    self.player = player
    self.ball = ball
    self.state = nil
end

function AI:update(dt)
    if self.state == nil then
        self.state = self.move_to_ball
    end

    return self:state()
end

function AI:move_to_ball()
    if math.abs(self.ball.x - self.player.x) < 10 then
        self.state = self.jump_towards_ball
    end

    if self.ball.x < self.player.x then
        self.player:move("left")
    elseif self.ball.x > self.player.x + self.player.w then
        self.player:move("right")
    end
end

function AI:jump_towards_ball()
    if self.ball.y + self.ball.radius * 2 > self.player.y - self.ball.radius * 1 then
        self.state = self.hit_ball
    elseif self.ball.vy > 0 then
        self.state = self.move_to_ball
    else
        self.player:jump()
        self.state = self.move_to_ball
    end
end

function AI:hit_ball()
    self.state = self.move_to_ball
    return self.player:hit()
end

return AI