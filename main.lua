local Game = require "game"
local c = require "constants"
local MenuModule = require "classes.Menu"
local settings = require "settings_manager"
local menus = require "menus"
local state = {}

local empty = function (...) end

local function switch_state(new_state)
    (state.leave or empty)()
    state = new_state;
    (state.load or empty)()
end

menus.initialize(switch_state)

function love.load()
    love.window.setMode(c.WIDTH, c.HEIGHT)
    switch_state(menus.main_menu)
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