-- ball.lua
local ball = {}

ball.owner = nil
ball.holdDistance = 20

ball.x = 512
ball.y = 288
ball.r = 8

ball.vx = 0
ball.vy = 0

ball.friction = 0.96   -- slows the ball each frame
ball.maxSpeed = 600

function ball.update(dt, pitch, player)
    
    -- If ball is free, check for pickup
    if ball.owner == nil then
        local dx = player.x + player.w/2 - ball.x
        local dy = player.y + player.h/2 - ball.y
        local dist = math.sqrt(dx*dx + dy*dy)

        if dist < 25 then
            ball.owner = player
        end
    end

    if ball.owner ~= nil then
        -- Ball follows player direction
        local px = ball.owner.x + ball.owner.w/2
        local py = ball.owner.y + ball.owner.h/2

        -- Determine direction of movement
        local dirX, dirY = ball.owner.lastMoveX, ball.owner.lastMoveY

        -- If player is standing still, keep ball in front
        if dirX == 0 and dirY == 0 then
            dirX = 0
            dirY = -1
        end

        -- Normalize
        local len = math.sqrt(dirX*dirX + dirY*dirY)
        dirX, dirY = dirX/len, dirY/len

        -- Position ball in front of player
        ball.x = px + dirX * ball.holdDistance
        ball.y = py + dirY * ball.holdDistance

        -- Ball has no velocity while held
        ball.vx = 0
        ball.vy = 0

        return -- skip normal physics
    end

    -- Apply velocity
    ball.x = ball.x + ball.vx * dt
    ball.y = ball.y + ball.vy * dt

    -- Apply friction
    ball.vx = ball.vx * ball.friction
    ball.vy = ball.vy * ball.friction

    -- Stop tiny velocities
    if math.abs(ball.vx) < 5 then ball.vx = 0 end
    if math.abs(ball.vy) < 5 then ball.vy = 0 end

    -- Collision with pitch boundaries
    local left = pitch.x + ball.r
    local right = pitch.x + pitch.w - ball.r
    local top = pitch.y + ball.r
    local bottom = pitch.y + pitch.h - ball.r

    if ball.x < left then
        ball.x = left
        ball.vx = -ball.vx
    elseif ball.x > right then
        ball.x = right
        ball.vx = -ball.vx
    end

    if ball.y < top then
        ball.y = top
        ball.vy = -ball.vy
    elseif ball.y > bottom then
        ball.y = bottom
        ball.vy = -ball.vy
    end
end

function ball.draw()
    love.graphics.setColor(1, 1, 0)
    love.graphics.circle("fill", ball.x, ball.y, ball.r)
end

return ball
