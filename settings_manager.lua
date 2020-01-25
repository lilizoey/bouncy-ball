local c = require "constants"
local Module = {}

Module.settings = {
    gravity = {type = type(c.METER * 12.5), value = c.METER * 12.5},
    menu_font_size = {type = type(22), value = 22}
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
end

return Module