local class = require "libraries.middleclass"
local settings = require "settings_manager"

local Module = {}

local Menu = class("menu")
Module.Menu = Menu

--- Constructor for a menu
-- Array(Button): buttons a list of all buttons
function Menu:initialize(x, y, w)
    self.x = x
    self.y = y
    self.w = w
    self.buttons = {}
    self.spacing = 10
end

function Menu:update_layout()
    local prev_bottom = self.y
    for _, button in pairs(self.buttons) do
        button:set_y(prev_bottom + self.spacing)
        prev_bottom = prev_bottom + button:get_height() + self.spacing
    end
end

function Menu:add(text)
    local new_button = Module.Button:new(text, self.x, self.y, self.w)
    table.insert(self.buttons, new_button)
    self:update_layout()

    return new_button
end

function Menu:update()
    for _, button in pairs(self.buttons) do
        button:update()
    end
end

function Menu:draw()
    for _, button in pairs(self.buttons) do
        button:draw()
    end
end

function Menu:mousepressed(x, y, button)
    for _, menu_button in pairs(self.buttons) do
        menu_button:mousepressed(x, y, button)
    end
end

-- buttons

local Button = class("button")
Module.Button = Button

Button.static.font_size = settings.get_setting("menu_font_size")
Button.static.font = love.graphics.newFont(Button.font_size)

function Button:initialize(text, x, y, w)
    self.text = text
    self.x = x
    self.y = y
    self.w = w
    self.centered = true
    self.selected = false
end

function Button:get_height()
    return Button.font:getHeight() + 10
end

function Button:set_x(x)
    self.x = x
end

function Button:set_y(y)
    self.y = y
end

function Button:draw()
    if self.selected then
        love.graphics.setColor(0.7, 0.7, 0.7)
    else
        love.graphics.setColor(0.4, 0.4, 0.4)
    end

    love.graphics.rectangle("fill", self.x, self.y, self.w, self:get_height())
    love.graphics.setColor(1,1,1)
    love.graphics.print(
        self.text,
        Button.font,
        love.math.newTransform(
            -- Center the text, rounding because non-integer text is blurry
            math.floor((self.x + self.w / 2) - Button.font:getWidth(self.text) / 2),
            self.y + 5
        )
    )
end

function Button.update_font()
    if Button.font_size ~= settings.get_setting("menu_font_size") then
        Button.static.font_size = settings.get_setting("menu_font_size")
        Button.static.font = love.graphics.newFont(Button.font_size)
    end
end

function Button:update_selected()
    local x, y = love.mouse.getPosition()

    self.selected =  self:in_bounds(x, y)
end

function Button:update(dt)
    Button.update_font()
    self:update_selected()
end

function Button:in_bounds(x, y)
    return x > self.x and
    x < self.x + self.w and
    y > self.y and
    y < self.y + self:get_height()
end

function Button:mousepressed(x, y, button)
    if self:in_bounds(x, y) and button == 1 and self.onclick then
        self.onclick()
    end
end

function Button:register_onclick(fun)
    self.onclick = fun
end

return Module