import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/object"

import "Scripts/trombone"

local gfx <const> = playdate.graphics

-- Dictionary of seconds currently displayed on screen, and their X position
-- Should be used to place notes on the track
local visibleSeconds = {}

function updateTimePositions()
    -- Using the clock of the media player for future sync
    local time = playdate.sound.getCurrentTime()
    -- Using string as keys to have a dict instead of an array
    local currentSecond = "" .. math.floor(time)

    -- Updating positions of existing marks
    for second,xpos in pairs(visibleSeconds) do
        if xpos <= -5 then
            visibleSeconds[second] = nil
        else 
            visibleSeconds[second] -= 1
        end
    end

    if visibleSeconds[currentSecond] == nil then
        visibleSeconds[currentSecond] = 400
    end
end

function displayTime()
    -- Drawing seconds
    for second,xpos in pairs(visibleSeconds) do
        gfx.drawText("" .. second, xpos, 220)
    end
end

function updateDisplay()
    -- Clearing the screen
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, 400, 240)

    displayTime()

    -- Drawing the vertical left bar
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(20, 0, 3, 240)
    gfx.fillRect(30, 0, 3, 240)

    local playerPosition = getPlayerPosition()

    -- Drawing the player (on the left bar)
    local playerCircleX = 27
    local playerCircleY = 20 + 2 * playerPosition
    local playerCircleRadius = 15

    local drawingPlayerFunction = gfx.drawCircleAtPoint
    if playdate.buttonIsPressed("up") or
        playdate.buttonIsPressed("down") or
        playdate.buttonIsPressed("left") or
        playdate.buttonIsPressed("right") or
        playdate.buttonIsPressed("b")
    then
        -- Pressed state
        gfx.setColor(gfx.kColorBlack)
        gfx.fillCircleAtPoint(playerCircleX, playerCircleY, playerCircleRadius)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(playerCircleX, playerCircleY, playerCircleRadius - 2)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillCircleAtPoint(playerCircleX, playerCircleY, playerCircleRadius - 5)
    else
        -- Normal state
        gfx.setColor(gfx.kColorBlack)
        gfx.fillCircleAtPoint(playerCircleX, playerCircleY, playerCircleRadius)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(playerCircleX, playerCircleY, playerCircleRadius - 2)
        
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

    if playdate.isCrankDocked() then
        playdate.ui.crankIndicator:draw()
    end
end

-- Gameplay loop
function playdate.update()
    updateTimePositions()
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