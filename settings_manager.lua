local c = require "constants"
local Module = {}

Module.settings = {
    version = 1,
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
    long_hit_button = {
        type = type("x"),
        value = "x",
        name = "Long Hit",
        on_update = {},
    },
    lob_hit_button = {
        type = type("c"),
        value = "c",
        name = "Lob Hit",
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

function Module.add_callback(name, fun)
    table.insert(Module.settings[name].on_update, fun)
end

local function serialize_setting(key, setting)
    local key_line = tostring(key) .. ":"
    local name_line = "\t" .. tostring(setting.name)
    local type_line = "\t" .. tostring(setting.type)
    local value_line = "\t" .. tostring(setting.value)
    return key_line .. "\n" .. name_line .. "\n" .. type_line .. "\n" .. value_line
end

local function serialize_settings()
    local serialized = tostring(Module.settings.version) .. "\n"
    for key, value in pairs(Module.settings) do
        if key ~= "version" then
            serialized = serialized .. serialize_setting(key, value) .. "\n"
        end
    end
    return serialized
end

local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function deserialize_settings(serialized)
    local new_settings = {}
    local current_key = nil
    local which = 1
    local version = false

    for setting in string.gmatch(serialized, "[^\n]+") do
        local trimmed = trim(setting)
        if not version then
            version = tonumber(trimmed)
            if version ~= Module.settings.version or not version then
                return Module.settings
            end
        else
            local i, j = string.find(trimmed, ":")
            if i == string.len(trimmed) then
                current_key = string.sub(trimmed, 1, i - 1)
                new_settings[current_key] = {}
                new_settings[current_key].on_update = {}
                which = 1
            elseif which == 2 then
                new_settings[current_key].name = trimmed
            elseif which == 3 then
                new_settings[current_key].type = trimmed
            elseif which == 4 then
                local curr_type = new_settings[current_key].type
                if curr_type == type("string") then
                    new_settings[current_key].value = trimmed
                elseif curr_type == type(22) then
                    new_settings[current_key].value = tonumber(trimmed)
                end
            end

            which = which + 1
        end
    end

    return new_settings
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

    Module.save()
end

function Module.save()
    love.filesystem.write("settings",serialize_settings())
end

function Module.load()
    local settings = love.filesystem.read("settings")
    if settings then
        Module.settings = deserialize_settings(settings)
    end
end

Module.load()

return Module