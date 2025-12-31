-- player.lua
-- Player-controlled entity for Football Prototype
-- Handles input, movement, dribbling, and drawing

local player = {}

-- ==============================
-- Size and Movement
-- ==============================
player.w = 20
player.h = 20
player.speed = 250            -- default speed
player.vx = 0                 -- current velocity X
player.vy = 0                 -- current velocity Y
player.lastMoveX = 0          -- last movement direction X
player.lastMoveY = -1         -- default facing up

-- ==============================
-- Colors
-- ==============================
player.color = {0.2, 0.2, 1}       -- main color
player.highlight = {0.4, 0.4, 1}   -- outline/highlight

-- ==============================
-- Spawn player on pitch
-- ==============================
function player.spawn(pitch)
    -- Position near left side, centered vertically
    player.x = pitch.x + 120 - player.w - 5
    player.y = pitch.y + pitch.h / 2 - player.h / 2

    player.lastMoveX = 0
    player.lastMoveY = -1
end

-- ==============================
-- Update player
-- ==============================
-- dt: delta time
-- pitch: pitch object
-- ball: ball object
function player.update(dt, pitch, ball)
    local moveX, moveY = 0, 0

    -- ==============================
    -- Read input
    -- ==============================
    if love.keyboard.isDown("w") then moveY = moveY - 1 end
    if love.keyboard.isDown("s") then moveY = moveY + 1 end
    if love.keyboard.isDown("a") then moveX = moveX - 1 end
    if love.keyboard.isDown("d") then moveX = moveX + 1 end

    -- Normalize diagonal movement
    if moveX ~= 0 or moveY ~= 0 then
        local len = math.sqrt(moveX^2 + moveY^2)
        moveX, moveY = moveX / len, moveY / len

        -- Update facing direction
        player.lastMoveX = moveX
        player.lastMoveY = moveY
    end

    -- ==============================
    -- Adjust speed if dribbling
    -- ==============================
    if ball.owner == player then
        player.speed = 200   -- slightly slower when controlling ball
    else
        player.speed = 250
    end

    -- ==============================
    -- Apply movement
    -- ==============================
    player.vx = moveX * player.speed
    player.vy = moveY * player.speed

    player.x = player.x + player.vx * dt
    player.y = player.y + player.vy * dt

    -- ==============================
    -- Clamp to pitch boundaries
    -- ==============================
    local pitchPadding = 40
    player.x = math.max(pitchPadding, math.min(player.x, 1024 - pitchPadding - player.w))
    player.y = math.max(pitchPadding, math.min(player.y, 576 - pitchPadding - player.h))
end

-- ==============================
-- Draw player
-- ==============================
function player.draw()
    -- Draw highlight (slightly larger rectangle)
    love.graphics.setColor(player.highlight)
    love.graphics.rectangle(
        "fill",
        player.x - 2,
        player.y - 2,
        player.w + 4,
        player.h + 4
    )

    -- Draw main player rectangle
    love.graphics.setColor(player.color)
    love.graphics.rectangle(
        "fill",
        player.x,
        player.y,
        player.w,
        player.h
    )
end

return player
