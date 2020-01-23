--- A Score Managing Module
-- Keeps track of an arbitrary amount of scores and draws them to the screen.
--
-- module: score_manager
-- license: GPLv3
-- author: sayaks
-- copyright: sayaks 2020

local Module = {}

local scores = {}


function Module.init_score(which)
    if not scores[which] then
        scores[which] = 0
    end
end

function Module.score(which)
    Module.init_score(which)

    scores[which] = scores[which] + 1
end

function Module.draw(which, x, y)
    Module.init_score(which)
    love.graphics.print(scores[which], x, y, 0)
end

return Module