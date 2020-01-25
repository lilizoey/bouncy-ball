--- Classes for creating and managing menus
-- module: MenuModule
-- license: GPLv3
-- author: sayaks
-- copyright: sayaks 2020

local class = require "libraries.middleclass"
local settings = require "settings_manager"

local Module = {}

--- A menu of buttons
-- type: Menu
local Menu = class("menu")
Module.Menu = Menu

--- Constructor for a menu
-- number: x x coordinate
-- number: y y coordinate
-- number: w width of the menu
function Menu:initialize(x, y, w)
    self.x = x
    self.y = y
    self.w = w
    self.buttons = {}
    self.spacing = 10
end

--- Recreate the layout of the menu
function Menu:update_layout()
    local prev_bottom = self.y
    for _, button in pairs(self.buttons) do
        button:set_y(prev_bottom + self.spacing)
        prev_bottom = prev_bottom + button:get_height() + self.spacing
    end
end

--- Add another button with some text
-- string: text the text that the button will display
-- treturn: Button the newly created button
function Menu:add(text)
    local new_button = Module.Button:new(text, self.x, self.y, self.w)
    table.insert(self.buttons, new_button)
    self:update_layout()

    return new_button
end

--- Update the status of all the buttons in the menu
function Menu:update()
    for _, button in pairs(self.buttons) do
        button:update()
    end
end

--- Draw the menu
function Menu:draw()
    for _, button in pairs(self.buttons) do
        button:draw()
    end
end

--- Check if a button got pressed
function Menu:mousepressed(x, y, button)
    for _, menu_button in pairs(self.buttons) do
        menu_button:mousepressed(x, y, button)
    end
end

function Menu:keypressed(key)
    for _, menu_button in pairs(self.buttons) do
        (menu_button.keypressed or function () end)(menu_button, key)
    end
end

--- A button
-- type: Button
local Button = class("button")
Module.Button = Button

Button.static.font_size = settings.get_setting("menu_font_size")
Button.static.font = love.graphics.newFont(Button.font_size)

--- Constructor for buttons
-- string: text the text to display
-- number: x x coordinate of button
-- number: y y coordinate of button
-- number: w width
function Button:initialize(text, x, y, w)
    self.text = text
    self.x = x
    self.y = y
    self.w = w
    self.centered = true
    self.selected = false
end

--- Calculate the height of the button
-- return: number
function Button:get_height()
    return Button.font:getHeight() + 10
end

function Button:set_x(x)
    self.x = x
end

function Button:set_y(y)
    self.y = y
end

--- Draw the button centered
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

function Button.update_font(value)
    Button.static.font = love.graphics.newFont(value)
end

settings.add_callback("menu_font_size", Button.update_font)

function Button:update_selected()
    local x, y = love.mouse.getPosition()

    self.selected =  self:in_bounds(x, y)
end

--- update the status of the button
-- number: dt time since last update
function Button:update(dt)
    self:update_selected()
end

function Button:in_bounds(x, y)
    return x > self.x and
    x < self.x + self.w and
    y > self.y and
    y < self.y + self:get_height()
end

--- Check if the mousepress clicks the button, only responds to left click
-- number: x x coordinate
-- number: y y coordinate
-- int: button which button was clicked
function Button:mousepressed(x, y, button)
    if self:in_bounds(x, y) and button == 1 and self.onclick then
        self.onclick()
    end
end

--- Register a callback for when the button is clicked
-- !function: fun callback 
function Button:register_onclick(fun)
    self.onclick = fun
end

-- button #2

KeyButton = class("keybutton", Button)
Module.KeyButton = KeyButton

function KeyButton:initialize(action, x, y, w)
    Button.initialize(self, action .. ": " .. settings.get_setting(action .. "_button"), x, y, w)
    self.action = action
    self.key_change = false
    settings.add_callback(action .. "_button", function (v) self:update_text(v) end)
end

function KeyButton:update()
    Button.update(self)
    --print(self.action, self.key_change, self.selected)
end

function KeyButton:change_key(new_key)
    settings.set_setting(self.action .. "_button", new_key)
end

function KeyButton:mousepressed(x, y, button)
    if self:in_bounds(x, y) and button == 1 and self.key_change == false then
        self.key_change = true
    elseif button == 1 and self.key_change == true then
        self.key_change = false
    end
end

function KeyButton:keypressed(key)
    print(key, self.key_change)
    if self.key_change then
        self:change_key(key)
        self.key_change = false
    end
end

function KeyButton:update_text(val)
    self.text = self.action .. ": " .. val
end

return Module