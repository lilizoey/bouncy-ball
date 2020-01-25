local c = require "constants"
local settings = require "settings_manager"

local module = {}

module.Gravity = {
    apply_gravity = function(self, dt)
        self.vy = self.vy + settings.get_setting("gravity") * dt
    end,
    included = function(mixin, klass)
        if not klass.vy then
            klass.vy = 0
        end
    end
}

return module