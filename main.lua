local Game = require "game"
local c = require "constants"
local MenuModule = require "classes.Menu"
local settings = require "settings_manager"
local state = Game

local empty = function (...) end

local function switch_state(new_state)
    (state.leave or empty)()
    state = new_state;
    (state.load or empty)()
end

local main_menu = MenuModule.Menu:new(c.WIDTH / 2 - 100, 100, 200)

main_menu:add("Easy Game"):register_onclick(function ()
    settings.set_setting("gravity", c.METER * 10)
    switch_state(Game)
end)

main_menu:add("Normal Game"):register_onclick(function () switch_state(Game) end)

main_menu:add("Hard Game"):register_onclick(function ()
    settings.set_setting("gravity", c.METER * 15)
    switch_state(Game)
end)

function love.load()
    love.window.setMode(c.WIDTH, c.HEIGHT)
    switch_state(main_menu)
end

function love.update(dt)
    (state.update or empty)(state, dt)
end

function love.draw()
    (state.draw or empty)(state)
end

function love.keypressed(key)
    (state.keypressed or empty)(state, key)
end

function love.mousepressed(x, y, button, istouch, pressed)
    (state.mousepressed or empty)(state, x, y, button, istouch, pressed)
end