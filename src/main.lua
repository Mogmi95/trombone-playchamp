import "CoreLibs/graphics"

local gfx <const> = playdate.graphics

-- Vertical position of the dot, from 0 (top) to 100 (bottom)
local playerPosition = 0

function updatePlayerPosition()
    playerPosition = 100 - math.abs((playdate.getCrankPosition() - 180) / 1.8)
end

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

    -- Drawing the player (on the left bar)
    local playerCircleX = 20
    local playerCircleY = 20 + 2 * playerPosition
    local playerCircleRadius = 5

    local drawingPlayerFunction = gfx.drawCircleAtPoint
    if playdate.buttonIsPressed("up") or
        playdate.buttonIsPressed("down") or
        playdate.buttonIsPressed("left") or
        playdate.buttonIsPressed("right")
    then
        drawingPlayerFunction = gfx.fillCircleAtPoint
    end

    drawingPlayerFunction(playerCircleX, playerCircleY, playerCircleRadius)
end

-- Gameplay loop
initGame()
function playdate.update()
    updatePlayerPosition()
    updateDisplay()
end