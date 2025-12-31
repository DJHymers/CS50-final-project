-- ball.lua
-- Ball entity for Football Prototype
-- Handles physics, possession, shooting, goal detection, and drawing

local ball = {}
local score = require("score")

-- ==============================
-- Ball properties
-- ==============================
ball.owner = nil               -- current owner (player or opponent)
ball.holdDistance = 20         -- distance from owner's center
ball.x = 512
ball.y = 288
ball.r = 8                     -- radius
ball.vx = 0
ball.vy = 0
ball.pickupCooldown = 0.75
ball.pickupTimer = 0
ball.friction = 0.96
ball.currentFriction = ball.friction
ball.maxSpeed = 600
ball.charge = 0
ball.maxCharge = 1.2
ball.shootPower = 1000
ball.passPower = 850
ball.scored = nil
ball.outOfBounds = nil

-- ==============================
-- Reset ball after goal or kick-off
-- ==============================
function ball.reset()
    ball.x = 512
    ball.y = 288
    ball.vx = 0
    ball.vy = 0
    ball.owner = nil
    ball.charge = 0
    ball.currentFriction = ball.friction
    ball.pickupTimer = ball.pickupCooldown
    ball.scored = nil
    ball.outOfBounds = nil
end

-- ==============================
-- Release ball in a direction
-- ==============================
-- dirX, dirY: normalized direction
-- power: kick power
function ball.release(dirX, dirY, power)
    ball.owner = nil
    dirX = dirX or 1
    dirY = dirY or 0

    local pop = 120 -- small boost from foot
    ball.vx = dirX * power + dirX * pop
    ball.vy = dirY * power + dirY * pop

    -- Slightly offset ball from owner to prevent immediate re-pickup
    ball.x = ball.x + dirX * 10
    ball.y = ball.y + dirY * 10

    ball.pickupTimer = ball.pickupCooldown
    ball.currentFriction = (power < ball.shootPower) and 0.90 or 0.97
end

-- ==============================
-- Check if an entity can take possession
-- ==============================
function ball.checkPossession(entity)
    if ball.owner == entity or ball.pickupTimer > 0 then return end

    local ex = entity.x + entity.w/2
    local ey = entity.y + entity.h/2
    local dx = ball.x - ex
    local dy = ball.y - ey
    local dist = math.sqrt(dx*dx + dy*dy)
    local touchRadius = ball.r + math.max(entity.w, entity.h)/2

    if dist <= touchRadius then
        ball.owner = entity
        ball.pickupTimer = ball.pickupCooldown
        ball.currentFriction = ball.friction
    end
end

-- ==============================
-- Update ball physics and possession
-- ==============================
function ball.update(dt, pitch, player, opponent)
    -- Countdown pickup timer
    if ball.pickupTimer > 0 then
        ball.pickupTimer = ball.pickupTimer - dt
    end

    -- Possession checks
    ball.checkPossession(player)
    ball.checkPossession(opponent)

    -- Ball follows owner
    if ball.owner then
        local px = ball.owner.x + ball.owner.w/2
        local py = ball.owner.y + ball.owner.h/2
        local dirX, dirY = ball.owner.lastMoveX, ball.owner.lastMoveY
        if dirX == 0 and dirY == 0 then dirX, dirY = 1, 0 end
        local len = math.sqrt(dirX^2 + dirY^2)
        dirX, dirY = dirX/len, dirY/len

        ball.x = px + dirX * ball.holdDistance
        ball.y = py + dirY * ball.holdDistance
        ball.vx, ball.vy = 0, 0
        return
    end

    -- ==============================
    -- Ball movement & friction
    -- ==============================
    ball.x = ball.x + ball.vx * dt
    ball.y = ball.y + ball.vy * dt

    local f = ball.currentFriction or ball.friction
    ball.vx = ball.vx * f
    ball.vy = ball.vy * f

    -- Stop tiny velocities
    if math.abs(ball.vx) < 5 then ball.vx = 0 end
    if math.abs(ball.vy) < 5 then ball.vy = 0 end

    -- ==============================
    -- Collision: entities can "block" the ball
    -- ==============================
    for _, e in ipairs({player, opponent}) do
        if ball.owner ~= e then
            local ex, ey = e.x + e.w/2, e.y + e.h/2
            local dx, dy = ball.x - ex, ball.y - ey
            local dist = math.sqrt(dx^2 + dy^2)
            if dist <= ball.r + math.max(e.w, e.h)/2 then
                ball.owner = e
                ball.pickupTimer = ball.pickupCooldown
                ball.currentFriction = ball.friction
            end
        end
    end

    -- ==============================
    -- Pitch boundaries & goal detection
    -- ==============================
    local left = pitch.x
    local right = pitch.x + pitch.w
    local top = pitch.y
    local bottom = pitch.y + pitch.h

    local goalWidth = 120
    local goalDepth = 30
    local postWidth = 5
    local goalY = pitch.y + pitch.h/2 - goalWidth/2

    -- Left goal
    if ball.x - ball.r < left then
        if ball.y > goalY and ball.y < goalY + goalWidth then
            ball.scored = "opponent"
            local netBack = left - goalDepth
            if ball.x < netBack then
                ball.x = netBack
                ball.vx, ball.vy = 0, 0
            end
        elseif (ball.y > goalY - postWidth and ball.y <= goalY) or
               (ball.y >= goalY + goalWidth and ball.y < goalY + goalWidth + postWidth) then
            -- Rebound off post
            ball.x = left + ball.r
            ball.vx = -ball.vx
        else
            -- Out of bounds → goal kick
            ball.owner = nil
            ball.outOfBounds = "left"
        end
    end

    -- Right goal
    if ball.x + ball.r > right then
        if ball.y > goalY and ball.y < goalY + goalWidth then
            ball.scored = "player"
            local netBack = right + goalDepth
            if ball.x > netBack then
                ball.x = netBack
                ball.vx, ball.vy = 0, 0
            end
        elseif (ball.y > goalY - postWidth and ball.y <= goalY) or
               (ball.y >= goalY + goalWidth and ball.y < goalY + goalWidth + postWidth) then
            -- Rebound off post
            ball.x = right - ball.r
            ball.vx = -ball.vx
        else
            ball.owner = nil
            ball.outOfBounds = "right"
        end
    end

    -- Top/bottom wall bounce
    if ball.y - ball.r < top then
        ball.y = top + ball.r
        ball.vy = -ball.vy
    elseif ball.y + ball.r > bottom then
        ball.y = bottom - ball.r
        ball.vy = -ball.vy
    end
end

-- ==============================
-- Draw ball
-- ==============================
function ball.draw()
    love.graphics.setColor(1, 1, 0)
    love.graphics.circle("fill", ball.x, ball.y, ball.r)
end

return ball
