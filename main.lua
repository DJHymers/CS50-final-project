-- main.lua
-- Core game loop for Football Prototype
-- Handles game states, scoring, timers, player/opponent updates, and UI

local pitch = require("pitch")
local player = require("player")
local opponent = require("opponent")
local ball = require("ball")
local score = require("score")

-- Game state variables
local gameState = "menu"       -- "menu" or "playing"
local difficulty = "medium"
local maxScore = 5             -- Maximum goals to win
local gameOver = false

-- Timers and text for scoring and victory messages
local goalTimer = 0
local goalText = ""
local winnerTimer = 0
local winnerText = ""

-- Difficulty configuration (affects opponent speed)
local difficultySpeeds = {
    easyOnBall = 100, easyOffBall = 120,
    mediumOnBall = 140, mediumOffBall = 160,
    hardOnBall = 180, hardOffBall = 200
}

-- ==============================
-- LOVE2D load function
-- ==============================
function love.load()
    love.window.setMode(1024, 576, { resizable=false, vsync=true })
    player.spawn(pitch)
    opponent.spawn(pitch)
end

-- ==============================
-- LOVE2D update function
-- ==============================
function love.update(dt)
    -- ==========================
    -- Playing state
    -- ==========================
    if gameState == "playing" and not gameOver then
        -- Update entities
        player.update(dt, pitch, ball)
        opponent.update(dt, pitch, ball, player)
        ball.update(dt, pitch, player, opponent)

        -- Charge ball if player holds space or shift
        if ball.owner == player and (love.keyboard.isDown("space") or love.keyboard.isDown("lshift")) then
            ball.charge = (ball.charge or 0) + dt * 4.0
            ball.charge = math.min(ball.charge, ball.maxCharge)
        end

        -- ==========================
        -- Handle scoring
        -- ==========================
        if ball.scored and goalTimer <= 0 then
            if ball.scored == "player" then
                score.player = score.player + 1
                goalText = "PLAYER GOAL!"
            else
                score.opponent = score.opponent + 1
                goalText = "OPPONENT GOAL!"
            end
            goalTimer = 2.0 -- show goal message for 2 seconds

            -- Check for maximum score to determine winner
            if score.player >= maxScore then
                winnerText = "PLAYER WINS!"
                winnerTimer = 5.0
                gameOver = true
            elseif score.opponent >= maxScore then
                winnerText = "OPPONENT WINS!"
                winnerTimer = 5.0
                gameOver = true
            end
        end

        -- ==========================
        -- Handle out-of-bounds (goal kick)
        -- ==========================
        if ball.outOfBounds == "left" then
            -- Ball went out past left goal → right team goal kick
            ball.reset()
            player.spawn(pitch) -- player at appropriate half
            opponent.spawn(pitch) -- opponent at halfway line
            ball.outOfBounds = nil
        elseif ball.outOfBounds == "right" then
            -- Ball went out past right goal → left team goal kick
            ball.reset()
            player.spawn(pitch)
            opponent.spawn(pitch)
            ball.outOfBounds = nil
        end
    end

    -- ==========================
    -- Goal timer countdown
    -- ==========================
    if goalTimer > 0 then
        goalTimer = goalTimer - dt
        if goalTimer <= 0 then
            -- Reset positions after pause
            ball.reset()
            player.spawn(pitch)
            opponent.spawn(pitch)
            ball.scored = nil
            goalText = ""
        end
    end

    -- ==========================
    -- Winner timer countdown
    -- ==========================
    if winnerTimer > 0 then
        winnerTimer = winnerTimer - dt
        if winnerTimer <= 0 then
            -- Reset everything and return to menu
            score.player = 0
            score.opponent = 0
            ball.reset()
            player.spawn(pitch)
            opponent.spawn(pitch)
            goalText = ""
            winnerText = ""
            gameOver = false
            gameState = "menu"
        end
    end
end

-- ==============================
-- LOVE2D draw function
-- ==============================
function love.draw()
    if gameState == "menu" then
        -- Draw menu
        love.graphics.setColor(1,1,1)
        love.graphics.printf("FOOTBALL PROTOTYPE", 0, 150, 1024, "center")
        love.graphics.printf("Select difficulty:", 0, 220, 1024, "center")
        love.graphics.printf("1 - Easy | 2 - Medium | 3 - Hard", 0, 260, 1024, "center")
    elseif gameState == "playing" then
        -- Draw pitch and entities
        pitch.draw()
        player.draw()
        opponent.draw()
        ball.draw()
        score.draw()

        -- Draw power bar if player owns ball
        if ball.owner == player then
            local barWidth, barHeight = 100, 10
            local ratio = (ball.charge or 0) / ball.maxCharge

            love.graphics.setColor(1,1,1)
            love.graphics.print("POWER", 20, 5)

            love.graphics.setColor(0,0,0)
            love.graphics.rectangle("fill", 20, 20, barWidth, barHeight)

            love.graphics.setColor(0,1,0)
            love.graphics.rectangle("fill", 20, 20, barWidth * ratio, barHeight)
        end

        -- Draw goal or winner messages
        if goalText ~= "" then
            love.graphics.setColor(1, 1, 0)
            love.graphics.printf(goalText, 0, 250, 1024, "center")
        elseif winnerText ~= "" then
            love.graphics.setColor(1, 1, 0)
            love.graphics.printf(winnerText, 0, 250, 1024, "center")
        end
    end
end

-- ==============================
-- Handle menu input for difficulty
-- ==============================
function love.keypressed(key)
    if gameState == "menu" then
        if key == "1" then
            difficulty = "easy"
            opponent.speedOnBall = difficultySpeeds.easyOnBall
            opponent.speedOffBall = difficultySpeeds.easyOffBall
        elseif key == "2" then
            difficulty = "medium"
            opponent.speedOnBall = difficultySpeeds.mediumOnBall
            opponent.speedOffBall = difficultySpeeds.mediumOffBall
        elseif key == "3" then
            difficulty = "hard"
            opponent.speedOnBall = difficultySpeeds.hardOnBall
            opponent.speedOffBall = difficultySpeeds.hardOffBall
        end

        if key == "1" or key == "2" or key == "3" then
            -- Spawn players and ball
            player.spawn(pitch)
            opponent.spawn(pitch)
            ball.reset()
            gameState = "playing"
        end
    end
end

-- ==============================
-- Handle releasing the ball
-- ==============================
function love.keyreleased(key)
    if ball.owner ~= player then return end

    -- Determine facing direction
    local dirX, dirY = player.lastMoveX, player.lastMoveY
    if dirX == 0 and dirY == 0 then dirY = -1 end

    -- Normalize direction
    local len = math.sqrt(dirX*dirX + dirY*dirY)
    dirX, dirY = dirX/len, dirY/len

    -- Determine power from charge and movement momentum
    local t = (ball.charge or 0) / ball.maxCharge
    if t <= 0 then return end
    local chargeRatio = math.sqrt(t)
    local moveSpeed = math.sqrt((player.vx or 0)^2 + (player.vy or 0)^2)
    local momentum = moveSpeed * 0.35

    local power
    if key == "lshift" then
        power = ball.passPower * chargeRatio + momentum
    elseif key == "space" then
        power = ball.shootPower * chargeRatio + momentum
    else
        return
    end

    -- Release the ball
    ball.release(dirX, dirY, power)
    ball.charge = 0
end
