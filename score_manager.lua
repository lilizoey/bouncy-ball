--- A Score Managing Module
-- that keeps track of an arbitrary amount of scores and draws them to the
-- screen.
--
-- module: score_manager
-- license: GPLv3
-- author: sayaks
-- copyright: sayaks 2020

local Module = {}

local scores = {}

local function init_score(which)
    if not scores[which] then
        scores[which] = 0
    end
end

--- Add a point to a tracked player
-- string: which The player that got a point
function Module.score(which)
    init_score(which)

    scores[which] = scores[which] + 1
end

--- Draw a score to the screen.
-- Note that drawing at non-integer coordinates will give blurry text.
--
-- string: which The player whose score should be drawn
-- number: x
-- number: y
function Module.draw(which, x, y)
    init_score(which)
    love.graphics.setColor(1,1,1)
    love.graphics.print(scores[which], x, y, 0)
end

return Module