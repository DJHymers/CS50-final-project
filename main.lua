-- main.lua
local pitch = require("pitch")
local player = require("player")
local ball = require("ball")

function love.load()
    love.window.setMode(1024, 576, {
        resizable = false,
        vsync = true
    })
end

function love.update(dt)
    player.update(dt, pitch, ball)
    ball.update(dt, pitch, player)

    -- Charging shot (left mouse)
    if ball.owner == player and love.mouse.isDown(1) then
        ball.charge = math.min(ball.charge + dt, ball.maxCharge)
    end

    -- Charging pass (right mouse)
    if ball.owner == player and love.mouse.isDown(2) then
        ball.charge = math.min(ball.charge + dt, ball.maxCharge)
    end
end

function love.draw()
    -- Draw pitch
    pitch.draw()

    -- Draw player
    player.draw()

    -- Draw ball
    ball.draw()
end

function love.mousereleased(x, y, button)
    if ball.owner == player then
        local dirX = player.lastMoveX
        local dirY = player.lastMoveY
        local len = math.sqrt(dirX*dirX + dirY*dirY)
        dirX, dirY = dirX/len, dirY/len

        if button == 1 then
            -- Shoot
            local power = ball.shootPower * (ball.charge / ball.maxCharge)
            ball.vx = dirX * power
            ball.vy = dirY * power
            ball.owner = nil
        elseif button == 2 then
            -- Pass
            local power = ball.passPower * (ball.charge / ball.maxCharge)
            ball.vx = dirX * power
            ball.vy = dirY * power
            ball.owner = nil
        end

        ball.charge = 0
    end
end
