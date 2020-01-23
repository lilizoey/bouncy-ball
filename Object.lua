local class = require "libraries.middleclass"
local Object = class("Object")

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

function Object:get_height()
    return self.h
end

function Object:get_width()
    return self.w
end

function Object:get_x()
    return self.x
end

function Object:get_y()
    return self.y
end

function Object:register_callback(name, fun)
    self.callbacks[name] = fun
end

function Object:call_callback(name, ...)
    if self.callbacks[name] then
        self.callbacks[name](...)
    end
end

function Object:draw()
    love.graphics.setColor(self.r,self.g,self.b)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end

return Object