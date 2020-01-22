local c = require "constants"

local AI = {}
AI.__index = AI

function AI.new(player, ball)
    local self = setmetatable({
        player = player,
        ball = ball,
        state = nil
    }, AI)

    return self
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
    if self.ball.y + self.ball.r * 2 > self.player.y then
        self.state = self.hit_ball
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