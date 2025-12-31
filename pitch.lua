-- pitch.lua
-- Handles drawing the football pitch and goals

local pitch = {}

-- ==============================
-- Pitch dimensions
-- ==============================
local pitchX, pitchY = 40, 40
local pitchW, pitchH = 1024 - 80, 576 - 80

pitch.x, pitch.y = pitchX, pitchY
pitch.w, pitch.h = pitchW, pitchH

-- ==============================
-- Draw the pitch
-- ==============================
function pitch.draw()
    -- Draw pitch background
    love.graphics.setColor(0.1, 0.5, 0.1)
    love.graphics.rectangle("fill", 0, 0, 1024, 576)

    -- Draw pitch border
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", pitchX, pitchY, pitchW, pitchH)

    -- Centre line
    love.graphics.line(pitchX + pitchW/2, pitchY, pitchX + pitchW/2, pitchY + pitchH)

    -- ==============================
    -- Penalty boxes
    -- ==============================
    local penaltyBoxW, penaltyBoxH = 120, pitchH * 0.6
    local sixYardBoxW, sixYardBoxH = 60, pitchH * 0.3

    -- Left penalty box
    love.graphics.rectangle("line", pitchX, pitchY + pitchH * 0.2, penaltyBoxW, penaltyBoxH)
    -- Right penalty box
    love.graphics.rectangle("line", pitchX + pitchW - penaltyBoxW, pitchY + pitchH * 0.2, penaltyBoxW, penaltyBoxH)

    -- Six-yard boxes
    love.graphics.rectangle("line", pitchX, pitchY + pitchH * 0.35, sixYardBoxW, sixYardBoxH)
    love.graphics.rectangle("line", pitchX + pitchW - sixYardBoxW, pitchY + pitchH * 0.35, sixYardBoxW, sixYardBoxH)

    -- ==============================
    -- Centre circle
    -- ==============================
    love.graphics.circle("line", pitchX + pitchW/2, pitchY + pitchH/2, 60)

    -- Penalty arcs
    love.graphics.arc("line", "open", pitchX + penaltyBoxW, pitchY + pitchH/2, 60, math.rad(-90), math.rad(90))
    love.graphics.arc("line", "open", pitchX + pitchW - penaltyBoxW, pitchY + pitchH/2, 60, math.rad(90), math.rad(270))

    -- Centre spot
    love.graphics.circle("fill", pitchX + pitchW/2, pitchY + pitchH/2, 5)

    -- Penalty spots
    love.graphics.circle("fill", pitchX + penaltyBoxW - 40, pitchY + pitchH/2, 5)
    love.graphics.circle("fill", pitchX + pitchW - penaltyBoxW + 40, pitchY + pitchH/2, 5)

    -- Corner arcs
    love.graphics.arc("line", "open", pitchX, pitchY, 20, math.rad(0), math.rad(90))
    love.graphics.arc("line", "open", pitchX, pitchY + pitchH, 20, math.rad(270), math.rad(360))
    love.graphics.arc("line", "open", pitchX + pitchW, pitchY, 20, math.rad(90), math.rad(180))
    love.graphics.arc("line", "open", pitchX + pitchW, pitchY + pitchH, 20, math.rad(180), math.rad(270))

    -- ==============================
    -- Goals
    -- ==============================
    local goalWidth, goalDepth, postW = 120, 30, 8
    local goalY = pitchY + pitchH/2 - goalWidth/2

    -- Draw nets (semi-transparent)
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.rectangle("fill", pitchX - goalDepth, goalY, goalDepth, goalWidth)        -- left net
    love.graphics.rectangle("fill", pitchX + pitchW, goalY, goalDepth, goalWidth)         -- right net

    -- Draw goal posts (solid)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", pitchX - postW, goalY, postW, goalWidth)              -- left posts
    love.graphics.rectangle("fill", pitchX + pitchW, goalY, postW, goalWidth)             -- right posts
end

return pitch
