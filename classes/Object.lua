--- Abstract superclass of all Game Objects
--
-- classmod: Object
-- license: GPLv3
-- author: sayaks
-- copyright: sayaks 2020
local class = require "libraries.middleclass"
local Object = class("Object")

--- Constructor for Objects
-- number: x x-coordinate
-- number: y y-coordinate
-- !World: world The world the object is in.
-- number: w width
-- number: h height
-- ?number: r red color for drawing
-- ?number: g green color for drawing
-- ?number: b blue color for drawing
function Object:initialize(x, y, world, w, h, r, g, b)
    self.x = x
    self.y = y
    self.world = world
    self.h = h
    self.w = w
    self.callbacks = {}
    self.r = r or 1.0
    self.g = g or 1.0
    self.b = b or 1.0
end

--- Get the height of an object
-- return: number Height
function Object:get_height()
    return self.h
end

--- Get the width of an object
-- return: number Width
function Object:get_width()
    return self.w
end

--- Get the x-coordinate of an object
-- return: number x-coordinate
function Object:get_x()
    return self.x
end

--- Get the y-coordinate of an object
-- return: number y-coordinate
function Object:get_y()
    return self.y
end

--- Register a callback with a name
-- string: name The name of the callback
-- !function: fun The function to be called
function Object:register_callback(name, fun)
    self.callbacks[name] = fun
end

--- Call a named callback function if it exists
-- string: name Name of callback to call
-- param: ... Arguments to be passed to callback
function Object:call_callback(name, ...)
    if self.callbacks[name] then
        self.callbacks[name](...)
    end
end

--- Fallback drawing method, draws a rectangle.
function Object:draw()
    love.graphics.setColor(self.r,self.g,self.b)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end

return Object