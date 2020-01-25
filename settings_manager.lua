local c = require "constants"
local Module = {}

Module.settings = {
    gravity = {
        type = type(c.METER * 12.5),
        value = c.METER * 12.5,
        name = "Gravity",
        on_update = {},
    },
    menu_font_size = {
        type = type(22),
        value = 22,
        name = "Font Size",
        on_update = {},
    },
    jump_button = {
        type = type("up"), 
        value = "up",
        name = "Jump",
        on_update = {},
    },
    right_button = {
        type = type("right"),
        value = "right",
        name = "Right",
        on_update = {},
    },
    left_button = {
        type = type("left"),
        value = "left",
        name = "Left",
        on_update = {},
    },
    hit_button = {
        type = type("space"), 
        value = "space",
        name = "Hit",
        on_update = {},
    },
}

function Module.get_setting(name)
    if Module.settings[name] then
        return Module.settings[name].value
    else
        return nil
    end
end

function Module.set_setting(name, value)
    if not Module.settings[name] then
        return
    end

    if type(value) ~= Module.settings[name].type then
        return
    end

    Module.settings[name].value = value
    for _, fun in pairs(Module.settings[name].on_update) do
        fun(value)
    end
end

function Module.add_callback(name, fun)
    table.insert(Module.settings[name].on_update, fun)
end

return Module