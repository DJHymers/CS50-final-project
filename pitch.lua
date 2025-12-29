-- pitch.lua
local pitch = {}

local pitchX = 40
local pitchY = 40
local pitchW = 1024 - 80
local pitchH = 576 - 80

pitch.x = pitchX 
pitch.y = pitchY 
pitch.w = pitchW 
pitch.h = pitchH

function pitch.draw()
    -- Draw pitch background
    love.graphics.setColor(0.1, 0.5, 0.1)
    love.graphics.rectangle("fill", 0, 0, 1024, 576)

    -- Draw pitch border
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", 40, 40, 1024 - 80, 576 - 80)

    -- Draw centre line
    love.graphics.line(512, 40, 512, 576 - 40)

    -- Draw penalty boxes
    love.graphics.rectangle("line",
    pitchX,
    pitchY + pitchH * 0.2,
    120,
    pitchH * 0.6)

    love.graphics.rectangle("line",
    pitchX + pitchW - 120,
    pitchY + pitchH * 0.2,
    120,
    pitchH * 0.6)

    -- Draw six yard box
    love.graphics.rectangle("line",
    pitchX,
    pitchY + pitchH * 0.35,
    60,
    pitchH * 0.3)

    love.graphics.rectangle("line",
    pitchX + pitchW - 60,
    pitchY + pitchH * 0.35,
    60,
    pitchH * 0.3)

    -- Draw centre circle
    love.graphics.circle("line",
    pitchX + pitchW / 2,
    pitchY + pitchH / 2,
    60)

    -- Penalty box semi circles
    love.graphics.arc("line",
    "open",
    pitchX + 120,            
    pitchY + pitchH / 2,              
    60,                               
    math.rad(-90),                    
    math.rad(90)                      
    )

    love.graphics.arc("line",
    "open",
    pitchX + pitchW - 120,
    pitchY + pitchH / 2,
    60,
    math.rad(90),
    math.rad(270)
    )

    -- Centre spot
    love.graphics.circle("fill",
    pitchX + pitchW / 2,
    pitchY + pitchH / 2,
    5
    )

    -- Penalty spots
    love.graphics.circle("fill",
    pitchX + 120 - 40,         
    pitchY + pitchH / 2,
    5
    )

    love.graphics.circle("fill",
    pitchX + pitchW - 120 + 40,
    pitchY + pitchH / 2,
    5
    )

    -- Corner arcs
    love.graphics.arc("line", "open",
    pitchX, pitchY,
    20,
    math.rad(0),
    math.rad(90)
    )

    love.graphics.arc("line", "open",
    pitchX, pitchY + pitchH,
    20,
    math.rad(270),
    math.rad(360)
    )

    love.graphics.arc("line", "open",
    pitchX + pitchW, pitchY,
    20,
    math.rad(90),
    math.rad(180)
    )

    love.graphics.arc("line", "open",
    pitchX + pitchW, pitchY + pitchH,
    20,
    math.rad(180),
    math.rad(270)
    )

end

return pitch