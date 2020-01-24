local c = require "constants"

local module = {}

module.Gravity = {
    apply_gravity = function(self, dt)
        self.vy = self.vy + c.METER * 15 * dt
    end,
    included = function(mixin, klass)
        if not klass.vy then
            klass.vy = 0
        end
    end
}

return module