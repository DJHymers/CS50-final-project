-- score.lua
-- Handles player and opponent scores and drawing

local score = {}

-- ==============================
-- Score values
-- ==============================
score.player = 0
score.opponent = 0

-- Font for displaying score
score.font = love.graphics.newFont(24)

-- Flag for optional effects when someone scores
score.justScored = false

-- ==============================
-- Add a point to the given player
-- who: "player" or "opponent"
-- ==============================
function score.add(who)
    if who == "player" then
        score.player = score.player + 1
    elseif who == "opponent" then
        score.opponent = score.opponent + 1
    end

    -- Can be used to trigger animations or sounds
    score.justScored = true
end

-- ==============================
-- Draw the score on screen
-- ==============================
function score.draw()
    love.graphics.setFont(score.font)
    love.graphics.setColor(1, 1, 1) -- white

    local text = score.player .. " : " .. score.opponent
    local windowWidth = love.graphics.getWidth()
    local textWidth = score.font:getWidth(text)

    -- Center the score horizontally
    love.graphics.print(text, (windowWidth - textWidth) / 2, 10)
end

return score
