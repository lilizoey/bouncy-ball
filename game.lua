local Game = {}

local bump = require "libraries.bump"
local c = require "constants"
local Player = require "classes.Player"
local Ball = require "classes.Ball"
local AI = require "ai"
local score_manager = require "score_manager"

Game.world = bump.newWorld()

Game.gameobjects = {}
Game.terrain = {}
Game.timer = 0

Game.ai = nil
Game.player = nil

local function add_wall(x, y, w, h, type, which, invisible)
    local wall = {
        x = x,
        y = y,
        w = w,
        h = h,
        type = type,
        which = which,
        invisible = invisible
    }

    Game.world:add(wall, x, y, w, h)
    table.insert(Game.terrain, wall)
end

function Game.reset()
    Game.timer = 0
    Game.player = nil
    score_manager:reset()
    Game.world = bump.newWorld()

    Game.gameobjects = {}
    Game.terrain = {}

    add_wall(-5, 0, 5, c.HEIGHT, "wall", "left")
    add_wall(c.WIDTH, 0, 5, c.HEIGHT, "wall", "right")
    add_wall(0, c.HEIGHT, c.WIDTH / 2, 5, "floor", "left")
    add_wall(c.WIDTH / 2, c.HEIGHT, c.WIDTH / 2, 5, "floor", "right")
    add_wall(c.WIDTH / 2 - c.METER / 6, c.HEIGHT - c.METER * 1.5, c.METER / 3, c.METER * 1.5, "divider", "all")
    add_wall(c.WIDTH / 2 - c.METER / 6, 0, c.METER / 3, c.HEIGHT, "divider", "player", true)

    local player_1 = Player:new(c.METER / 2, c.HEIGHT - Player.h, Game.world)
    local player_2 = Player:new(c.WIDTH - c.METER / 2 - Player.w, c.HEIGHT - Player.h, Game.world)
    local ball = Ball:new((c.WIDTH / 2) - Ball.RADIUS, c.METER, 0, 0, Game.world)
    Game.ai = AI:new(player_2, ball, Game.gameobjects)

    ball:register_callback("floor", function (other)
        if other.which == "left" then
            score_manager.score("right")
        elseif other.which == "right" then
            score_manager.score("left")
        end
    end)

    Game.player = player_1

    table.insert(Game.gameobjects, player_1)
    table.insert(Game.gameobjects, player_2)
    table.insert(Game.gameobjects, ball)
end

function Game.load()
    Game.reset()
    love.graphics.setFont(love.graphics.newFont(c.TEXT_SIZE))
end

function Game.update(_, dt)
    Game.timer = Game.timer + dt

    while Game.timer > c.TIMESTEP do

        for _, obj in pairs(Game.gameobjects) do
            obj:update(c.TIMESTEP)
        end

        Game.player:key_down_handler()
        Game.ai:update(c.TIMESTEP)

        Game.timer = Game.timer - c.TIMESTEP
    end
end

function Game.draw(_)
    love.graphics.setBackgroundColor(0.3, 0.5, 0.9)
    love.graphics.setColor(0.2, 0.8, 0.2)
    love.graphics.rectangle("fill", 0, c.HEIGHT - c.METER * 0.8, c.WIDTH, c.METER * 0.8)

    for _, obj in pairs(Game.gameobjects) do
        obj:draw()
    end

    love.graphics.setColor(0.8, 0.8, 0.8)
    for _, obj in pairs(Game.terrain) do
        if not obj.invisible then
            love.graphics.rectangle("fill", obj.x, obj.y, obj.w, obj.h)
        end
    end

    score_manager.draw("left", 50, 50)
    score_manager.draw("right", c.WIDTH - 50, 50)
end

function Game.keypressed(_, key)
    Game.player:keypressed(key, Game.gameobjects)
end

return Game