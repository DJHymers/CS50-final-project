-- opponent.lua
-- AI-controlled opponent for Football Prototype
-- Handles movement, possession logic, evasive behavior, and shooting

local opponent = {}

-- ==============================
-- Size and movement
-- ==============================
opponent.w = 20
opponent.h = 20

-- Base movement speeds (adjusted by difficulty)
opponent.speed = 200        -- default base speed
opponent.speedOnBall = 0    -- speed when opponent has the ball
opponent.speedOffBall = 0   -- speed when opponent is chasing

-- Last movement direction (used for ball handling)
opponent.lastMoveX = 0
opponent.lastMoveY = -1

-- ==============================
-- AI state and shooting
-- ==============================
opponent.state = "chase"    -- "chase" = going for ball, "attack" = has ball
opponent.shootCooldown = 1.0
opponent.shootTimer = 0

-- ==============================
-- Colors for drawing
-- ==============================
opponent.color = {1, 0.5, 0.25}     -- main body
opponent.highlight = {1, 0.7, 0.45} -- outline/highlight

-- ==============================
-- Spawn opponent on pitch
-- ==============================
function opponent.spawn(pitch)
    -- Start near right side, centered vertically
    opponent.x = pitch.x + pitch.w - 120 + 5
    opponent.y = pitch.y + pitch.h / 2 - opponent.h / 2
    opponent.lastMoveX = 0
    opponent.lastMoveY = -1
end

-- ==============================
-- AI Update
-- ==============================
-- dt: delta time
-- pitch: pitch object
-- ball: ball object
-- player: player object
function opponent.update(dt, pitch, ball, player)
    -- Update AI state based on possession
    if ball.owner == opponent then
        opponent.state = "attack"
    else
        opponent.state = "chase"
    end

    -- Countdown shooting cooldown timer
    if opponent.shootTimer > 0 then
        opponent.shootTimer = opponent.shootTimer - dt
    end

    local targetX, targetY

    -- ==============================
    -- Determine target position
    -- ==============================
    if opponent.state == "chase" then
        -- Out of possession: go toward the ball
        targetX = ball.x
        targetY = ball.y
        opponent.speed = opponent.speedOffBall
    else
        -- In possession: move toward opponent's goal
        targetX = pitch.x
        targetY = pitch.y + pitch.h / 2

        -- Evasive logic: avoid player if in path
        local playerX = player.x + player.w / 2
        local playerY = player.y + player.h / 2

        local dxGoal = targetX - (opponent.x + opponent.w/2)
        local dyGoal = targetY - (opponent.y + opponent.h/2)
        local dxPlayer = playerX - (opponent.x + opponent.w/2)
        local dyPlayer = playerY - (opponent.y + opponent.h/2)

        -- Dot product to check if player is roughly in path
        local dot = dxGoal*dxPlayer + dyGoal*dyPlayer
        local distPlayer = math.sqrt(dxPlayer^2 + dyPlayer^2)

        -- If player is in path and close, dodge perpendicular
        if dot > 0 and distPlayer < 100 then
            local dodgeDirection = 1
            if math.random() < 0.5 then dodgeDirection = -1 end
            local perpX = -dyGoal * dodgeDirection
            local perpY = dxGoal * dodgeDirection
            local len = math.sqrt(perpX^2 + perpY^2)
            perpX, perpY = perpX / len, perpY / len

            targetX = (opponent.x + opponent.w/2) + perpX * 50
            targetY = (opponent.y + opponent.h/2) + perpY * 50
            opponent.speed = opponent.speedOnBall - 10
        else
            opponent.speed = opponent.speedOnBall
        end
    end

    -- ==============================
    -- Move toward target
    -- ==============================
    local moveX = targetX - (opponent.x + opponent.w/2)
    local moveY = targetY - (opponent.y + opponent.h/2)
    local len = math.sqrt(moveX^2 + moveY^2)

    if len > 0 then
        moveX, moveY = moveX / len, moveY / len
        opponent.lastMoveX = moveX
        opponent.lastMoveY = moveY
    else
        moveX, moveY = 0, 0
    end

    -- Apply movement
    opponent.x = opponent.x + moveX * opponent.speed * dt
    opponent.y = opponent.y + moveY * opponent.speed * dt

    -- Clamp to pitch bounds
    local padding = 40
    opponent.x = math.max(padding, math.min(opponent.x, 1024 - padding - opponent.w))
    opponent.y = math.max(padding, math.min(opponent.y, 576 - padding - opponent.h))

    -- ==============================
    -- Attempt to take possession
    -- ==============================
    local dx = (opponent.x + opponent.w/2) - ball.x
    local dy = (opponent.y + opponent.h/2) - ball.y
    local dist = math.sqrt(dx*dx + dy*dy)

    if dist <= ball.r + math.max(opponent.w, opponent.h)/2 and ball.pickupTimer <= 0 then
        ball.owner = opponent
        ball.pickupTimer = ball.pickupCooldown
        ball.currentFriction = ball.friction
    end

    -- ==============================
    -- Shoot logic (only inside goal box)
    -- ==============================
    if opponent.state == "attack" and len < 150 and opponent.shootTimer <= 0 then
        local ox, oy = opponent.x + opponent.w/2, opponent.y + opponent.h/2
        local goalBoxX = pitch.x
        local goalBoxY = pitch.y + pitch.h/2 - 60
        local goalBoxW = 30
        local goalBoxH = 120

        -- Check if inside shooting box
        if ox <= goalBoxX + goalBoxW and oy >= goalBoxY and oy <= goalBoxY + goalBoxH then
            local dirX = pitch.x - ox
            local dirY = pitch.y + pitch.h/2 - oy
            local dLen = math.sqrt(dirX^2 + dirY^2)
            dirX, dirY = dirX / dLen, dirY / dLen
            ball.release(dirX, dirY, ball.shootPower * 0.8)
            opponent.shootTimer = opponent.shootCooldown
        end
    end
end

-- ==============================
-- Draw opponent
-- ==============================
function opponent.draw()
    -- Draw highlight/outlines
    love.graphics.setColor(opponent.highlight)
    love.graphics.rectangle("fill", opponent.x - 2, opponent.y - 2, opponent.w + 4, opponent.h + 4)
    -- Draw main body
    love.graphics.setColor(opponent.color)
    love.graphics.rectangle("fill", opponent.x, opponent.y, opponent.w, opponent.h)
end

return opponent
