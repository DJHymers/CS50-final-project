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
end

function love.draw()
    -- Draw pitch
    pitch.draw()

    -- Draw player
    player.draw()

    -- Draw ball
    ball.draw()
end
