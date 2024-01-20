import "CoreLibs/graphics"
import "CoreLibs/ui"

import "Scripts/trombone"

local gfx <const> = playdate.graphics

function initGame()
end

function updateDisplay()
        -- Clearing the screen
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, 400, 240)

    -- Drawing the vertical left bar
    gfx.setColor(gfx.kColorBlack)
    gfx.drawLine(20, 20, 20, 220)
    gfx.drawLine(16, 20, 24, 20)
    gfx.drawLine(16, 220, 24, 220)

    local playerPosition = getPlayerPosition()

    -- Drawing the player (on the left bar)
    local playerCircleX = 20
    local playerCircleY = 20 + 2 * playerPosition
    local playerCircleRadius = 5

    local drawingPlayerFunction = gfx.drawCircleAtPoint
    if playdate.buttonIsPressed("up") or
        playdate.buttonIsPressed("down") or
        playdate.buttonIsPressed("left") or
        playdate.buttonIsPressed("right") or
        playdate.buttonIsPressed("b")
    then
        drawingPlayerFunction = gfx.fillCircleAtPoint
    end

    if playdate.buttonJustPressed("up") or
        playdate.buttonJustPressed("down") or
        playdate.buttonJustPressed("left") or
        playdate.buttonJustPressed("right") or
        playdate.buttonJustPressed("b")
    then
        startTooting(getPitch(playerPosition))
    end

    if playdate.buttonJustReleased("up") or
        playdate.buttonJustReleased("down") or
        playdate.buttonJustReleased("left") or
        playdate.buttonJustReleased("right") or
        playdate.buttonJustReleased("b")
    then
        stopTooting()
    end


    drawingPlayerFunction(playerCircleX, playerCircleY, playerCircleRadius)

    if playdate.isCrankDocked() then
        playdate.ui.crankIndicator:draw()
    end
end

-- Gameplay loop
initGame()
function playdate.update()
    updateDisplay()
end

function playdate.cranked()
    if playdate.buttonIsPressed("up") or
        playdate.buttonIsPressed("down") or
        playdate.buttonIsPressed("left") or
        playdate.buttonIsPressed("right") or
        playdate.buttonIsPressed("b")
    then
        startTooting(getPitch(getPlayerPosition()))
    end
end