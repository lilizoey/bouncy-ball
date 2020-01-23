local bump = require "libraries.bump"
local Ball = require "ball"
local AI = require "ai"
local Player = require "player"
local ScoreManager = require "score_manager"
local c = require "constants"

local world = bump.newWorld()

local ball = Ball.new(100, c.HEIGHT - 4 * c.METER, c.METER * 5, 0, world)

ball:register_callback("floor", function (other)
    if other.which == "left" then
        ScoreManager.score("right")
    elseif other.which == "right" then
        ScoreManager.score("left")
    end
end)

local left_wall = {type = "wall", which = "left"}
local left_floor = {type = "floor", which = "left"}
local right_wall = {type = "wall", which = "right"}
local right_floor = {type = "floor", which = "right"}
local divider =  {
    type = "divider",
    which = "all",
    x = c.WIDTH / 2 - (c.METER * 1 / 8),
    y = c.HEIGHT - c.METER * 1.5,
    w = c.METER / 4,
    h = c.METER * 1.5,
}
local player_divider = {
    type = "divider",
    which = "player",
    x = c.WIDTH / 2 - (c.METER * 1 / 8),
    y = 0,
    w = c.METER / 4,
    h = c.HEIGHT,
}

world:add(left_wall, -5, 0, 5, c.HEIGHT)
world:add(right_wall, c.WIDTH, 0, 5, c.HEIGHT)
world:add(left_floor, 0, c.HEIGHT, c.WIDTH / 2, 5)
world:add(right_floor, c.WIDTH / 2, c.HEIGHT, c.WIDTH / 2, 5)
world:add(divider, divider.x, divider.y, divider.w, divider.h)
world:add(player_divider, player_divider.x, player_divider.y, player_divider.w, player_divider.h)

local player = Player.new(10, 0, world)
local player2 = Player.new(c.WIDTH - 10 - Player.w, 0, world)

local hitters = {}

local function prune_hitters()
    for i = table.getn(hitters), 1, -1 do
        if hitters[i].hit then
            table.remove(hitters, i)
        end
    end
end

local ai = AI.new(player2, ball)

function love.load()
    love.window.setMode(c.WIDTH, c.HEIGHT)
    love.graphics.setFont(love.graphics.newFont(c.TEXT_SIZE))
end

function love.draw()
    ScoreManager.draw("left", 50, 50)
    ScoreManager.draw("right", c.WIDTH - 50, 50)
    player:draw()
    player2:draw()
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", divider.x, divider.y, divider.w, divider.h)
    for _, obj in pairs(hitters) do
        obj:draw()
    end
    ball:draw()
end

local timer = 0

function love.update(dt)
    timer = timer + dt
    while timer > c.TIMESTEP do
        prune_hitters()
        for _, obj in pairs(hitters) do
            obj:update(c.TIMESTEP)
        end
        local maybe_hitter = ai:update(c.TIMESTEP)
        ball:update(c.TIMESTEP)
        player:update(c.TIMESTEP)
        player2:update(c.TIMESTEP)
        if love.keyboard.isDown("left") then
            player:move("left")
        elseif love.keyboard.isDown("right") then
            player:move("right")
        else
            player:move("none")
        end
        timer = timer - c.TIMESTEP

        if maybe_hitter ~= nil then
            table.insert(hitters, maybe_hitter)
        end
    end
end

function love.keypressed(key)
    if key == "up" then
        player:jump()
    end
    if key == "space" then
        table.insert(hitters, player:hit())
    end
end