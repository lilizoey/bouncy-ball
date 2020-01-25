local MenuModule = require "classes.Menu"
local c = require "constants"
local Game = require "game"
local settings = require "settings_manager"

local Module = {}

function Module.initialize(switch_state_fun)
    Module.switch_state = switch_state_fun
end

Module.main_menu = MenuModule.Menu:new(
    c.WIDTH / 2 - 100,
    100,
    200
)

Module.main_menu:add("Easy"):register_onclick(function ()
    settings.set_setting("gravity", c.METER * 10)
    Module.switch_state(Game)
end)

Module.main_menu:add("Medium"):register_onclick(function ()
    settings.set_setting("gravity", c.METER * 12.5)
    Module.switch_state(Game)
end)

Module.main_menu:add("Hard"):register_onclick(function ()
    settings.set_setting("gravity", c.METER * 15)
    Module.switch_state(Game)
end)

Module.main_menu:add("Settings"):register_onclick(function ()
    Module.switch_state(Module.settings)
end)

Module.settings = MenuModule.Menu:new(
    c.WIDTH / 2 - 200,
    100,
    400,
    2
)

Module.settings:add("Back"):register_onclick(function ()
    Module.switch_state(Module.main_menu)
end)

Module.settings:add_button(MenuModule.KeyButton:new("jump"))
Module.settings:add_button(MenuModule.KeyButton:new("left"))
Module.settings:add_button(MenuModule.KeyButton:new("right"))
Module.settings:add_button(MenuModule.KeyButton:new("long_hit"))
Module.settings:add_button(MenuModule.KeyButton:new("lob_hit"))

return Module