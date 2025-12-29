-- Player.lua
local player = {}

player.x = 100
player.y = 200
player.w = 20
player.h = 20
player.speed = 250

player.lastMoveX = 0
player.lastMoveY = -1   -- default facing up

-- Base Colour (Controlled player)
player.color = {0.2, 0.2, 1}

-- Highlight colour (Lighter shade)
player.highlight = {0.4, 0.4, 1}

function player.update(dt, pitch, ball)
    local moveX, moveY = 0, 0

    if moveX ~= 0 or moveY ~= 0 then
        player.lastMoveX = moveX
        player.lastMoveY = moveY
    end

    if ball.owner == player then
        player.speed = 200   -- slower when dribbling
    else
        player.speed = 250   -- normal speed
    end

    
    if love.keyboard.isDown("w") then moveY = moveY - 1 end
    if love.keyboard.isDown("s") then moveY = moveY + 1 end
    if love.keyboard.isDown("a") then moveX = moveX - 1 end
    if love.keyboard.isDown("d") then moveX = moveX + 1 end

    -- Normalize diagonal movement
    if moveX ~= 0 or moveY ~= 0 then
        local len = math.sqrt(moveX * moveX + moveY * moveY)
        moveX, moveY = moveX / len, moveY / len
    end

    -- Apply movement
    player.x = player.x + moveX * player.speed * dt
    player.y = player.y + moveY * player.speed * dt

    -- Clamp to pitch boundaries
    local pitchPadding = 40
    player.x = math.max(pitchPadding, math.min(player.x, 1024 - pitchPadding - player.w))
    player.y = math.max(pitchPadding, math.min(player.y, 576 - pitchPadding - player.h))
end

function player.draw()
    -- Draw highlight first (slightly bigger) 
    love.graphics.setColor(player.highlight) 
    love.graphics.rectangle("fill", 
        player.x - 2, 
        player.y - 2, 
        player.w + 4, 
        player.h + 4 
    ) 
    
    -- Draw actual player 
    love.graphics.setColor(player.color) 
    love.graphics.rectangle("fill", 
        player.x, 
        player.y, 
        player.w, 
        player.h 
    ) 
end 

return player